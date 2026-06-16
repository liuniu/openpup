/// Defines a custom role (agent persona) that can be @mentioned in chat.
class RoleDefinition {
  final String id;
  final String name;
  final String mention; // short handle used after @
  final String description;
  final String systemPrompt;
  final List<String> capabilities;
  final bool isBuiltIn;
  final DateTime? createdAt;

  const RoleDefinition({
    required this.id,
    required this.name,
    required this.mention,
    required this.description,
    required this.systemPrompt,
    this.capabilities = const [],
    this.isBuiltIn = false,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'mention': mention,
    'description': description,
    'system_prompt': systemPrompt,
    'capabilities': capabilities,
    'is_builtin': isBuiltIn,
  };

  factory RoleDefinition.fromJson(Map<String, dynamic> json) => RoleDefinition(
    id: json['id'] as String? ?? json['mention'] as String,
    name: json['name'] as String,
    mention: json['mention'] as String,
    description: json['description'] as String? ?? '',
    systemPrompt: json['system_prompt'] as String? ?? '',
    capabilities: (json['capabilities'] as List<dynamic>?)?.cast<String>() ?? [],
    isBuiltIn: json['is_builtin'] as bool? ?? false,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null,
  );
}

/// Predefined built-in roles.
List<RoleDefinition> builtInRoles() => [
  RoleDefinition(
    id: 'dev',
    name: 'Dev',
    mention: 'dev',
    description: 'Software development expert',
    systemPrompt: 'You are a senior software engineer. Help with coding, architecture, debugging, and best practices.',
    capabilities: ['Code generation', 'Debugging', 'Architecture design', 'Code review'],
    isBuiltIn: true,
  ),
  RoleDefinition(
    id: 'writer',
    name: 'Writer',
    mention: 'writer',
    description: 'Professional writing and editing',
    systemPrompt: 'You are a professional writer and editor. Help with writing, editing, content strategy, and storytelling.',
    capabilities: ['Content creation', 'Editing', 'Proofreading', 'Style guide'],
    isBuiltIn: true,
  ),
  RoleDefinition(
    id: 'ops',
    name: 'Ops',
    mention: 'ops',
    description: 'DevOps and infrastructure specialist',
    systemPrompt: 'You are a DevOps engineer. Help with CI/CD, infrastructure, deployment, and monitoring.',
    capabilities: ['CI/CD', 'Infrastructure', 'Deployment', 'Monitoring'],
    isBuiltIn: true,
  ),
  RoleDefinition(
    id: 'research',
    name: 'Research',
    mention: 'research',
    description: 'Research and analysis expert',
    systemPrompt: 'You are a research analyst. Help with data analysis, literature review, and insight generation.',
    capabilities: ['Data analysis', 'Research', 'Report writing', 'Insights'],
    isBuiltIn: true,
  ),
  RoleDefinition(
    id: 'data',
    name: 'Data',
    mention: 'data',
    description: 'Data science and analytics specialist',
    systemPrompt: 'You are a data scientist. Help with data analysis, visualization, machine learning, and statistics.',
    capabilities: ['Data analysis', 'Visualization', 'ML models', 'Statistics'],
    isBuiltIn: true,
  ),
  RoleDefinition(
    id: 'design',
    name: 'Design',
    mention: 'design',
    description: 'UI/UX and visual design expert',
    systemPrompt: 'You are a UI/UX designer. Help with design systems, user experience, and visual design.',
    capabilities: ['UI design', 'UX research', 'Design systems', 'Prototyping'],
    isBuiltIn: true,
  ),
  RoleDefinition(
    id: 'coach',
    name: 'Coach',
    mention: 'coach',
    description: 'Personal and professional coach',
    systemPrompt: 'You are a personal coach. Help with goal setting, productivity, career development, and personal growth.',
    capabilities: ['Goal setting', 'Productivity', 'Career advice', 'Personal growth'],
    isBuiltIn: true,
  ),
];
