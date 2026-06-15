import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/finance_provider.dart';
import 'overview_tab.dart';
import 'research_tab.dart';
import 'orders_tab.dart';
import 'pipeline_tab.dart';

/// Finance Workbench — replaces FinanceWorkbench.tsx.
///
/// 4 sub-tabs: Overview, Research, Orders, Pipeline.
class FinanceShell extends ConsumerWidget {
  const FinanceShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;
    final financeState = ref.watch(financeProvider);
    final tabs = ['Overview', 'Research', 'Orders', 'Pipeline'];

    return Container(
      color: colors.backgroundPrimary,
      child: Column(
        children: [
          // Header + tab bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.borderTertiary!, width: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Finance Workbench',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                const SizedBox(height: 12),
                Row(
                  children: tabs.asMap().entries.map((entry) {
                    final isActive = financeState.activeTab == entry.value.toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => ref.read(financeProvider.notifier).setActiveTab(entry.value.toLowerCase()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF0E6A4C)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                            border: isActive
                                ? Border.all(color: const Color(0xFF0E6A4C).withOpacity(0.22))
                                : null,
                            boxShadow: isActive
                                ? [BoxShadow(
                                    color: const Color(0xFF0E6A4C).withOpacity(0.18),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  )]
                                : null,
                          ),
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                              color: isActive ? const Color(0xFFE5F7F0) : colors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: _buildTabContent(financeState.activeTab),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(String tab) {
    switch (tab) {
      case 'overview':
        return const FinanceOverviewTab();
      case 'research':
        return const FinanceResearchTab();
      case 'orders':
        return const FinanceOrdersTab();
      case 'pipeline':
        return const FinancePipelineTab();
      default:
        return const FinanceOverviewTab();
    }
  }
}
