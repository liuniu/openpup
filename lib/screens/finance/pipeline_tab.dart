import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/finance_provider.dart';

/// Finance pipeline — replaces FinancePipeline.tsx.
///
/// Shows: trade intent list, batch check, prepare/place orders.
class FinancePipelineTab extends ConsumerWidget {
  const FinancePipelineTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return Container(
      color: colors.backgroundPrimary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Input area
          Text('Trade Intents', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.borderSecondary!, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Paste trade intents as JSON…',
                    hintStyle: TextStyle(fontSize: 12, color: colors.textTertiary),
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(fontSize: 12, color: colors.textPrimary, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: colors.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Batch Check', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.borderSecondary!, width: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Clear', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Intent list (empty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  Icon(Icons.rocket_launch_outlined, size: 28, color: colors.textTertiary),
                  const SizedBox(height: 8),
                  Text('No trade intents', style: TextStyle(fontSize: 12, color: colors.textTertiary)),
                  const SizedBox(height: 4),
                  Text('Define intents and run batch check', style: TextStyle(fontSize: 11, color: colors.textTertiary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
