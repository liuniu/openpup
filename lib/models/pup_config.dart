/// Pup (agent) configuration — maps to stores/appStore.ts PupConfig.
class PupConfig {
  final String key;
  final String displayName;
  final String description;
  final bool enabled;
  final bool isCustom;

  const PupConfig({
    required this.key,
    required this.displayName,
    this.description = '',
    this.enabled = true,
    this.isCustom = false,
  });

  factory PupConfig.fromJson(Map<String, dynamic> json) => PupConfig(
        key: json['key'] as String,
        displayName: json['display_name'] as String? ?? json['key'] as String,
        description: json['description'] as String? ?? '',
        enabled: json['enabled'] as bool? ?? true,
        isCustom: json['is_custom'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'key': key,
        'display_name': displayName,
        'description': description,
        'enabled': enabled,
        'is_custom': isCustom,
      };
}

/// Memory chip (top memories) — maps to stores/appStore.ts MemoryChip.
class MemoryChip {
  final String content;
  final String memoryType;
  final double importance;

  const MemoryChip({
    required this.content,
    this.memoryType = 'fact',
    this.importance = 0.0,
  });

  factory MemoryChip.fromJson(Map<String, dynamic> json) => MemoryChip(
        content: json['content'] as String,
        memoryType: json['memory_type'] as String? ?? 'fact',
        importance: (json['importance'] as num?)?.toDouble() ?? 0.0,
      );
}

/// Context statistics — maps to stores/appStore.ts ContextStats.
class ContextStats {
  final String pupKey;
  final int messageCount;
  final int contextTokens;
  final int contextLimit;
  final CompressionStatus compressionStatus;

  const ContextStats({
    required this.pupKey,
    this.messageCount = 0,
    this.contextTokens = 0,
    this.contextLimit = 0,
    this.compressionStatus = const CompressionStatus(),
  });

  factory ContextStats.fromJson(Map<String, dynamic> json) => ContextStats(
        pupKey: json['pup_key'] as String,
        messageCount: json['message_count'] as int? ?? 0,
        contextTokens: json['context_tokens'] as int? ?? 0,
        contextLimit: json['context_limit'] as int? ?? 0,
        compressionStatus: json['compression_status'] != null
            ? CompressionStatus.fromJson(
                json['compression_status'] as Map<String, dynamic>)
            : const CompressionStatus(),
      );
}

class CompressionStatus {
  final bool isCompressed;
  final int lastCompressionRow;

  const CompressionStatus({
    this.isCompressed = false,
    this.lastCompressionRow = 0,
  });

  factory CompressionStatus.fromJson(Map<String, dynamic> json) =>
      CompressionStatus(
        isCompressed: json['is_compressed'] as bool? ?? false,
        lastCompressionRow: json['last_compression_row'] as int? ?? 0,
      );
}
