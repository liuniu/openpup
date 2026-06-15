import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'input_bar.dart';
import '../../models/chat_message.dart';
import '../../models/pup_config.dart';
import '../../providers/chat_provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/message_bubble.dart';

/// Main chat screen — replaces the `activeNav === 'chat'` block in App.tsx.
///
/// Layout (top → bottom):
/// 1. Memory chips bar (recent context hints)
/// 2. Scrollable message list
/// 3. Input bar (fixed at bottom)
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    // If user scrolls up, disable auto-scroll; if at bottom, re-enable
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    _autoScroll = (maxScroll - currentScroll) < 50;
  }

  void _scrollToBottom() {
    if (_autoScroll && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final appState = ref.watch(appProvider);
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    // Auto-scroll when streaming or new messages
    _scrollToBottom();

    return Container(
      color: colors.backgroundPrimary,
      child: Column(
        children: [
          // ── Memory chips bar ─────────────────────────────────────────
          if (appState.memoryChips.isNotEmpty)
            _MemoryChipsBar(
              chips: appState.memoryChips,
              colors: colors,
            ),

          // ── Message list ─────────────────────────────────────────────
          Expanded(
            child: appState.onboardingDone == true &&
                    (chatState.messages.isNotEmpty || chatState.sending)
                ? ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    itemCount: chatState.messages.length + (chatState.sending ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Streaming bubble shown after all complete messages
                      if (index == chatState.messages.length && chatState.sending) {
                        return MessageBubble(
                          message: ChatMessage(
                            id: 'streaming',
                            role: 'assistant',
                            content: chatState.streamingContent,
                            pupKey: chatState.streamingPup?.key ?? 'alpha',
                            pupName: chatState.streamingPup?.name ?? 'Alpha',
                          ),
                          isStreaming: true,
                          streamingContent: chatState.streamingContent,
                          streamingReasoning: chatState.streamingReasoningContent,
                          streamingSteps: chatState.streamingSteps,
                          isNew: true,
                        );
                      }

                      final msg = chatState.messages[index];
                      return MessageBubble(
                        message: msg,
                        isNew: false,
                      );
                    },
                  )
                : _buildEmptyState(colors),
          ),

          // ── Input bar ────────────────────────────────────────────────
          const InputBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(OpenPupColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 36, color: colors.textTertiary),
          const SizedBox(height: 8),
          Text(
            'No messages yet. Start a conversation!',
            style: TextStyle(fontSize: 13, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}

// ── Memory chips bar ─────────────────────────────────────────────────────────

class _MemoryChipsBar extends StatelessWidget {
  final List<MemoryChip> chips;
  final OpenPupColors colors;

  const _MemoryChipsBar({required this.chips, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.borderTertiary!, width: 0.5),
        ),
      ),
      child: Row(
        children: chips.take(5).map((chip) {
          return Container(
            constraints: const BoxConstraints(maxWidth: 180),
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.borderTertiary!, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1D9E75),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    chip.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
