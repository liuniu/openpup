import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chat_provider.dart';
import '../../providers/ui_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/chat_message.dart';
import '../../services/llm_service.dart';

/// Role chips shown above the input bar for quick @mentions.
const List<_RoleChipData> _roleChips = [
  _RoleChipData(emoji: '\u{1F469}\u{200D}\u{1F4BB}', label: 'Dev', mention: 'dev'),
  _RoleChipData(emoji: '\u{270D}\u{FE0F}', label: 'Writer', mention: 'writer'),
  _RoleChipData(emoji: '\u{2699}\u{FE0F}', label: 'Ops', mention: 'ops'),
  _RoleChipData(emoji: '\u{1F50D}', label: 'Research', mention: 'research'),
  _RoleChipData(emoji: '\u{1F4CA}', label: 'Data', mention: 'data'),
  _RoleChipData(emoji: '\u{1F3A8}', label: 'Design', mention: 'design'),
  _RoleChipData(emoji: '\u{1F4AC}', label: 'Coach', mention: 'coach'),
];

class _RoleChipData {
  final String emoji;
  final String label;
  final String mention;
  const _RoleChipData({
    required this.emoji,
    required this.label,
    required this.mention,
  });
}

/// Chat input bar with role chips and text input.
class InputBar extends ConsumerStatefulWidget {
  const InputBar({super.key});

  @override
  ConsumerState<InputBar> createState() => _InputBarState();
}

class _InputBarState extends ConsumerState<InputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _imeComposing = false;

  @override
  void initState() {
    super.initState();
    final input = ref.read(chatProvider).input;
    if (input.isNotEmpty) {
      _controller.text = input;
      _controller.selection = TextSelection.collapsed(offset: input.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final notifier = ref.read(chatProvider.notifier);

    notifier.appendMessage(
      ChatMessage(id: _uuid(), role: 'user', content: text),
    );
    notifier.setInput('');
    notifier.setStreamingPup(
      StreamingPupState(
        key: ref.read(uiProvider).selectedPupKey,
        name: 'Alpha',
      ),
    );
    notifier.setSending(true);
    _controller.clear();

    _callLlm();
  }

  Future<void> _callLlm() async {
    final notifier = ref.read(chatProvider.notifier);

    try {
      final history = notifier.state.messages;

      final response = await LlmService.sendMessage(
        history: history,
        message: '',
      );

      if (!mounted) return;

      if (response.isError) {
        notifier.appendMessage(
          ChatMessage(
            id: _uuid(),
            role: 'assistant',
            content: response.content,
            pupKey: ref.read(uiProvider).selectedPupKey,
            pupName: 'Alpha',
          ),
        );
      } else {
        final fullContent = response.content;
        for (int i = 1; i <= fullContent.length; i++) {
          if (!mounted) return;
          notifier.setStreamingContent(fullContent.substring(0, i));
          await Future.delayed(const Duration(milliseconds: 2));
        }

        notifier.appendMessage(
          ChatMessage(
            id: _uuid(),
            role: 'assistant',
            content: fullContent,
            pupKey: ref.read(uiProvider).selectedPupKey,
            pupName: 'Alpha',
          ),
        );
      }

      notifier.resetStreaming();
      notifier.setSending(false);
    } catch (e) {
      if (!mounted) return;
      notifier.appendMessage(
        ChatMessage(
          id: _uuid(),
          role: 'assistant',
          content: 'Error: $e',
          pupKey: ref.read(uiProvider).selectedPupKey,
          pupName: 'Alpha',
        ),
      );
      notifier.resetStreaming();
      notifier.setSending(false);
    }
  }

  void _onStop() {
    ref.read(chatProvider.notifier).resetStreaming();
    ref.read(chatProvider.notifier).setSending(false);
  }

  void _insertMention(String mention) {
    final text = _controller.text;
    final pos = _controller.selection.baseOffset;
    final mentionStr = '@$mention ';
    final newText = text.substring(0, pos) + mentionStr + text.substring(pos);
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(offset: pos + mentionStr.length);
    ref.read(chatProvider.notifier).setInput(newText);
    _focusNode.requestFocus();
  }

  String _uuid() => DateTime.now().millisecondsSinceEpoch.toString();

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final colors = Theme.of(context).extension<OpenPupColors>()!;
    final sending = chatState.sending;

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundPrimary,
        border: Border(
          top: BorderSide(color: colors.borderTertiary!, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Role chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: _roleChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final role = _roleChips[index];
                final isActive = _controller.text.contains('@${role.mention}');

                return GestureDetector(
                  onTap: () => _insertMention(role.mention),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? colors.accent!.withOpacity(0.12)
                          : colors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isActive ? colors.accent! : colors.borderTertiary!,
                        width: isActive ? 1 : 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(role.emoji, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          role.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive ? colors.accent : colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Input row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 160),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.borderSecondary!, width: 0.5),
                      color: colors.backgroundPrimary,
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      onChanged: (value) => ref.read(chatProvider.notifier).setInput(value),
                      onSubmitted: (_) {
                        if (!_imeComposing) _onSend();
                      },
                      decoration: InputDecoration(
                        hintText: 'Message Alpha...',
                        hintStyle: TextStyle(fontSize: 13, color: colors.textTertiary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(10),
                        isCollapsed: true,
                      ),
                      style: TextStyle(fontSize: 13, color: colors.textPrimary, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                sending
                    ? _StopButton(colors: colors, onTap: _onStop)
                    : _SendButton(
                        colors: colors,
                        enabled: _controller.text.trim().isNotEmpty,
                        onTap: _onSend,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final OpenPupColors colors;
  final bool enabled;
  final VoidCallback onTap;

  const _SendButton({required this.colors, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: enabled ? colors.textPrimary : colors.textPrimary?.withOpacity(0.25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.arrow_upward, size: 16, color: colors.backgroundPrimary),
      ),
    );
  }
}

class _StopButton extends StatelessWidget {
  final OpenPupColors colors;
  final VoidCallback onTap;

  const _StopButton({required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.stop, size: 16),
      ),
    );
  }
}
