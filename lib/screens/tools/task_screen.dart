import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';

/// Task manager — replaces TaskManager.tsx.
///
/// Shows task list + scheduled jobs.
class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
  int _tabIndex = 0; // 0 = tasks, 1 = scheduled

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return Container(
      color: colors.backgroundPrimary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text('Tasks',
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
                    child: Text('+ New Task', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _Tab(label: 'Tasks', index: 0, current: _tabIndex, colors: colors, onTap: () => setState(() => _tabIndex = 0)),
                const SizedBox(width: 6),
                _Tab(label: 'Scheduled', index: 1, current: _tabIndex, colors: colors, onTap: () => setState(() => _tabIndex = 1)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),

          // Content
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 32, color: colors.textTertiary),
                  const SizedBox(height: 8),
                  Text(_tabIndex == 0 ? 'No tasks' : 'No scheduled jobs',
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

class _Tab extends StatelessWidget {
  final String label;
  final int index;
  final int current;
  final OpenPupColors colors;
  final VoidCallback onTap;

  const _Tab({required this.label, required this.index, required this.current, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? colors.backgroundSecondary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.w500 : FontWeight.w400, color: isActive ? colors.textPrimary : colors.textSecondary)),
      ),
    );
  }
}
