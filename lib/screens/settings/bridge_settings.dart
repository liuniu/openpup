import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';

/// Bridge settings — Telegram / WeChat / QQ / Discord configuration.
/// Replaces BridgeSettings.tsx.
class BridgeSettingsScreen extends ConsumerWidget {
  const BridgeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return Container(
      color: colors.backgroundPrimary,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Bridge Configuration',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
          const SizedBox(height: 16),

          // Platform cards
          _BridgeCard(
            platform: 'Telegram',
            icon: Icons.telegram,
            colors: colors,
            enabled: false,
          ),
          const SizedBox(height: 8),
          _BridgeCard(
            platform: 'WeChat',
            icon: Icons.chat,
            colors: colors,
            enabled: false,
          ),
          const SizedBox(height: 8),
          _BridgeCard(
            platform: 'QQ',
            icon: Icons.forum,
            colors: colors,
            enabled: false,
          ),
          const SizedBox(height: 8),
          _BridgeCard(
            platform: 'Discord',
            icon: Icons.headset_mic,
            colors: colors,
            enabled: false,
          ),
        ],
      ),
    );
  }
}

class _BridgeCard extends StatefulWidget {
  final String platform;
  final IconData icon;
  final OpenPupColors colors;
  final bool enabled;

  const _BridgeCard({
    required this.platform,
    required this.icon,
    required this.colors,
    required this.enabled,
  });

  @override
  State<_BridgeCard> createState() => _BridgeCardState();
}

class _BridgeCardState extends State<_BridgeCard> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.enabled;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.colors.borderTertiary!, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(widget.icon, size: 20, color: widget.colors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.platform, style: TextStyle(fontSize: 13, color: widget.colors.textPrimary)),
                Text(
                  _enabled ? 'Connected' : 'Not configured',
                  style: TextStyle(fontSize: 11, color: widget.colors.textTertiary),
                ),
              ],
            ),
          ),
          Switch(
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
            activeColor: widget.colors.accent,
          ),
        ],
      ),
    );
  }
}
