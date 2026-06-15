import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/channel_models.dart';
import '../../theme/app_theme.dart';
import '../../utils/pup_visuals.dart';
import '../../widgets/markdown_renderer.dart';

/// Channel detail view — replaces PackChannel.tsx detail mode.
///
/// Layout:
/// - Top: Plan section with custom DAG visualization
/// - Middle: Message thread
/// - Bottom: Input area for review comments
class ChannelDetailScreen extends ConsumerStatefulWidget {
  final String channelId;

  const ChannelDetailScreen({super.key, required this.channelId});

  @override
  ConsumerState<ChannelDetailScreen> createState() => _ChannelDetailScreenState();
}

class _ChannelDetailScreenState extends ConsumerState<ChannelDetailScreen> {
  DelegationPlan? _plan;
  List<ChannelMessageRecord> _messages = [];
  bool _loading = true;
  bool _showPlan = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _loading = true);
    // TODO: load channel detail from rust bridge
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
                // Back button + title
                _buildHeader(colors),

                // Plan toggle + DAG
                if (_plan != null) _buildPlanSection(colors),

                // Messages
                Expanded(child: _buildMessages(colors)),

                // Input bar
                _buildInputBar(colors),
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
            child: Text(
              _plan?.channelTitle ?? 'Channel',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary),
            ),
          ),
          // Actions: continue, abort
          _ActionChip(label: 'Continue', colors: colors, onTap: () {}),
          const SizedBox(width: 6),
          _ActionChip(label: 'Abort', colors: colors, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildPlanSection(OpenPupColors colors) {
    if (_plan == null || _plan!.subtasks.isEmpty) return const SizedBox();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Toggle bar
        GestureDetector(
          onTap: () => setState(() => _showPlan = !_showPlan),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.account_tree, size: 14, color: colors.textSecondary),
                const SizedBox(width: 6),
                Text('Plan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                const SizedBox(width: 4),
                Text('(${_plan!.subtasks.length} steps)', style: TextStyle(fontSize: 11, color: colors.textTertiary)),
                const Spacer(),
                AnimatedRotation(
                  turns: _showPlan ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(Icons.expand_more, size: 14, color: colors.textTertiary),
                ),
              ],
            ),
          ),
        ),

        // DAG visualization
        if (_showPlan)
          Container(
            height: 140,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.borderTertiary!, width: 0.5),
            ),
            child: CustomPaint(
              painter: _DagPainter(
                subtasks: _plan!.subtasks,
                accent: colors.accent!,
                secondary: colors.textSecondary!,
                tertiary: colors.textTertiary!,
                success: colors.textSuccess!,
                warning: colors.textWarning!,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final s in _plan!.subtasks)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6, height: 6,
                              decoration: BoxDecoration(
                                color: pupAccentColor(s.pup),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${s.pup}: ${s.description}',
                              style: TextStyle(fontSize: 10, color: colors.textTertiary),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMessages(OpenPupColors colors) {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 28, color: colors.textTertiary),
            const SizedBox(height: 8),
            Text('No messages yet', style: TextStyle(fontSize: 12, color: colors.textTertiary)),
          ],
        ),
      );
    }
    return ListView.builder(
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
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: pupAccentColor(msg.sender),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(msg.sender,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                    const Spacer(),
                    Text(_formatTime(msg.timestamp),
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
    );
  }

  Widget _buildInputBar(OpenPupColors colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.borderTertiary!, width: 0.5)),
        color: colors.backgroundPrimary,
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
                  hintText: 'Add comment…',
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

  String _formatTime(int ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── DAG Painter ─────────────────────────────────────────────────────────────

class _DagPainter extends CustomPainter {
  final List<Subtask> subtasks;
  final Color accent, secondary, tertiary, success, warning;

  _DagPainter({
    required this.subtasks,
    required this.accent,
    required this.secondary,
    required this.tertiary,
    required this.success,
    required this.warning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (subtasks.isEmpty) return;

    final n = subtasks.length;
    final nodeR = 8.0;
    final startX = 40.0;
    final stepY = size.height / (n + 1);

    // Draw edges (dependencies)
    final edgePaint = Paint()
      ..color = tertiary.withOpacity(0.2)
      ..strokeWidth = 1;
    for (int i = 0; i < n; i++) {
      final y1 = stepY * (i + 1);
      for (final dep in subtasks[i].dependsOn) {
        final depIdx = subtasks.indexWhere((s) => s.pup == dep || s.description.contains(dep));
        if (depIdx >= 0) {
          final y0 = stepY * (depIdx + 1);
          canvas.drawLine(
            Offset(startX + nodeR + 4, y0),
            Offset(startX + nodeR + 4, y1 - nodeR),
            edgePaint,
          );
        }
      }
    }

    // Draw nodes
    for (int i = 0; i < n; i++) {
      final y = stepY * (i + 1);
      final color = pupAccentColor(subtasks[i].pup);

      // Outer glow
      canvas.drawCircle(Offset(startX, y), nodeR + 3, Paint()..color = color.withOpacity(0.12));
      // Inner circle
      canvas.drawCircle(Offset(startX, y), nodeR, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ActionChip extends StatelessWidget {
  final String label;
  final OpenPupColors colors;
  final VoidCallback onTap;
  const _ActionChip({required this.label, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: colors.borderSecondary!, width: 0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
      ),
    );
  }
}
