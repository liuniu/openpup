import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../utils/pup_visuals.dart';

/// Pup (Agent) manager — replaces PupManager.tsx.
class PupManagerScreen extends ConsumerWidget {
  const PupManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    final pups = [
      _PupData('alpha', 'Alpha', 'Orchestrator — routes tasks to specialist pups', true, false),
      _PupData('dev', 'Dev', 'Software engineering & code review', true, false),
      _PupData('writer', 'Writer', 'Writing & content creation', true, false),
      _PupData('ops', 'Ops', 'DevOps & infrastructure', true, false),
      _PupData('research', 'Research', 'Information gathering & analysis', true, false),
      _PupData('life_admin', 'Life Admin', 'Scheduling & personal tasks', true, false),
    ];

    return Container(
      color: colors.backgroundPrimary,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Text('Pup Manager',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.accent!.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('${pups.length}', style: TextStyle(fontSize: 11, color: colors.accent)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.borderSecondary!, width: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('+ Custom Pup', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          for (final pup in pups) ...[
            _PupCard(pup: pup, colors: colors),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _PupData {
  final String key;
  final String name;
  final String description;
  final bool enabled;
  final bool isCustom;
  const _PupData(this.key, this.name, this.description, this.enabled, this.isCustom);
}

class _PupCard extends StatelessWidget {
  final _PupData pup;
  final OpenPupColors colors;

  const _PupCard({required this.pup, required this.colors});

  @override
  Widget build(BuildContext context) {
    final accent = pupAccentColor(pup.key);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderTertiary!, width: 0.5),
      ),
      child: Row(
        children: [
          // Indicator dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(pup.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                    const SizedBox(width: 6),
                    Text('@${pup.key}', style: TextStyle(fontSize: 10, color: colors.textTertiary, fontFamily: 'monospace')),
                    if (pup.isCustom)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: colors.accent!.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('custom', style: TextStyle(fontSize: 9, color: colors.accent)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(pup.description, style: TextStyle(fontSize: 11, color: colors.textTertiary)),
              ],
            ),
          ),
          // Permissions summary
          _PermBadge(label: 'shell', colors: colors),
          const SizedBox(width: 4),
          _PermBadge(label: 'read', colors: colors),
          const SizedBox(width: 4),
          _PermBadge(label: 'web', colors: colors),
          const SizedBox(width: 8),
          // Toggle
          Switch(
            value: pup.enabled,
            onChanged: (_) {},
            activeColor: colors.accent,
          ),
        ],
      ),
    );
  }
}

class _PermBadge extends StatelessWidget {
  final String label;
  final OpenPupColors colors;
  const _PermBadge({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors.borderTertiary!, width: 0.5),
      ),
      child: Text(label, style: TextStyle(fontSize: 9, color: colors.textTertiary, fontFamily: 'monospace')),
    );
  }
}
