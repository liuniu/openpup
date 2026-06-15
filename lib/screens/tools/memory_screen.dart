import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';

/// Memory manager — replaces MemoryManager.tsx + DiaryViewer.tsx.
///
/// Two tabs: Long-term memories (list + search + edit) and Diary (daily entries).
class MemoryScreen extends ConsumerStatefulWidget {
  const MemoryScreen({super.key});

  @override
  ConsumerState<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends ConsumerState<MemoryScreen> {
  int _tabIndex = 0; // 0 = long_term, 1 = diary
  final _searchCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return Container(
      color: colors.backgroundPrimary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                _TabBtn(label: 'Long-term', index: 0, current: _tabIndex, colors: colors, onTap: () => setState(() => _tabIndex = 0)),
                const SizedBox(width: 6),
                _TabBtn(label: 'Diary', index: 1, current: _tabIndex, colors: colors, onTap: () => setState(() => _tabIndex = 1)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Content
          Expanded(
            child: _tabIndex == 0 ? _buildLongTermTab(colors) : _buildDiaryTab(colors),
          ),
        ],
      ),
    );
  }

  Widget _buildLongTermTab(OpenPupColors colors) {
    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.borderSecondary!, width: 0.5),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 14, color: colors.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search memories…',
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    style: TextStyle(fontSize: 12, color: colors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // List
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 0, // TODO: from rust bridge
                  itemBuilder: (_, i) => const SizedBox(),
                  // Empty state:
                  // child: Center(
                  //   child: Text('No memories yet', style: TextStyle(fontSize: 13, color: colors.textTertiary)),
                  // ),
                ),
        ),
      ],
    );
  }

  Widget _buildDiaryTab(OpenPupColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.book_outlined, size: 32, color: colors.textTertiary),
          const SizedBox(height: 8),
          Text('Diary — Phase 5', style: TextStyle(fontSize: 13, color: colors.textTertiary)),
        ],
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final int index;
  final int current;
  final OpenPupColors colors;
  final VoidCallback onTap;

  const _TabBtn({
    required this.label,
    required this.index,
    required this.current,
    required this.colors,
    required this.onTap,
  });

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
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
            color: isActive ? colors.textPrimary : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
