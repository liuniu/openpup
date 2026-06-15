import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';

/// Finance overview — replaces FinanceOverview.tsx.
///
/// Shows: health status, market status, balance, positions, watchlist.
class FinanceOverviewTab extends ConsumerWidget {
  const FinanceOverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return Container(
      color: colors.backgroundPrimary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Service health chips
          Row(
            children: [
              _HealthChip(label: 'Intel', status: 'up', colors: colors),
              const SizedBox(width: 8),
              _HealthChip(label: 'Risk', status: 'unconfigured', colors: colors),
              const SizedBox(width: 8),
              _HealthChip(label: 'Exec', status: 'up', colors: colors),
            ],
          ),
          const SizedBox(height: 16),

          // Market status + Balance row
          Row(
            children: [
              Expanded(child: _MetricCard(label: 'Total Assets', value: '--', tone: 'green', colors: colors)),
              const SizedBox(width: 8),
              Expanded(child: _MetricCard(label: 'Available', value: '--', tone: 'blue', colors: colors)),
              const SizedBox(width: 8),
              Expanded(child: _MetricCard(label: 'P&L', value: '--', tone: 'amber', colors: colors)),
            ],
          ),
          const SizedBox(height: 16),

          // Positions section
          Text('Positions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
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
                  Icon(Icons.show_chart, size: 24, color: colors.textTertiary),
                  const SizedBox(height: 4),
                  Text('No positions', style: TextStyle(fontSize: 12, color: colors.textTertiary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Watchlist
          Text('Watchlist', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.borderTertiary!, width: 0.5),
            ),
            child: Center(
              child: Text('Add stocks to your watchlist', style: TextStyle(fontSize: 12, color: colors.textTertiary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthChip extends StatelessWidget {
  final String label;
  final String status;
  final OpenPupColors colors;

  const _HealthChip({required this.label, required this.status, required this.colors});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (status) {
      'up' => (const Color(0xFF1D9E75).withOpacity(0.12), const Color(0xFF0E6A4C)),
      'unconfigured' => (const Color(0xFFBA7517).withOpacity(0.12), const Color(0xFF8A5A10)),
      _ => (const Color(0xFFE24B4A).withOpacity(0.12), const Color(0xFFB81C1C)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String tone;
  final OpenPupColors colors;

  const _MetricCard({required this.label, required this.value, required this.tone, required this.colors});

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      'green' => const Color(0xFF0E6A4C),
      'amber' => const Color(0xFF8A5A10),
      'blue' => const Color(0xFF1A5EA0),
      _ => const Color(0xFFB81C1C),
    };
    final bgColor = color.withOpacity(0.12);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: color)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
