import 'package:dio/dio.dart';

// NOTE: The API key should be stored securely (e.g. via a backend proxy or
// environment variable injected at build time). Do NOT commit real keys here.
const _claudeApiUrl = 'https://api.anthropic.com/v1/messages';
const _model = 'claude-sonnet-4-20250514';

enum CoachTopic { workout, meal, recovery, motivation }

// Fallback responses when the API is unavailable
const _fallbacks = {
  CoachTopic.workout:
      'Focus on compound movements today. Consistency beats intensity — keep showing up.',
  CoachTopic.meal:
      'Fuel your body with lean protein, complex carbs, and plenty of vegetables.',
  CoachTopic.recovery:
      'Rest is where growth happens. Prioritise sleep and stay hydrated.',
  CoachTopic.motivation:
      'Every rep, every step — you are building the best version of yourself.',
};

class AiCoachService {
  final Dio _dio;
  final String apiKey;

  AiCoachService({required this.apiKey, Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 30),
            ));

  Future<String> ask({
    required CoachTopic topic,
    required String systemContext,
  }) async {
    final questions = {
      CoachTopic.workout:
          'What specific workout should I do today based on my profile and recent activity?',
      CoachTopic.meal:
          'Suggest a high-protein meal or snack that matches my fitness goal for today.',
      CoachTopic.recovery:
          'Give me a recovery or rest-day tip based on my current streak and workload.',
      CoachTopic.motivation:
          'Give me a short, personalised motivational message based on my progress this week.',
    };

    try {
      final response = await _dio.post(
        _claudeApiUrl,
        options: Options(headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        }),
        data: {
          'model': _model,
          'max_tokens': 1000,
          'system': systemContext,
          'messages': [
            {'role': 'user', 'content': questions[topic]},
          ],
        },
      );

      final content = response.data['content'] as List;
      return (content.first as Map<String, dynamic>)['text'] as String;
    } catch (_) {
      return _fallbacks[topic]!;
    }
  }
}
