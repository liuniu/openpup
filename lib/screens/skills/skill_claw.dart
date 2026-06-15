import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';

/// Skill system manager — replaces SkillClaw.tsx.
class SkillClawScreen extends ConsumerWidget {
  const SkillClawScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return Container(
      color: colors.backgroundPrimary,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Text('Skills',
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
                  child: Text('Install from Git', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Placeholder
          if (true)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Icon(Icons.extension, size: 32, color: colors.textTertiary),
                    const SizedBox(height: 8),
                    Text('No skills installed', style: TextStyle(fontSize: 13, color: colors.textTertiary)),
                    const SizedBox(height: 4),
                    Text('Install skills from ClaWHub or Git repos',
                        style: TextStyle(fontSize: 11, color: colors.textTertiary)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
