import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';

/// Finance research — replaces FinanceResearch.tsx.
///
/// Shows: symbol search, news items, data tables.
class FinanceResearchTab extends ConsumerWidget {
  const FinanceResearchTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return Container(
      color: colors.backgroundPrimary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Symbol search
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.borderSecondary!, width: 0.5),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 16, color: colors.textTertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search symbol or news…',
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: TextStyle(fontSize: 13, color: colors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Screener results placeholder
          Text('Screener', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.borderTertiary!, width: 0.5),
            ),
            child: Center(
              child: Text('Run a stock screener query', style: TextStyle(fontSize: 12, color: colors.textTertiary)),
            ),
          ),
          const SizedBox(height: 16),

          // News section
          Text('News', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
          const SizedBox(height: 8),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  Icon(Icons.article_outlined, size: 28, color: colors.textTertiary),
                  const SizedBox(height: 4),
                  Text('No recent news', style: TextStyle(fontSize: 12, color: colors.textTertiary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
