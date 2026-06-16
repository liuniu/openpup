import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'input_bar.dart';
import '../../models/chat_message.dart';
import '../../models/pup_config.dart';
import '../../providers/chat_provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/markdown_renderer.dart';

/// Main chat screen.
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

    _scrollToBottom();

    return Container(
      color: colors.backgroundPrimary,
      child: Column(
        children: [
          if (appState.memoryChips.isNotEmpty)
            _MemoryChipsBar(chips: appState.memoryChips, colors: colors),

          Expanded(
            child: (chatState.messages.isNotEmpty || chatState.sending)
                ? ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    itemCount: chatState.messages.length + (chatState.sending ? 1 : 0),
                    itemBuilder: (context, index) {
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
                      return MessageBubble(message: msg, isNew: false);
                    },
                  )
                : _buildWelcome(colors),
          ),

          const InputBar(),
        ],
      ),
    );
  }

  Widget _buildWelcome(OpenPupColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.accent!.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.pets, size: 30, color: colors.accent),
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome to openpup',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your AI companion is ready to help.',
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
          ),
          const SizedBox(height: 28),

          // Tips card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.borderTertiary!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 16, color: colors.accent),
                    const SizedBox(width: 6),
                    Text(
                      'Getting Started',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _TipItem(
                  icon: Icons.person_outline,
                  text: 'Tell me about yourself \u2014 your background, interests, and goals',
                  colors: colors,
                ),
                const SizedBox(height: 10),
                _TipItem(
                  icon: Icons.chat_bubble_outline,
                  text: 'Describe what you need help with \u2014 coding, writing, research, or daily tasks',
                  colors: colors,
                ),
                const SizedBox(height: 10),
                _TipItem(
                  icon: Icons.tune_outlined,
                  text: 'Let me know your preferences \u2014 how formal, how detailed, what tone you prefer',
                  colors: colors,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Text(
            'Type a message below to start chatting...',
            style: TextStyle(fontSize: 12, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final OpenPupColors colors;

  const _TipItem({
    required this.icon,
    required this.text,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: colors.accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.4),
          ),
        ),
      ],
    );
  }
}

// Memory chips bar
class _MemoryChipsBar extends StatelessWidget {
  final List<MemoryChip> chips;
  final OpenPupColors colors;

  const _MemoryChipsBar({required this.chips, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.borderTertiary!, width: 0.5)),
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
                  width: 5, height: 5,
                  decoration: const BoxDecoration(color: Color(0xFF1D9E75), shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    chip.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: colors.textSecondary),
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
