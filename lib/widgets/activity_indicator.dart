import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../theme/app_theme.dart';

/// Activity step indicators — replaces the streaming step display in App.tsx.
///
/// Shows: routing → skill → shell → … activity icons with labels.
class ActivityIndicator extends StatelessWidget {
  final List<ActivityStep> steps;
  final bool showReasoning;
  final String reasoningContent;

  const ActivityIndicator({
    super.key,
    required this.steps,
    this.showReasoning = false,
    this.reasoningContent = '',
  });

  static const Map<String, String> _icons = {
    'routing': '→',
    'skill': '⚡',
    'shell': '\$',
    'file_read': '📄',
    'file_write': '✏️',
    'http': '🌐',
    'memory': '🧠',
    'task': '✓',
    'mcp': '🔌',
    'tool_call': '⚙',
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Activity steps
        if (steps.isNotEmpty)
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final isLast = i == steps.length - 1;
            final icon = _icons[step.kind] ?? '⚙';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    icon,
                    style: TextStyle(
                      fontSize: 11,
                      color: isLast
                          ? colors.textSecondary
                          : colors.textTertiary?.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      step.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: isLast
                            ? colors.textSecondary
                            : colors.textTertiary?.withOpacity(0.3),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

        // Reasoning tokens
        if (showReasoning && reasoningContent.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 80),
            child: SingleChildScrollView(
              child: Text(
                reasoningContent,
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: colors.textTertiary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
