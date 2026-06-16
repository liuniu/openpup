import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/llm_config.dart';
import '../models/chat_message.dart';

/// Service for calling the configured LLM API (OpenAI-compatible).
class LlmService {
  LlmService._();

  static Future<LlmResponse> sendMessage({
    required List<ChatMessage> history,
    required String message,
    String? systemPrompt,
  }) async {
    final messages = <Map<String, String>>[];

    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      messages.add({'role': 'system', 'content': systemPrompt});
    }

    // Use history as-is (message is already the last entry in history)
    for (final msg in history.reversed.take(20).toList().reversed) {
      messages.add({'role': msg.role, 'content': msg.content});
    }

    final body = jsonEncode({
      'model': DefaultLlmConfig.model,
      'messages': messages,
      'stream': false,
      'max_tokens': 4096,
    });

    final url = '${DefaultLlmConfig.baseUrl}/chat/completions';
    final auth = 'Bearer ${DefaultLlmConfig.apiKey}';

    final client = http.Client();
    try {
      final response = await client
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': auth,
            },
            body: body,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>;
        if (choices.isNotEmpty) {
          final choice = choices[0] as Map<String, dynamic>;
          final content = choice['message']['content'] as String? ?? '';
          final usage = data['usage'] as Map<String, dynamic>?;
          return LlmResponse(
            content: content,
            promptTokens: usage?['prompt_tokens'] as int? ?? 0,
            completionTokens: usage?['completion_tokens'] as int? ?? 0,
          );
        }
        return LlmResponse(content: '', promptTokens: 0, completionTokens: 0);
      } else {
        final errBody = response.body.length > 500
            ? '${response.body.substring(0, 500)}...'
            : response.body;
        return LlmResponse(
          content: 'API Error (${response.statusCode}): $errBody',
          promptTokens: 0, completionTokens: 0, isError: true,
        );
      }
    } on SocketException catch (e) {
      return LlmResponse(
        content: 'Network error: Cannot reach ${DefaultLlmConfig.baseUrl}\n$e',
        promptTokens: 0, completionTokens: 0, isError: true,
      );
    } on http.ClientException catch (e) {
      return LlmResponse(
        content: 'Request failed: $e',
        promptTokens: 0, completionTokens: 0, isError: true,
      );
    } finally {
      client.close();
    }
  }
}

class LlmResponse {
  final String content;
  final int promptTokens;
  final int completionTokens;
  final bool isError;

  const LlmResponse({
    required this.content,
    required this.promptTokens,
    required this.completionTokens,
    this.isError = false,
  });
}
