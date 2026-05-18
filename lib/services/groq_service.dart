import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class GroqService {
  static String get _apiKey => dotenv.env['GEMMA_API_KEY'] ?? '';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  // Prioritas: Gemma 4 dulu, fallback ke Gemma 3
  static const List<String> _modelFallbacks = [
    'gemma-4-26b-a4b-it',
    'gemma-4-31b-it',
  ];

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<String> chat({
    required String systemPrompt,
    required String userMessage,
    int maxTokens = 256,
  }) async {
    Exception? lastError;

    for (final model in _modelFallbacks) {
      debugPrint('Gemma API trying model: $model');
      try {
        final response = await _dio.post(
          '/models/$model:generateContent?key=$_apiKey',
          data: {
            'system_instruction': {
              'parts': [
                {'text': systemPrompt},
              ],
            },
            'contents': [
              {
                'role': 'user',
                'parts': [
                  {'text': userMessage},
                ],
              },
            ],
            'generationConfig': {'maxOutputTokens': maxTokens},
          },
        );
        final text =
            response.data['candidates'][0]['content']['parts'][0]['text']
                as String;
        debugPrint('Gemma API success with model: $model');
        return text;
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        final body = e.response?.data?.toString() ?? '';
        lastError = Exception('Gemma API error $status ($model): $body');
        debugPrint('Model $model failed ($status), trying next...');
        if (status != 500 && status != 503) rethrow;
      }
    }

    throw lastError!;
  }

  Future<Map<String, dynamic>> chatJson({
    required String systemPrompt,
    required String userMessage,
    int maxTokens = 512,
  }) async {
    final raw = await chat(
      systemPrompt: systemPrompt,
      userMessage: userMessage,
      maxTokens: maxTokens,
    );
    // Strip thinking tags dan markdown
    var clean = raw
        .replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '')
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();
    // Ambil hanya bagian JSON-nya
    final jsonStart = clean.indexOf('{');
    final jsonEnd = clean.lastIndexOf('}');
    if (jsonStart != -1 && jsonEnd != -1) {
      clean = clean.substring(jsonStart, jsonEnd + 1);
    }
    debugPrint('chatJson clean: $clean');
    return jsonDecode(clean) as Map<String, dynamic>;
  }
}
