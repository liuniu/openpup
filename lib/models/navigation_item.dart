/// Permission request — maps to components/PermissionDialog.tsx PermissionRequest.
class PermissionRequest {
  final String requestId;
  final String skillName;
  final String description;
  final String riskLevel; // 'high' | 'medium' | 'low'

  const PermissionRequest({
    required this.requestId,
    this.skillName = '',
    this.description = '',
    this.riskLevel = 'medium',
  });

  factory PermissionRequest.fromJson(Map<String, dynamic> json) =>
      PermissionRequest(
        requestId: json['request_id'] as String,
        skillName: json['skill_name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        riskLevel: json['risk_level'] as String? ?? 'medium',
      );
}

/// Navigation item type — maps to stores/uiStore.ts NavItem.
enum NavItem {
  chat,
  channel,
  groups,
  finance,
  memories,
  timeline,
  skills,
  pups,
  tasks,
  mcp,
  bridge,
  settings,
  knowledge;

  String get labelKey {
    switch (this) {
      case NavItem.chat:
        return 'nav_chat';
      case NavItem.channel:
        return 'nav_pack_channel';
      case NavItem.groups:
        return 'nav_groups';
      case NavItem.finance:
        return 'nav_finance';
      case NavItem.timeline:
        return 'nav_timeline';
      case NavItem.memories:
        return 'nav_memories';
      case NavItem.knowledge:
        return 'nav_knowledge';
      case NavItem.tasks:
        return 'nav_tasks';
      case NavItem.pups:
        return 'nav_pups';
      case NavItem.skills:
        return 'nav_skills';
      case NavItem.mcp:
        return 'nav_mcp';
      case NavItem.bridge:
        return 'nav_bridge';
      case NavItem.settings:
        return 'nav_settings';
    }
  }
}
