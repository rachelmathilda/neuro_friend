import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class GroqService {
  static String get _apiKey => dotenv.env['GEMMA_API_KEY'] ?? '';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  // ✅ Primary model saja — fallback manual di bawah
  static const String _primaryModel = 'gemma-4-26b-a4b-it';
  static const String _fallbackModel = 'gemma-4-31b-it';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<String> _callModel({
    required String model,
    required String systemPrompt,
    required String userMessage,
    required int maxTokens,
    required bool jsonMode,
  }) async {
    debugPrint('Gemma API trying model: $model');
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
        'generationConfig': {
          'maxOutputTokens': maxTokens,
          if (jsonMode) 'responseMimeType': 'application/json',
        },
      },
    );
    debugPrint('Gemma API success with model: $model');
    return response.data['candidates'][0]['content']['parts'][0]['text']
        as String;
  }

  Future<String> chat({
    required String systemPrompt,
    required String userMessage,
    int maxTokens = 256,
    bool jsonMode = false,
  }) async {
    try {
      return await _callModel(
        model: _primaryModel,
        systemPrompt: systemPrompt,
        userMessage: userMessage,
        maxTokens: maxTokens,
        jsonMode: jsonMode,
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      debugPrint('Model $_primaryModel failed ($status), trying fallback...');
      // Fallback ke model kedua hanya untuk error 5xx atau timeout
      if (status == null || status >= 500) {
        try {
          return await _callModel(
            model: _fallbackModel,
            systemPrompt: systemPrompt,
            userMessage: userMessage,
            maxTokens: maxTokens,
            jsonMode: jsonMode,
          );
        } on DioException catch (e2) {
          final body = e2.response?.data?.toString() ?? '';
          throw Exception('Gemma API error ${e2.response?.statusCode}: $body');
        }
      }
      final body = e.response?.data?.toString() ?? '';
      throw Exception('Gemma API error $status: $body');
    }
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
      jsonMode: true,
    );
    debugPrint('chatJson clean: $raw');
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
