import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_service.dart';
import '../../core/localization/app_localizations.dart';

class ResultsPage extends ConsumerStatefulWidget {
  const ResultsPage({super.key});
  static const routeName = '/results';

  @override
  ConsumerState<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends ConsumerState<ResultsPage> {
  late final ConfettiController _confetti;
  final AiService _ai = AiService();
  String _summary = '';

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confetti.play();
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final score = args?['score'] as int? ?? 0;
      final total = args?['total'] as int? ?? 0;
      _loadSummary(score, total);
    });
  }

  Future<void> _loadSummary(int score, int total) async {
    final text = await _ai.chat('Generate a one-line friendly feedback for score $score/$total.');
    setState(() => _summary = text);
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final score = args?['score'] as int? ?? 0;
    final total = args?['total'] as int? ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(t.t('results'))),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.9 + 0.1 * value,
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      const Icon(Icons.emoji_events_rounded, size: 72, color: Colors.amber),
                      const SizedBox(height: 12),
                      Text('${t.t('yourScore')}: $score / $total', style: Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_summary.isNotEmpty)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(_summary, textAlign: TextAlign.center),
                    ),
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.orange, Colors.purple],
            ),
          )
        ],
      ),
    );
  }
}
