import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chat_provider.dart';
import '../../providers/ui_provider.dart';
import '../../providers/role_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/chat_message.dart';
import '../../models/role_definition.dart';
import '../../services/llm_service.dart';

/// Role chips shown above the input bar for quick @mentions.
class InputBar extends ConsumerStatefulWidget {
  const InputBar({super.key});

  @override
  ConsumerState<InputBar> createState() => _InputBarState();
}

class _InputBarState extends ConsumerState<InputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

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

    final chatNotifier = ref.read(chatProvider.notifier);

    // Check if this is about role creation
    if (!chatNotifier.state.roleCreationMode && LlmService.isRoleCreationIntent(text)) {
      _startRoleCreation(text);
      return;
    }

    _sendNormalMessage(text);
  }

  void _startRoleCreation(String text) {
    final notifier = ref.read(chatProvider.notifier);

    notifier.appendMessage(
      ChatMessage(id: _uuid(), role: 'user', content: text),
    );
    notifier.setInput('');
    notifier.setSending(true);
    notifier.setRoleCreationMode(true);
    _controller.clear();

    _callRoleLlm();
  }

  void _sendNormalMessage(String text) {
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

    _callNormalLlm();
  }

  Future<void> _callRoleLlm() async {
    final notifier = ref.read(chatProvider.notifier);

    try {
      final history = ref.read(chatProvider).messages;
      final response = await LlmService.sendRoleCreationMessage(
        history: history,
        message: '',
      );

      if (!mounted) return;

      if (response.isError) {
        notifier.appendMessage(
          ChatMessage(
            id: _uuid(), role: 'assistant', content: response.content,
          ),
        );
        notifier.setRoleCreationMode(false);
      } else {
        // Check if the response contains a role definition
        final role = LlmService.extractRoleFromResponse(response.content);
        if (role != null) {
          // Role created! Add it to the role provider
          ref.read(roleProvider.notifier).addRole(role);
          notifier.appendMessage(
            ChatMessage(
              id: _uuid(), role: 'assistant',
              content: '**🎉 New role created: ${role.name}**\n\n'
                  'You can now use `@${role.mention}` to invoke this role.\n\n'
                  '_${role.description}_\n\n'
                  'Capabilities: ${role.capabilities.join(", ")}',
              pupKey: 'alpha', pupName: 'Alpha',
            ),
          );
          notifier.setRoleCreationMode(false);
        } else {
          // Still gathering info — show the response normally
          notifier.appendMessage(
            ChatMessage(
              id: _uuid(), role: 'assistant', content: response.content,
              pupKey: 'alpha', pupName: 'Alpha',
            ),
          );
        }
      }

      notifier.resetStreaming();
      notifier.setSending(false);
    } catch (e) {
      if (!mounted) return;
      notifier.appendMessage(
        ChatMessage(
          id: _uuid(), role: 'assistant', content: 'Error: $e',
        ),
      );
      notifier.resetStreaming();
      notifier.setSending(false);
      notifier.setRoleCreationMode(false);
    }
  }

  Future<void> _callNormalLlm() async {
    final notifier = ref.read(chatProvider.notifier);

    try {
      final history = ref.read(chatProvider).messages;
      final response = await LlmService.sendMessage(
        history: history,
        message: '',
      );

      if (!mounted) return;

      if (response.isError) {
        notifier.appendMessage(
          ChatMessage(
            id: _uuid(), role: 'assistant', content: response.content,
            pupKey: ref.read(uiProvider).selectedPupKey, pupName: 'Alpha',
          ),
        );
      } else {
        final fullContent = response.content;
        notifier.setStreamingContent(fullContent);
        notifier.appendMessage(
          ChatMessage(
            id: _uuid(), role: 'assistant', content: fullContent,
            pupKey: ref.read(uiProvider).selectedPupKey, pupName: 'Alpha',
          ),
        );
      }

      notifier.resetStreaming();
      notifier.setSending(false);
    } catch (e) {
      if (!mounted) return;
      notifier.appendMessage(
        ChatMessage(
          id: _uuid(), role: 'assistant', content: 'Error: $e',
          pupKey: ref.read(uiProvider).selectedPupKey, pupName: 'Alpha',
        ),
      );
      notifier.resetStreaming();
      notifier.setSending(false);
    }
  }

  void _onStop() {
    ref.read(chatProvider.notifier).resetStreaming();
    ref.read(chatProvider.notifier).setSending(false);
    ref.read(chatProvider.notifier).setRoleCreationMode(false);
  }

  void _insertMention(String mention) {
    final text = _controller.text;
    final pos = _controller.selection.isValid ? _controller.selection.baseOffset : text.length;
    final mentionStr = '@$mention ';
    final newText = text.substring(0, pos) + mentionStr + text.substring(pos);
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(offset: (pos + mentionStr.length).clamp(0, newText.length));
    ref.read(chatProvider.notifier).setInput(newText);
    _focusNode.requestFocus();
  }

  String _uuid() => DateTime.now().millisecondsSinceEpoch.toString();

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final roles = ref.watch(roleProvider);
    final colors = Theme.of(context).extension<OpenPupColors>()!;
    final sending = chatState.sending;
    final roleCreation = chatState.roleCreationMode;

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundPrimary,
        border: Border(top: BorderSide(color: colors.borderTertiary!, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Role chips (built-in + custom)
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: roles.length + 1, // +1 for the create button
              separatorBuilder: (_, __) => const SizedBox(width: 4),
              itemBuilder: (context, index) {
                if (index == roles.length) {
                  // "Create Role" button
                  return GestureDetector(
                    onTap: () {
                      _controller.text = 'create a new role';
                      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
                      _focusNode.requestFocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.accent!.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.accent!.withOpacity(0.3), width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 12, color: colors.accent),
                          const SizedBox(width: 3),
                          Text(
                            'Create',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: colors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final role = roles[index];
                final isActive = false;
                return GestureDetector(
                  onTap: () => _insertMention(role.mention),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: role.isBuiltIn ? colors.backgroundSecondary : colors.accent!.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive ? colors.accent! : colors.borderTertiary!,
                        width: isActive ? 1 : 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(
                            color: _chipColor(index).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            role.name.substring(0, 3).toUpperCase(),
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: _chipColor(index),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          role.name,
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

          // Role creation indicator
          if (roleCreation)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              color: colors.accent!.withOpacity(0.08),
              child: Row(
                children: [
                  SizedBox(
                    width: 12, height: 12,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: colors.accent),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Creating role... answer the questions below',
                    style: TextStyle(fontSize: 11, color: colors.accent),
                  ),
                ],
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
                      onSubmitted: (_) => _onSend(),
                      decoration: InputDecoration(
                        hintText: roleCreation ? 'Answer the questions to create your role...' : 'Message Alpha...',
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
                    : _SendButton(colors: colors, enabled: _controller.text.trim().isNotEmpty, onTap: _onSend),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _chipColor(int index) {
    const _colors = [0x1D9E75, 0xBA7517, 0x378ADD, 0xE55555, 0x8B5CF6, 0xEC4899, 0x14B8A6, 0xF97316, 0x06B6D4, 0x84CC16];
    return Color(_colors[index % _colors.length]);
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
          color: enabled ? colors.textPrimary! : colors.textPrimary!.withOpacity(0.25),
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
          color: colors.backgroundSecondary!,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.stop, size: 16),
      ),
    );
  }
}
