import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../bridge/rust_bridge.dart';
import '../../utils/format_helpers.dart';
import 'llm_config_panel.dart';

/// Desktop settings screen — groups LLM config + app settings.
///
/// Replaces the "settings" content in App.tsx (LlmConfigPanel + DesktopSettings).
class DesktopSettingsScreen extends ConsumerWidget {
  const DesktopSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return Container(
      color: colors.backgroundPrimary,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ── LLM Configuration ───────────────────────────────────────
          const LlmConfigPanel(),
          const SizedBox(height: 32),

          // ── App Settings ────────────────────────────────────────────
          const _AppSettingsSection(),
        ],
      ),
    );
  }
}

// ── App Settings ────────────────────────────────────────────────────────────

class _AppSettingsSection extends ConsumerWidget {
  const _AppSettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Application',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // Theme toggle
        _SettingsCard(
          colors: colors,
          child: Column(
            children: [
              _SettingsRow(
                label: 'Theme',
                colors: colors,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ThemeBtn(label: 'Dark', colors: colors, isActive: true, onTap: () {}),
                    const SizedBox(width: 6),
                    _ThemeBtn(label: 'Light', colors: colors, isActive: false, onTap: () {}),
                  ],
                ),
              ),
              _Divider(colors: colors),

              // Execution mode
              _SettingsRow(
                label: 'Execution Mode',
                colors: colors,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ModeBtn(label: 'Leashed', colors: colors, isActive: true, onTap: () {}),
                    const SizedBox(width: 6),
                    _ModeBtn(label: 'Free Run', colors: colors, isActive: false, onTap: () {}),
                  ],
                ),
              ),
              _Divider(colors: colors),

              // Language
              _SettingsRow(
                label: 'Language',
                colors: colors,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LangBtn(label: '中文', colors: colors, isActive: true, onTap: () {}),
                    const SizedBox(width: 6),
                    _LangBtn(label: 'EN', colors: colors, isActive: false, onTap: () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Backup section
        _SettingsCard(
          colors: colors,
          child: Column(
            children: [
              _SettingsRow(
                label: 'Export Workspace',
                subtitle: 'Backup all data to a zip file',
                colors: colors,
                trailing: _ActionBtn(label: 'Export', colors: colors, onTap: () {
                  // TODO: call export_workspace
                }),
              ),
              _Divider(colors: colors),
              _SettingsRow(
                label: 'Import Workspace',
                subtitle: 'Restore from a backup file',
                colors: colors,
                trailing: _ActionBtn(label: 'Import', colors: colors, onTap: () {
                  // TODO: call file_selector then import_workspace
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Reusable sub-widgets ────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final OpenPupColors colors;
  final Widget child;
  const _SettingsCard({required this.colors, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderTertiary!, width: 0.5),
      ),
      child: child,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final OpenPupColors colors;
  final Widget trailing;
  const _SettingsRow({
    required this.label,
    this.subtitle,
    required this.colors,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13, color: colors.textPrimary)),
                if (subtitle != null)
                  Text(subtitle!, style: TextStyle(fontSize: 11, color: colors.textTertiary)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final OpenPupColors colors;
  const _Divider({required this.colors});
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: colors.borderTertiary);
  }
}

class _ThemeBtn extends StatelessWidget {
  final String label;
  final OpenPupColors colors;
  final bool isActive;
  final VoidCallback onTap;
  const _ThemeBtn({required this.label, required this.colors, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? colors.backgroundPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
      ),
    );
  }
}

class _ModeBtn extends StatelessWidget {
  final String label;
  final OpenPupColors colors;
  final bool isActive;
  final VoidCallback onTap;
  const _ModeBtn({required this.label, required this.colors, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? colors.accent!.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, color: isActive ? colors.accent : colors.textSecondary)),
      ),
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String label;
  final OpenPupColors colors;
  final bool isActive;
  final VoidCallback onTap;
  const _LangBtn({required this.label, required this.colors, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? colors.backgroundPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final OpenPupColors colors;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.backgroundPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.borderSecondary!, width: 0.5),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
      ),
    );
  }
}
