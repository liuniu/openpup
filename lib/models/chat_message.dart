/// Chat message — maps to stores/chatStore.ts ChatMessage.
class ChatMessage {
  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final String? pupKey;
  final String? pupName;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.pupKey,
    this.pupName,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        role: json['role'] as String,
        content: json['content'] as String,
        pupKey: json['pup_key'] as String?,
        pupName: json['pup_name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'content': content,
        'pup_key': pupKey,
        'pup_name': pupName,
      };
}

/// Streaming pup state.
class StreamingPupState {
  final String key;
  final String name;

  const StreamingPupState({required this.key, required this.name});
}

/// Activity step during streaming.
class ActivityStep {
  final String kind;
  final String label;

  const ActivityStep({required this.kind, required this.label});

  factory ActivityStep.fromJson(Map<String, dynamic> json) => ActivityStep(
        kind: json['kind'] as String,
        label: json['label'] as String,
      );
}

/// Token usage summary.
class TokenUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  const TokenUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory TokenUsage.fromJson(Map<String, dynamic> json) => TokenUsage(
        promptTokens: json['prompt_tokens'] as int,
        completionTokens: json['completion_tokens'] as int,
        totalTokens: json['total_tokens'] as int,
      );
}
