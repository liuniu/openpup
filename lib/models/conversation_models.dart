/// Conversation (group chat) data models — maps to GroupChat.tsx types.

class ConversationSpace {
  final String id;
  final String title;
  final String description;
  final String accent;
  final int memberCount;
  final int unread;
  final String routingMode;
  final List<TransportBinding> transports;

  const ConversationSpace({
    required this.id,
    required this.title,
    this.description = '',
    this.accent = '#378ADD',
    this.memberCount = 0,
    this.unread = 0,
    this.routingMode = 'auto',
    this.transports = const [],
  });

  factory ConversationSpace.fromJson(Map<String, dynamic> json) =>
      ConversationSpace(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        accent: json['accent'] as String? ?? '#378ADD',
        memberCount: json['member_count'] as int? ?? 0,
        unread: json['unread'] as int? ?? 0,
        routingMode: json['routing_mode'] as String? ?? 'auto',
        transports: (json['transports'] as List<dynamic>?)
                ?.map((t) => TransportBinding.fromJson(t as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class TransportBinding {
  final String kind;
  final String label;
  final String status;

  const TransportBinding({
    required this.kind,
    required this.label,
    this.status = 'active',
  });

  factory TransportBinding.fromJson(Map<String, dynamic> json) =>
      TransportBinding(
        kind: json['kind'] as String,
        label: json['label'] as String,
        status: json['status'] as String? ?? 'active',
      );
}

class ConversationMessage {
  final String id;
  final String conversationId;
  final String senderName;
  final String senderKind;
  final String content;
  final int createdAt;

  const ConversationMessage({
    required this.id,
    required this.conversationId,
    required this.senderName,
    this.senderKind = 'human',
    required this.content,
    required this.createdAt,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) =>
      ConversationMessage(
        id: json['id'] as String,
        conversationId: json['conversation_id'] as String,
        senderName: json['sender_name'] as String,
        senderKind: json['sender_kind'] as String? ?? 'human',
        content: json['content'] as String,
        createdAt: json['created_at'] as int,
      );
}

class ConversationMember {
  final String id;
  final String identityId;
  final String displayName;
  final String role;
  final bool online;

  const ConversationMember({
    required this.id,
    required this.identityId,
    required this.displayName,
    this.role = 'member',
    this.online = false,
  });

  factory ConversationMember.fromJson(Map<String, dynamic> json) =>
      ConversationMember(
        id: json['id'] as String,
        identityId: json['identity_id'] as String,
        displayName: json['display_name'] as String,
        role: json['role'] as String? ?? 'member',
        online: json['online'] as bool? ?? false,
      );
}
