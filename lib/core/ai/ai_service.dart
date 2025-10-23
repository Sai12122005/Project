import 'dart:async';

import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  AiService({String? apiKey}) {
    final key = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY');
    if (key.isNotEmpty) {
      _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: key);
    }
  }

  GenerativeModel? _model;

  Future<String> getQuizFeedback({required String question, required String selectedAnswer}) async {
    final prompt = 'Question: $question\nAnswer: $selectedAnswer\nGive short, friendly feedback for a student.';
    return _safeText(prompt);
  }

  Future<String> chat(String userMessage) async {
    final prompt = 'You are a friendly AI tutor. Reply concisely and educationally.\nUser: $userMessage';
    return _safeText(prompt);
  }

  Future<String> _safeText(String prompt) async {
    try {
      if (_model == null) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        return 'AI response not available. Using local helper: ${_simpleHelper(prompt)}';
      }
      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text;
      return text?.trim().isNotEmpty == true ? text!.trim() : 'AI response not available.';
    } catch (_) {
      return 'AI response not available.';
    }
  }

  String _simpleHelper(String input) {
    if (input.toLowerCase().contains('capital') && input.toLowerCase().contains('india')) {
      return 'The capital of India is New Delhi.';
    }
    if (input.toLowerCase().contains('red planet')) {
      return 'Mars is called the Red Planet due to iron oxide.';
    }
    return 'Keep learning! Great question—try thinking of key concepts first.';
  }
}
