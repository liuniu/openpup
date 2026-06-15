/// Channel data types — maps to types/channel.ts.

class ChannelRecord {
  final String id;
  final String taskId;
  final String title;
  final String status;
  final int createdAt;
  final int? completedAt;
  final int updatedAt;
  final int? currentLayer;
  final int reviewRound;
  final bool awaitingUser;
  final String? blockedReason;
  final List<String> members;

  const ChannelRecord({
    required this.id,
    required this.taskId,
    required this.title,
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.updatedAt,
    this.currentLayer,
    this.reviewRound = 0,
    this.awaitingUser = false,
    this.blockedReason,
    this.members = const [],
  });

  factory ChannelRecord.fromJson(Map<String, dynamic> json) => ChannelRecord(
        id: json['id'] as String,
        taskId: json['task_id'] as String,
        title: json['title'] as String,
        status: json['status'] as String,
        createdAt: json['created_at'] as int,
        completedAt: json['completed_at'] as int?,
        updatedAt: json['updated_at'] as int,
        currentLayer: json['current_layer'] as int?,
        reviewRound: json['review_round'] as int? ?? 0,
        awaitingUser: json['awaiting_user'] as bool? ?? false,
        blockedReason: json['blocked_reason'] as String?,
        members: (json['members'] as List<dynamic>?)?.cast<String>() ?? [],
      );

  String get statusLabel {
    switch (status) {
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'awaiting_review':
        return 'Review';
      default:
        return status;
    }
  }
}

class ChannelMessageRecord {
  final String id;
  final String channelId;
  final String sender;
  final String content;
  final String msgType;
  final int timestamp;

  const ChannelMessageRecord({
    required this.id,
    required this.channelId,
    required this.sender,
    required this.content,
    this.msgType = 'text',
    required this.timestamp,
  });

  factory ChannelMessageRecord.fromJson(Map<String, dynamic> json) =>
      ChannelMessageRecord(
        id: json['id'] as String,
        channelId: json['channel_id'] as String,
        sender: json['sender'] as String,
        content: json['content'] as String,
        msgType: json['msg_type'] as String? ?? 'text',
        timestamp: json['timestamp'] as int,
      );
}

class DelegationPlan {
  final String channelId;
  final String channelTitle;
  final List<Subtask> subtasks;

  const DelegationPlan({
    required this.channelId,
    required this.channelTitle,
    this.subtasks = const [],
  });

  factory DelegationPlan.fromJson(Map<String, dynamic> json) => DelegationPlan(
        channelId: json['channel_id'] as String,
        channelTitle: json['channel_title'] as String,
        subtasks: (json['subtasks'] as List<dynamic>?)
                ?.map((s) => Subtask.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class Subtask {
  final String pup;
  final String description;
  final List<String> dependsOn;

  const Subtask({
    required this.pup,
    required this.description,
    this.dependsOn = const [],
  });

  factory Subtask.fromJson(Map<String, dynamic> json) => Subtask(
        pup: json['pup'] as String,
        description: json['description'] as String,
        dependsOn:
            (json['depends_on'] as List<dynamic>?)?.cast<String>() ?? [],
      );
}
