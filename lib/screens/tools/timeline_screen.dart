import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';

/// Timeline — replaces Timeline.tsx.
///
/// Shows conversation events + skill runs with filter tabs.
class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  int _filterIndex = 0; // 0=all, 1=alpha, 2=you, 3=skills
  final _filters = ['All', 'Alpha', 'You', 'Skills'];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return Container(
      color: colors.backgroundPrimary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + filters
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text('Timeline',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
                const Spacer(),
                // Export button
                GestureDetector(
                  onTap: () {},
                  child: Icon(Icons.file_download_outlined, size: 16, color: colors.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _filters.asMap().entries.map((entry) {
                final isActive = entry.key == _filterIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => _filterIndex = entry.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? colors.backgroundSecondary : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: !isActive ? Border.all(color: colors.borderTertiary!, width: 0.5) : null,
                      ),
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                          color: isActive ? colors.textPrimary : colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Event list
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timeline, size: 32, color: colors.textTertiary),
                  const SizedBox(height: 8),
                  Text('No timeline events yet',
                      style: TextStyle(fontSize: 13, color: colors.textTertiary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
