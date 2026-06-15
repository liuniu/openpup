import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';

/// Finance orders — replaces FinanceOrders.tsx.
///
/// Shows: positions, open orders, trade history.
class FinanceOrdersTab extends ConsumerWidget {
  const FinanceOrdersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return Container(
      color: colors.backgroundPrimary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary bar
          Row(
            children: [
              _SummaryChip(label: 'Open Orders', value: '0', colors: colors),
              const SizedBox(width: 8),
              _SummaryChip(label: 'Today Trades', value: '0', colors: colors),
              const SizedBox(width: 8),
              _SummaryChip(label: 'P&L', value: '--', colors: colors),
            ],
          ),
          const SizedBox(height: 16),

          // Orders list
          Text('Orders', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.borderTertiary!, width: 0.5),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 24, color: colors.textTertiary),
                  const SizedBox(height: 4),
                  Text('No orders', style: TextStyle(fontSize: 12, color: colors.textTertiary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Trade history
          Text('Trade History', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
          const SizedBox(height: 8),
          Center(
            child: Text('No trades yet', style: TextStyle(fontSize: 12, color: colors.textTertiary)),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final OpenPupColors colors;

  const _SummaryChip({required this.label, required this.value, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.borderTertiary!, width: 0.5),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary)),
            Text(label, style: TextStyle(fontSize: 10, color: colors.textTertiary)),
          ],
        ),
      ),
    );
  }
}
