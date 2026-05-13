import 'dart:convert';
import 'package:dio/dio.dart';

class GroqService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  static const String _model = 'meta-llama/llama-4-scout-17b-16e-instruct';
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<String> chat({
    required String systemPrompt,
    required String userMessage,
    int maxTokens = 256,
  }) async {
    final response = await _dio.post(
      '/chat/completions',
      data: {
        'model': _model,
        'max_tokens': maxTokens,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userMessage},
        ],
      },
    );

    return response.data['choices'][0]['message']['content'] as String;
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
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
