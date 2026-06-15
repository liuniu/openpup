import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chat_provider.dart';
import '../../providers/ui_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/chat_message.dart';

/// Chat input bar — replaces the textarea + send/stop button in App.tsx.
///
/// Features:
/// - Multi-line textarea with auto-resize (max 160px)
/// - Send button (↑) when idle
/// - Stop button (■) during streaming
/// - IME composition detection for CJK Enter handling
/// - @mention insertion from pup selection
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
    // Sync the provider's input state to the controller
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

    ref.read(chatProvider.notifier).appendMessage(
          ChatMessage(id: _uuid(), role: 'user', content: text),
        );
    ref.read(chatProvider.notifier).setInput('');
    ref.read(chatProvider.notifier).setStreamingPup(
          StreamingPupState(
            key: ref.read(uiProvider).selectedPupKey,
            name: 'Alpha',
          ),
        );
    ref.read(chatProvider.notifier).setSending(true);
    _controller.clear();

    // TODO: call OpenPupBridge.sendMessage()
  }

  void _onStop() {
    ref.read(chatProvider.notifier).resetStreaming();
    ref.read(chatProvider.notifier).setSending(false);
    // TODO: call OpenPupBridge.abortMessage()
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final colors = Theme.of(context).extension<OpenPupColors>()!;
    final uiState = ref.watch(uiProvider);
    final sending = chatState.sending;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: colors.backgroundPrimary,
        border: Border(
          top: BorderSide(color: colors.borderTertiary!, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // @mention insert button
          if (uiState.selectedPupKey != 'alpha')
            GestureDetector(
              onTap: () => _insertMention(uiState.selectedPupKey),
              child: Container(
                margin: const EdgeInsets.only(bottom: 2, right: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '@${uiState.selectedPupKey}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // Text input
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
                onChanged: (value) {
                  ref.read(chatProvider.notifier).setInput(value);
                },
                onKey: (node, event) {
                  // Enter to send (Shift+Enter for newline)
                  if (event is! KeyDownEvent) return KeyEventResult.ignored;
                  if (event.logicalKey != LogicalKeyboardKey.enter) {
                    return KeyEventResult.ignored;
                  }
                  // IME composition: let the Enter through to commit the IME text
                  if (_imeComposing) return KeyEventResult.ignored;
                  _onSend();
                  return KeyEventResult.handled;
                },
                decoration: InputDecoration(
                  hintText: 'Message Alpha…',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: colors.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(10),
                  isCollapsed: true,
                ),
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Send / Stop button
          sending
              ? _StopButton(colors: colors, onTap: _onStop)
              : _SendButton(
                  colors: colors,
                  enabled: _controller.text.trim().isNotEmpty,
                  onTap: _onSend,
                ),
        ],
      ),
    );
  }

  void _insertMention(String pupKey) {
    final mention = '@$pupKey ';
    final text = _controller.text;
    final pos = _controller.selection.baseOffset;
    final newText = text.substring(0, pos) + mention + text.substring(pos);
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(offset: pos + mention.length);
    ref.read(chatProvider.notifier).setInput(newText);
    _focusNode.requestFocus();
  }

  String _uuid() => DateTime.now().millisecondsSinceEpoch.toString();
}

// ── Send button ──────────────────────────────────────────────────────────────

class _SendButton extends StatelessWidget {
  final OpenPupColors colors;
  final bool enabled;
  final VoidCallback onTap;

  const _SendButton({
    required this.colors,
    required this.enabled,
    required this.onTap,
  });

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
        child: Icon(
          Icons.arrow_upward,
          size: 16,
          color: colors.backgroundPrimary,
        ),
      ),
    );
  }
}

// ── Stop button ─────────────────────────────────────────────────────────────

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

// Needed for ChatMessage type