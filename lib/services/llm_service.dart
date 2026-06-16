import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/llm_config.dart';
import '../models/chat_message.dart';
import '../models/role_definition.dart';

/// Service for calling the configured LLM API (OpenAI-compatible).
class LlmService {
  LlmService._();

  /// System prompt for role creation mode.
  static const String _roleCreatorSystemPrompt = '''
You are a "Role Creator" assistant. Your job is to help the user define a new AI agent role.

When the user wants to create a new role, follow this process:

1. **Understand the need**: Ask the user what kind of role they want to create — what domain, purpose, or function.
2. **Gather details**: Ask targeted questions to collect:
   - Role name (short, descriptive)
   - Mention handle (a short keyword for @mention, e.g. "translator")
   - Description (1-2 sentences)
   - Core capabilities (list of 3-5 key abilities)
   - System prompt (detailed instructions for the AI when acting as this role)
3. **Confirm**: Once you have enough information, present the role definition to the user for confirmation.
4. **Finalize**: When the user confirms, output the role definition in EXACTLY this JSON format on its own line:

[ROLE_CREATED]
{
  "name": "Role Name",
  "mention": "rolename",
  "description": "Short description",
  "system_prompt": "Detailed system prompt for this role",
  "capabilities": ["Capability 1", "Capability 2", "Capability 3"]
}
[/ROLE_CREATED]

Important rules:
- Be conversational and friendly
- Ask ONE question at a time
- Keep gathering info until you have name, mention, description, capabilities, and system prompt
- Do NOT output the [ROLE_CREATED] block until the user confirms
- If the user changes their mind or cancels, acknowledge and stop the role creation process
''';

  /// Keywords that suggest role creation intent.
  static const List<String> _roleCreationKeywords = [
    'create a role', 'new role', 'add a role', 'create role',
    'new character', 'create an agent', 'new agent',
    '添加角色', '创建角色', '新建角色', '新角色',
    'create a new assistant', 'define a role',
  ];

  /// Check if a message suggests role creation intent.
  static bool isRoleCreationIntent(String message) {
    final lower = message.toLowerCase();
    return _roleCreationKeywords.any((kw) => lower.contains(kw));
  }

  /// Send a message in role-creation mode.
  static Future<LlmResponse> sendRoleCreationMessage({
    required List<ChatMessage> history,
    required String message,
  }) async {
    return sendMessage(
      history: history,
      message: message,
      systemPrompt: _roleCreatorSystemPrompt,
    );
  }

  /// Try to extract a RoleDefinition from an LLM response.
  /// Returns null if the response doesn't contain a [ROLE_CREATED] block.
  static RoleDefinition? extractRoleFromResponse(String content) {
    final startMarker = '[ROLE_CREATED]';
    final endMarker = '[/ROLE_CREATED]';

    final startIdx = content.indexOf(startMarker);
    if (startIdx == -1) return null;

    final jsonStart = startIdx + startMarker.length;
    final endIdx = content.indexOf(endMarker, jsonStart);
    if (endIdx == -1) return null;

    final jsonStr = content.substring(jsonStart, endIdx).trim();
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return RoleDefinition(
        id: (json['mention'] as String?)?.toLowerCase() ?? '',
        name: json['name'] as String? ?? '',
        mention: (json['mention'] as String?)?.toLowerCase() ?? '',
        description: json['description'] as String? ?? '',
        systemPrompt: json['system_prompt'] as String? ?? '',
        capabilities: (json['capabilities'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? [],
        createdAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Main LLM call.
  static Future<LlmResponse> sendMessage({
    required List<ChatMessage> history,
    required String message,
    String? systemPrompt,
  }) async {
    final messages = <Map<String, String>>[];

    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      messages.add({'role': 'system', 'content': systemPrompt});
    }

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
