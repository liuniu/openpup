import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/navigation_item.dart';
import '../../providers/ui_provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/pup_visuals.dart';

/// Left sidebar — replaces sidebar in App.tsx.
///
/// Two states:
/// - Expanded (196px): full nav with labels
/// - Collapsed (48px):  dot strip, toggled via AppShell
class OpenPupSidebar extends ConsumerWidget {
  final double width;

  const OpenPupSidebar({super.key, this.width = 196});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(uiProvider);
    final appState = ref.watch(appProvider);
    final colors = Theme.of(context).extension<OpenPupColors>()!;
    final isPrimaryView =
        uiState.activeNav == NavItem.chat;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: colors.backgroundPrimary,
        border: Border(
          right: BorderSide(color: colors.borderTertiary!, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          _SidebarHeader(colors: colors),

          // ── Scrollable nav ────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              children: [
                // Pups section
                if (isPrimaryView) ...[
                  _SectionLabel(label: 'Pups', colors: colors),
                  _AlphaEntry(
                    isActive:
                        uiState.activeNav == NavItem.chat && uiState.selectedPupKey == 'alpha',
                    onTap: () {
                      ref.read(uiProvider.notifier).setActiveNav(NavItem.chat);
                      ref.read(uiProvider.notifier).setSelectedPupKey('alpha');
                    },
                    accentColor: colors.accent!,
                  ),
                  // Other pups from app state
                  for (final pup in appState.pups.where((p) => p.key != 'alpha'))
                    _PupEntry(
                      label: pup.displayName,
                      isActive: uiState.activeNav == NavItem.chat &&
                          uiState.selectedPupKey == pup.key,
                      color: pupAccentColor(pup.key),
                      onTap: () {
                        ref.read(uiProvider.notifier).setActiveNav(NavItem.chat);
                        ref.read(uiProvider.notifier).setSelectedPupKey(pup.key);
                      },
                    ),
                ],

                const SizedBox(height: 16),

                // Tools section
                _CollapsibleSection(
                  label: 'Tools',
                  isExpanded: uiState.toolsExpanded,
                  colors: colors,
                  onToggle: () =>
                      ref.read(uiProvider.notifier).setToolsExpanded(!uiState.toolsExpanded),
                  children: [
                    _NavItem(
                      label: 'Timeline',
                      icon: Icons.timeline,
                      isActive: uiState.activeNav == NavItem.timeline,
                      colors: colors,
                      onTap: () =>
                          ref.read(uiProvider.notifier).setActiveNav(NavItem.timeline),
                    ),
                    _NavItem(
                      label: 'Memories',
                      icon: Icons.memory,
                      isActive: uiState.activeNav == NavItem.memories,
                      colors: colors,
                      onTap: () =>
                          ref.read(uiProvider.notifier).setActiveNav(NavItem.memories),
                    ),
                    _NavItem(
                      label: 'Knowledge',
                      icon: Icons.menu_book,
                      isActive: uiState.activeNav == NavItem.knowledge,
                      badge: appState.kbSourceCount > 0
                          ? appState.kbSourceCount.toString()
                          : null,
                      colors: colors,
                      onTap: () =>
                          ref.read(uiProvider.notifier).setActiveNav(NavItem.knowledge),
                    ),
                    _NavItem(
                      label: 'Tasks',
                      icon: Icons.check_circle_outline,
                      isActive: uiState.activeNav == NavItem.tasks,
                      colors: colors,
                      onTap: () =>
                          ref.read(uiProvider.notifier).setActiveNav(NavItem.tasks),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Config section
                _CollapsibleSection(
                  label: 'Config',
                  isExpanded: uiState.configExpanded,
                  colors: colors,
                  onToggle: () =>
                      ref.read(uiProvider.notifier).setConfigExpanded(!uiState.configExpanded),
                  children: [
                    _NavItem(
                      label: 'Pup Manager',
                      icon: Icons.pets,
                      isActive: uiState.activeNav == NavItem.pups,
                      colors: colors,
                      onTap: () =>
                          ref.read(uiProvider.notifier).setActiveNav(NavItem.pups),
                    ),
                    _NavItem(
                      label: 'Skill Claw',
                      icon: Icons.extension,
                      isActive: uiState.activeNav == NavItem.skills,
                      colors: colors,
                      onTap: () =>
                          ref.read(uiProvider.notifier).setActiveNav(NavItem.skills),
                    ),
                    _NavItem(
                      label: 'Bridge',
                      icon: Icons.lan,
                      isActive: uiState.activeNav == NavItem.bridge,
                      colors: colors,
                      onTap: () =>
                          ref.read(uiProvider.notifier).setActiveNav(NavItem.bridge),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Footer ────────────────────────────────────────────────────
          _Footer(uiState: uiState, appState: appState, colors: colors),
        ],
      ),
    );
  }
}

// ── Header widget ────────────────────────────────────────────────────────────

class _SidebarHeader extends StatelessWidget {
  final OpenPupColors colors;
  const _SidebarHeader({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.borderTertiary!, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colors.accent!.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.pets, size: 14, color: colors.accent),
          ),
          const SizedBox(width: 6),
          Text(
            'openpup',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pups section ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final OpenPupColors colors;
  const _SectionLabel({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 6, right: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: colors.textTertiary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _AlphaEntry extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  final Color accentColor;

  const _AlphaEntry({
    required this.isActive,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? accentColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              _Dot(color: accentColor),
              const SizedBox(width: 8),
              Text(
                'Alpha',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? accentColor : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PupEntry extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _PupEntry({
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              _Dot(color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Nav items ────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final OpenPupColors colors;
  final VoidCallback onTap;
  final String? badge;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.colors,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: isActive ? colors.accent!.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(icon, size: 14, color: isActive ? colors.accent : colors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? colors.accent : colors.textPrimary,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: colors.accent!.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: colors.accent),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Collapsible section ──────────────────────────────────────────────────────

class _CollapsibleSection extends StatelessWidget {
  final String label;
  final bool isExpanded;
  final OpenPupColors colors;
  final VoidCallback onToggle;
  final List<Widget> children;

  const _CollapsibleSection({
    required this.label,
    required this.isExpanded,
    required this.colors,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 6, right: 8),
            child: Row(
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: colors.textTertiary,
                    letterSpacing: 0.6,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(Icons.chevron_right,
                      size: 12, color: colors.textTertiary),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...children,
      ],
    );
  }
}

// ── Pup dot ──────────────────────────────────────────────────────────────────

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ── Footer ───────────────────────────────────────────────────────────────────

class _Footer extends ConsumerWidget {
  final UIState uiState;
  final AppState appState;
  final OpenPupColors colors;
  const _Footer(
      {required this.uiState, required this.appState, required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      decoration: BoxDecoration(
        border:
            Border(top: BorderSide(color: colors.borderTertiary!, width: 0.5)),
      ),
      child: Column(
        children: [
          // Execution mode toggle
          GestureDetector(
            onTap: () {
              // TODO: call set_execution_mode on Rust backend
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: colors.backgroundSecondary?.withOpacity(0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    appState.execMode == 'leashed'
                        ? Icons.link
                        : Icons.link_off,
                    size: 12,
                    color: appState.execMode == 'leashed'
                        ? colors.accent
                        : colors.textWarning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    appState.execMode == 'leashed' ? 'LEASHED' : 'FREE RUN',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: appState.execMode == 'leashed'
                          ? colors.accent
                          : colors.textWarning,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
