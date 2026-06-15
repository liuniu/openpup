import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/pup_config.dart';
import '../theme/app_theme.dart';
import '../utils/pup_visuals.dart';
import 'markdown_renderer.dart';
import 'activity_indicator.dart';

/// Renders a single chat message — replaces the message rendering in App.tsx.
///
/// Two modes:
/// - `user` bubble: right-aligned, compact, info-colored background
/// - `assistant` bubble: left-aligned, bordered, with pup tag + left accent
/// - `streaming` mode: live view of tokens + activity steps
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isStreaming;
  final String? streamingContent;
  final String? streamingReasoning;
  final List<ActivityStep>? streamingSteps;
  final bool isNew;

  const MessageBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
    this.streamingContent,
    this.streamingReasoning,
    this.streamingSteps,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    if (message.role == 'user') {
      return _buildUserBubble(context);
    }
    return _buildAssistantBubble(context);
  }

  // ── User bubble (right-aligned) ──────────────────────────────────────────
  Widget _buildUserBubble(BuildContext context) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: const Color(0xFF1D9E75).withOpacity(0.12),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            fontSize: 13,
            height: 1.6,
            color: colors.textPrimary,
          ),
        ),
      ),
    );
  }

  // ── Assistant bubble (left-aligned) ──────────────────────────────────────
  Widget _buildAssistantBubble(BuildContext context) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;
    final pupKey = message.pupKey ?? 'alpha';
    final pupilName = message.pupName ?? 'Alpha';
    final accent = pupAccentColor(pupKey);
    final tagStyle = pupTagStyle(pupKey);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pup name tag
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(
                color: tagStyle.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                pupilName,
                style: TextStyle(
                  fontSize: 10,
                  color: tagStyle.text,
                ),
              ),
            ),

            // Message body
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: colors.backgroundPrimary,
                border: Border.all(color: colors.borderTertiary!, width: 0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Streaming activity steps
                  if (isStreaming &&
                      streamingSteps != null &&
                      streamingSteps!.isNotEmpty)
                    ActivityIndicator(
                      steps: streamingSteps!,
                      showReasoning: streamingReasoning != null,
                      reasoningContent: streamingReasoning ?? '',
                    ),

                  // Streaming reasoning content
                  if (isStreaming &&
                      streamingReasoning != null &&
                      streamingReasoning!.isNotEmpty &&
                      (streamingSteps == null || streamingSteps!.isEmpty))
                    Container(
                      constraints: const BoxConstraints(maxHeight: 80),
                      margin: const EdgeInsets.only(bottom: 6),
                      child: SingleChildScrollView(
                        child: Text(
                          streamingReasoning!,
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: colors.textTertiary,
                          ),
                        ),
                      ),
                    ),

                  // Content (streaming or complete)
                  if (isStreaming && streamingContent != null)
                    AppMarkdownRenderer(
                      data: streamingContent!,
                    )
                  else if (!isStreaming)
                    AppMarkdownRenderer(
                      data: message.content,
                    )
                  else
                    _buildThinkingIndicator(colors),
                ],
              ),
            ),

            // Message actions (copy button, etc.)
            if (!isStreaming)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: _MessageActions(
                  content: message.content,
                  colors: colors,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThinkingIndicator(OpenPupColors colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.accent,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Thinking…',
          style: TextStyle(
            fontSize: 12,
            color: colors.textTertiary,
          ),
        ),
      ],
    );
  }
}

// ── Message actions (copy button) ────────────────────────────────────────────
// Replaces MessageActions.tsx — simplified to copy-only for now.

class _MessageActions extends StatelessWidget {
  final String content;
  final OpenPupColors colors;

  const _MessageActions({required this.content, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionBtn(
          icon: Icons.copy,
          tooltip: 'Copy',
          color: colors.textTertiary!,
          onTap: () {
            // TODO: clipboard copy
          },
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 12, color: color),
        ),
      ),
    );
  }
}
