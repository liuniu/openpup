import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../providers/app_provider.dart';
import '../providers/ui_provider.dart';
import '../theme/app_theme.dart';
import '../models/navigation_item.dart';
import '../models/pup_config.dart';

/// Bottom status bar — shows execution mode, token usage & context stats.
///
/// Replaces the inline status indicators scattered through App.tsx.
class StatusBar extends ConsumerWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(uiProvider);
    final appState = ref.watch(appProvider);
    final chatState = ref.watch(chatProvider);
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    // Only show when relevant
    if (uiState.activeNav != NavItem.chat && uiState.activeNav != NavItem.channel) {
      return const SizedBox.shrink();
    }

    // Don't show during loading state
    if (appState.onboardingDone != true) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        border: Border(
          top: BorderSide(color: colors.borderTertiary!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Execution mode indicator
          _StatusChip(
            icon: appState.execMode == 'leashed' ? Icons.link : Icons.link_off,
            label: appState.execMode == 'leashed' ? 'LEASHED' : 'FREE RUN',
            color: appState.execMode == 'leashed'
                ? colors.accent!
                : colors.textWarning!,
            colors: colors,
          ),

          const SizedBox(width: 12),

          // Token usage (if available)
          if (chatState.tokenUsage != null) ...[
            _DotSeparator(colors: colors),
            _TokenStat(
              icon: Icons.arrow_drop_up,
              label: 'In',
              value: chatState.tokenUsage!.promptTokens,
              iconColor: colors.textSuccess!,
              textColor: colors.textTertiary!,
            ),
            const SizedBox(width: 8),
            _TokenStat(
              icon: Icons.arrow_drop_down,
              label: 'Out',
              value: chatState.tokenUsage!.completionTokens,
              iconColor: colors.textWarning!,
              textColor: colors.textTertiary!,
            ),
          ],

          // Context usage
          if (appState.contextStats != null) ...[
            const SizedBox(width: 8),
            _DotSeparator(colors: colors),
            const SizedBox(width: 8),
            _ContextUsageBar(stats: appState.contextStats!, colors: colors),
          ],

          const Spacer(),

          // Active pup indicator
          Text(
            '@${uiState.selectedPupKey}',
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final OpenPupColors colors;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TokenStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color iconColor;
  final Color textColor;

  const _TokenStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: iconColor),
        Text(
          '${_fmt(value)}',
          style: TextStyle(fontSize: 10, color: textColor),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(fontSize: 9, color: textColor.withOpacity(0.6)),
        ),
      ],
    );
  }

  String _fmt(int n) {
    if (n >= 1_000_000) return '${(n / 1_000_000).toStringAsFixed(1)}M';
    if (n >= 1_000) return '${(n / 1_000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

class _DotSeparator extends StatelessWidget {
  final OpenPupColors colors;
  const _DotSeparator({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text('·',
          style: TextStyle(fontSize: 10, color: colors.textTertiary)),
    );
  }
}

class _ContextUsageBar extends StatelessWidget {
  final ContextStats stats;
  final OpenPupColors colors;

  const _ContextUsageBar({required this.stats, required this.colors});

  @override
  Widget build(BuildContext context) {
    final ratio = stats.contextLimit > 0
        ? (stats.contextTokens / stats.contextLimit).clamp(0.0, 1.0)
        : 0.0;
    final barColor = ratio > 0.8
        ? colors.textDanger
        : ratio > 0.5
            ? colors.textWarning
            : colors.accent;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              children: [
                Container(color: colors.backgroundTertiary),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(color: barColor),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${_fmt(stats.contextTokens)}/${_fmt(stats.contextLimit)}',
          style: TextStyle(
            fontSize: 9,
            fontFamily: 'monospace',
            color: colors.textTertiary,
          ),
        ),
        if (stats.compressionStatus.isCompressed)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(Icons.compress, size: 9, color: colors.textTertiary),
          ),
      ],
    );
  }

  String _fmt(int n) {
    if (n >= 1_000_000) return '${(n / 1_000_000).toStringAsFixed(1)}M';
    if (n >= 1_000) return '${(n / 1_000).toStringAsFixed(1)}k';
    return n.toString();
  }
}
