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
        uiState.activeNav == NavItem.chat || uiState.activeNav == NavItem.channel;

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
          // ── Mode switch (Chat / Pack Channel) ─────────────────────────
          _ModeSwitch(uiState: uiState, colors: colors),

          // ── Scrollable nav ────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              children: [
                // Pups section
                if (isPrimaryView) ...[
                  _SectionLabel('Pups', colors: colors),
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
                      label: 'Pups',
                      icon: Icons.pets,
                      isActive: uiState.activeNav == NavItem.pups,
                      colors: colors,
                      onTap: () =>
                          ref.read(uiProvider.notifier).setActiveNav(NavItem.pups),
                    ),
                    _NavItem(
                      label: 'Skills',
                      icon: Icons.extension,
                      isActive: uiState.activeNav == NavItem.skills,
                      colors: colors,
                      onTap: () =>
                          ref.read(uiProvider.notifier).setActiveNav(NavItem.skills),
                    ),
                    _NavItem(
                      label: 'MCP',
                      icon: Icons.cable,
                      isActive: uiState.activeNav == NavItem.mcp,
                      colors: colors,
                      onTap: () =>
                          ref.read(uiProvider.notifier).setActiveNav(NavItem.mcp),
                    ),
                    _NavItem(
                      label: 'Bridge',
                      icon: Icons.lan,
                      isActive: uiState.activeNav == NavItem.bridge,
                      colors: colors,
                      onTap: () =>
                          ref.read(uiProvider.notifier).setActiveNav(NavItem.bridge),
                    ),
                    _NavItem(
                      label: 'Settings',
                      icon: Icons.settings,
                      isActive: uiState.activeNav == NavItem.settings,
                      colors: colors,
                      onTap: () =>
                          ref.read(uiProvider.notifier).setActiveNav(NavItem.settings),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Footer: Finance + execution mode ──────────────────────────
          _Footer(
            uiState: uiState,
            appState: appState,
            colors: colors,
          ),
        ],
      ),
    );
  }
}

// ── Mode switch ─────────────────────────────────────────────────────────────

class _ModeSwitch extends StatelessWidget {
  final UIState uiState;
  final OpenPupColors colors;
  const _ModeSwitch({required this.uiState, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: colors.borderTertiary!, width: 0.5)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _ModeBtn(
                label: 'Chat',
                isActive: uiState.activeNav == NavItem.chat,
                colors: colors,
                onTap: () {},
              ),
            ),
            Expanded(
              child: _ModeBtn(
                label: 'Packs',
                isActive: uiState.activeNav == NavItem.channel,
                colors: colors,
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final OpenPupColors colors;
  final VoidCallback onTap;
  const _ModeBtn(
      {required this.label,
      required this.isActive,
      required this.colors,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? colors.backgroundPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? colors.textPrimary : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Section label ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final OpenPupColors colors;
  const _SectionLabel(this.label, {required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 6),
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

// ── Alpha entry ─────────────────────────────────────────────────────────────

class _AlphaEntry extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  final Color accentColor;
  const _AlphaEntry(
      {required this.isActive,
      required this.onTap,
      required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return _NavItem(
      label: 'Alpha',
      icon: null,
      leading: _Dot(color: accentColor),
      isActive: isActive,
      onTap: onTap,
      colors: Theme.of(context).extension<OpenPupColors>()!,
    );
  }
}

// ── Pup entry ────────────────────────────────────────────────────────────────

class _PupEntry extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;
  const _PupEntry(
      {required this.label,
      required this.isActive,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _NavItem(
      label: label,
      icon: null,
      leading: _Dot(color: color),
      isActive: isActive,
      onTap: onTap,
      colors: Theme.of(context).extension<OpenPupColors>()!,
    );
  }
}

// ── Nav item button ─────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Widget? leading;
  final bool isActive;
  final String? badge;
  final OpenPupColors colors;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    this.icon,
    this.leading,
    required this.isActive,
    this.badge,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: isActive ? colors.backgroundSecondary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 7)],
                if (icon != null) ...[
                  Icon(icon, size: 14, color: isActive ? colors.textPrimary : colors.textSecondary),
                  const SizedBox(width: 7),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                      color: isActive ? colors.textPrimary : colors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    height: 18,
                    decoration: BoxDecoration(
                      color: colors.accent!.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: colors.accent,
                      ),
                    ),
                  ),
              ],
            ),
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
          // Finance entry
          _NavItem(
            label: 'Finance',
            icon: Icons.show_chart,
            isActive: uiState.activeNav == NavItem.finance,
            colors: colors,
            onTap: () =>
                ref.read(uiProvider.notifier).setActiveNav(NavItem.finance),
          ),
          if (uiState.activeNav == NavItem.finance)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D9E75).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Market',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D9E75)),
                ),
              ),
            ),
          const SizedBox(height: 8),
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
