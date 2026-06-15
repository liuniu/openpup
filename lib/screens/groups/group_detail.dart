import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/conversation_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/markdown_renderer.dart';

/// Conversation space detail — shows members + message history.
class GroupDetailScreen extends ConsumerStatefulWidget {
  final String spaceId;

  const GroupDetailScreen({super.key, required this.spaceId});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  List<ConversationMessage> _messages = [];
  List<ConversationMember> _members = [];
  bool _loading = true;
  bool _showMembers = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return Container(
      color: colors.backgroundPrimary,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header
                _buildHeader(colors),
                Expanded(child: _buildContent(colors)),
                // Input
                _buildInput(colors),
              ],
            ),
    );
  }

  Widget _buildHeader(OpenPupColors colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.borderTertiary!, width: 0.5)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, size: 18),
            onPressed: () => Navigator.of(context).maybePop(),
            color: colors.textSecondary,
          ),
          Expanded(
            child: Text('Space', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary)),
          ),
          // Members toggle
          GestureDetector(
            onTap: () => setState(() => _showMembers = !_showMembers),
            child: Row(
              children: [
                Icon(Icons.people, size: 16, color: _showMembers ? colors.accent : colors.textTertiary),
                const SizedBox(width: 4),
                Text('${_members.length}',
                    style: TextStyle(fontSize: 12, color: _showMembers ? colors.accent : colors.textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(OpenPupColors colors) {
    return Row(
      children: [
        // Messages
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 28, color: colors.textTertiary),
                      const SizedBox(height: 8),
                      Text('No messages in this space',
                          style: TextStyle(fontSize: 12, color: colors.textTertiary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (_, i) {
                    final msg = _messages[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(msg.senderName,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                                const Spacer(),
                                Text(_fmtTime(msg.createdAt),
                                    style: TextStyle(fontSize: 10, color: colors.textTertiary)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            AppMarkdownRenderer(data: msg.content),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        // Members panel
        if (_showMembers)
          Container(
            width: 180,
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: colors.borderTertiary!, width: 0.5)),
              color: colors.backgroundPrimary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Members', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _members.length,
                    itemBuilder: (_, i) {
                      final m = _members[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 6, height: 6,
                              decoration: BoxDecoration(
                                color: m.online ? colors.textSuccess : colors.textTertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(m.displayName, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                            ),
                            if (m.role == 'owner')
                              Icon(Icons.star, size: 10, color: colors.textWarning),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInput(OpenPupColors colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.borderTertiary!, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.borderSecondary!, width: 0.5),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Message…',
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                style: TextStyle(fontSize: 12, color: colors.textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.arrow_upward, size: 14, color: colors.backgroundPrimary),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtTime(int ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
