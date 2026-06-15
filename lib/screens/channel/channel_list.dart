import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/channel_models.dart';
import '../../theme/app_theme.dart';
import '../../utils/pup_visuals.dart';

/// Channel list — the main view of PackChannel when not in detail mode.
///
/// Shows all active/recent channels with status badges.
class ChannelListScreen extends ConsumerStatefulWidget {
  final void Function(String channelId)? onOpenChannel;

  const ChannelListScreen({super.key, this.onOpenChannel});

  @override
  ConsumerState<ChannelListScreen> createState() => _ChannelListScreenState();
}

class _ChannelListScreenState extends ConsumerState<ChannelListScreen> {
  List<ChannelRecord> _channels = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text('Pack Channel',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
                const Spacer(),
                if (_channels.any((c) => c.status == 'completed'))
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.clear_all, size: 16, color: colors.textTertiary),
                    ),
                  ),
                GestureDetector(
                  onTap: _loadChannels,
                  child: Icon(Icons.refresh, size: 16, color: colors.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${_channels.length} channels · ${_channels.where((c) => c.status == 'active').length} active',
              style: TextStyle(fontSize: 11, color: colors.textTertiary),
            ),
          ),
          const SizedBox(height: 12),

          // Channel list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _channels.isEmpty
                    ? _buildEmptyState(colors)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _channels.length,
                        itemBuilder: (_, i) => _ChannelCard(
                          channel: _channels[i],
                          colors: colors,
                          onTap: () => widget.onOpenChannel?.call(_channels[i].id),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(OpenPupColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_tree_outlined, size: 32, color: colors.textTertiary),
          const SizedBox(height: 8),
          Text('No active channels', style: TextStyle(fontSize: 13, color: colors.textTertiary)),
          const SizedBox(height: 4),
          Text('Start a multi-pup task from chat',
              style: TextStyle(fontSize: 11, color: colors.textTertiary)),
        ],
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final ChannelRecord channel;
  final OpenPupColors colors;
  final VoidCallback onTap;

  const _ChannelCard({
    required this.channel,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(channel.status);

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status indicator
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        channel.title.isNotEmpty ? channel.title : channel.taskId,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      // Member dots
                      if (channel.members.isNotEmpty)
                        Row(
                          children: channel.members.map((m) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: pupAccentColor(m),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    m[0].toUpperCase(),
                                    style: const TextStyle(fontSize: 8, color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 4),
                      // Status + time
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              channel.statusLabel,
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: statusColor),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _relativeTime(channel.updatedAt),
                            style: TextStyle(fontSize: 10, color: colors.textTertiary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Chevron
                Icon(Icons.chevron_right, size: 16, color: colors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF1D9E75);
      case 'completed':
        return const Color(0xFF94A3B8);
      case 'failed':
        return const Color(0xFFE55555);
      case 'awaiting_review':
        return const Color(0xFFBA7517);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  String _relativeTime(int ts) {
    final diff = DateTime.now().millisecondsSinceEpoch ~/ 1000 - ts;
    if (diff < 60) return 'now';
    if (diff < 3600) return '${diff ~/ 60}m ago';
    if (diff < 86400) return '${diff ~/ 3600}h ago';
    return '${diff ~/ 86400}d ago';
  }
}
