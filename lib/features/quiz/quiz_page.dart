import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ai/ai_service.dart';
import '../../core/localization/app_localizations.dart';

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({super.key});
  static const routeName = '/quiz';

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  final AiService _ai = AiService();
  List<Question> _questions = [];
  int _index = 0;
  Map<int, int> _answers = {}; // questionId -> selectedIndex
  String _aiFeedback = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('answers');
    if (saved != null) {
      final decoded = Map<String, dynamic>.from(jsonDecode(saved));
      _answers = decoded.map((k, v) => MapEntry(int.parse(k), v as int));
    }
    final data = await rootBundle.loadString('assets/questions.json');
    final list = jsonDecode(data) as List;
    _questions = list.map((e) => Question.fromJson(Map<String, dynamic>.from(e))).toList();
    setState(() => _loading = false);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('answers', jsonEncode(_answers));
  }

  Future<void> _selectAnswer(int questionId, int optionIndex) async {
    setState(() {
      _answers[questionId] = optionIndex;
      _aiFeedback = '';
    });
    await _persist();

    final q = _questions.firstWhere((q) => q.id == questionId);
    final feedback = await _ai.getQuizFeedback(question: q.question, selectedAnswer: q.options[optionIndex]);
    setState(() => _aiFeedback = feedback);
  }

  int _score() {
    int s = 0;
    for (final q in _questions) {
      final a = _answers[q.id];
      if (a != null && a == q.correctIndex) s++;
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator())) ;
    }

    final question = _questions[_index];
    final selected = _answers[question.id];

    return Scaffold(
      appBar: AppBar(title: Text(t.t('startQuiz'))),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Padding(
          key: ValueKey(_index),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(value: (_index + 1) / _questions.length),
              const SizedBox(height: 16),
              Text(question.question, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ...List.generate(question.options.length, (i) {
                final isSelected = selected == i;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: _BounceButton(
                    onTap: () => _selectAnswer(question.id, i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceVariant,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off),
                          const SizedBox(width: 12),
                          Expanded(child: Text(question.options[i])),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              if (_aiFeedback.isNotEmpty)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: _aiFeedback.isNotEmpty ? 1 : 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_aiFeedback)),
                    ],
                  ),
                ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _index > 0
                          ? () => setState(() => _index--)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                      label: Text(t.t('previous')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _index < _questions.length - 1
                          ? () => setState(() => _index++)
                          : () {
                              final s = _score();
                              Navigator.of(context).pushNamed('/results', arguments: {'score': s, 'total': _questions.length});
                            },
                      icon: Icon(_index < _questions.length - 1 ? Icons.chevron_right : Icons.check),
                      label: Text(t.t('next')),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Question {
  final int id;
  final String question;
  final List<String> options;
  final int correctIndex;

  Question({required this.id, required this.question, required this.options, required this.correctIndex});

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as int,
        question: json['question'] as String,
        options: (json['options'] as List).map((e) => e.toString()).toList(),
        correctIndex: json['correctIndex'] as int,
      );
}

class _BounceButton extends StatefulWidget {
  const _BounceButton({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  State<_BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<_BounceButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 100), lowerBound: 0.0, upperBound: 0.06);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails d) => _controller.forward();
  void _onTapUp(TapUpDetails d) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (d) {
        _onTapUp(d);
        widget.onTap();
      },
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1 - _controller.value;
          return Transform.scale(scale: scale, child: child);
        },
        child: widget.child,
      ),
    );
  }
}
