import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/conversation_models.dart';
import '../../theme/app_theme.dart';

/// Conversation space list — shows all groups with unread badges.
class GroupListScreen extends ConsumerStatefulWidget {
  final void Function(String spaceId)? onOpenSpace;

  const GroupListScreen({super.key, this.onOpenSpace});

  @override
  ConsumerState<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends ConsumerState<GroupListScreen> {
  List<ConversationSpace> _spaces = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    // TODO: load from rust bridge
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return Container(
      color: colors.backgroundPrimary,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text('Conversation Spaces',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.borderSecondary!, width: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('+ New', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('${_spaces.length} spaces',
                style: TextStyle(fontSize: 11, color: colors.textTertiary)),
          ),
          const SizedBox(height: 12),

          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _spaces.isEmpty
                    ? _buildEmpty(colors)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _spaces.length,
                        itemBuilder: (_, i) => _SpaceCard(
                          space: _spaces[i],
                          colors: colors,
                          onTap: () => widget.onOpenSpace?.call(_spaces[i].id),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(OpenPupColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.groups, size: 32, color: colors.textTertiary),
          const SizedBox(height: 8),
          Text('No conversation spaces', style: TextStyle(fontSize: 13, color: colors.textTertiary)),
        ],
      ),
    );
  }
}

class _SpaceCard extends StatelessWidget {
  final ConversationSpace space;
  final OpenPupColors colors;
  final VoidCallback onTap;

  const _SpaceCard({required this.space, required this.colors, required this.onTap});

  Color _parseAccent(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return const Color(0xFF378ADD);
  }

  @override
  Widget build(BuildContext context) {
    final accent = _parseAccent(space.accent);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.borderTertiary!, width: 0.5),
            ),
            child: Row(
              children: [
                // Accent bar
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(space.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                          if (space.unread > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${space.unread}',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      if (space.description.isNotEmpty)
                        Text(space.description, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: colors.textTertiary)),
                      Row(
                        children: [
                          Icon(Icons.people, size: 10, color: colors.textTertiary),
                          const SizedBox(width: 3),
                          Text('${space.memberCount}', style: TextStyle(fontSize: 10, color: colors.textTertiary)),
                          const SizedBox(width: 8),
                          // Transport badges
                          for (final t in space.transports)
                            Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: t.status == 'active'
                                    ? colors.accent!.withOpacity(0.1)
                                    : colors.backgroundTertiary?.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(t.label, style: TextStyle(fontSize: 8, color: colors.textTertiary)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 16, color: colors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
