import 'package:flutter/material.dart';
import '../../models/navigation_item.dart';
import '../../providers/ui_provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../config/llm_config.dart';

/// Mobile drawer — hamburger menu version of the sidebar.
class OpenPupMobileDrawer extends StatelessWidget {
  final OpenPupColors colors;
  final UIState uiState;
  final AppState appState;
  final void Function(NavItem) onNavTap;
  final void Function(String) onPupSelected;

  const OpenPupMobileDrawer({
    super.key,
    required this.colors,
    required this.uiState,
    required this.appState,
    required this.onNavTap,
    required this.onPupSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: colors.backgroundPrimary,
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            _DrawerHeader(colors: colors),

            // ── Navigation list ─────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Section: Chat
                  _SectionHeader(label: 'CHAT', colors: colors),
                  _NavTile(
                    icon: Icons.chat_bubble_outline,
                    label: 'Chat',
                    isActive: uiState.activeNav == NavItem.chat,
                    colors: colors,
                    onTap: () => onNavTap(NavItem.chat),
                  ),
                  _NavTile(
                    icon: Icons.account_tree_outlined,
                    label: 'Pack Channel',
                    isActive: uiState.activeNav == NavItem.channel,
                    colors: colors,
                    onTap: () => onNavTap(NavItem.channel),
                  ),

                  const SizedBox(height: 8),
                  _SectionHeader(label: 'TOOLS', colors: colors),
                  _NavTile(
                    icon: Icons.timeline,
                    label: 'Timeline',
                    isActive: uiState.activeNav == NavItem.timeline,
                    colors: colors,
                    onTap: () => onNavTap(NavItem.timeline),
                  ),
                  _NavTile(
                    icon: Icons.memory,
                    label: 'Memories',
                    isActive: uiState.activeNav == NavItem.memories,
                    colors: colors,
                    onTap: () => onNavTap(NavItem.memories),
                  ),
                  _NavTile(
                    icon: Icons.menu_book,
                    label: 'Knowledge Base',
                    isActive: uiState.activeNav == NavItem.knowledge,
                    badge: appState.kbSourceCount > 0 ? appState.kbSourceCount.toString() : null,
                    colors: colors,
                    onTap: () => onNavTap(NavItem.knowledge),
                  ),
                  _NavTile(
                    icon: Icons.check_circle_outline,
                    label: 'Tasks',
                    isActive: uiState.activeNav == NavItem.tasks,
                    colors: colors,
                    onTap: () => onNavTap(NavItem.tasks),
                  ),

                  const SizedBox(height: 8),
                  _SectionHeader(label: 'MANAGE', colors: colors),
                  _NavTile(
                    icon: Icons.pets,
                    label: 'Pup Manager',
                    isActive: uiState.activeNav == NavItem.pups,
                    colors: colors,
                    onTap: () => onNavTap(NavItem.pups),
                  ),
                  _NavTile(
                    icon: Icons.extension,
                    label: 'Skill Claw',
                    isActive: uiState.activeNav == NavItem.skills,
                    colors: colors,
                    onTap: () => onNavTap(NavItem.skills),
                  ),
                  _NavTile(
                    icon: Icons.cable,
                    label: 'MCP Settings',
                    isActive: uiState.activeNav == NavItem.mcp,
                    colors: colors,
                    onTap: () => onNavTap(NavItem.mcp),
                  ),
                  _NavTile(
                    icon: Icons.lan,
                    label: 'Bridge Settings',
                    isActive: uiState.activeNav == NavItem.bridge,
                    colors: colors,
                    onTap: () => onNavTap(NavItem.bridge),
                  ),
                  _NavTile(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    isActive: uiState.activeNav == NavItem.settings,
                    colors: colors,
                    onTap: () => onNavTap(NavItem.settings),
                  ),
                ],
              ),
            ),

            // ── Footer ──────────────────────────────────────────────────
            _DrawerFooter(
              colors: colors,
              execMode: appState.execMode,
              onFinanceTap: () => onNavTap(NavItem.finance),
              isFinanceActive: uiState.activeNav == NavItem.finance,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Drawer header ───────────────────────────────────────────────────────────
class _DrawerHeader extends StatelessWidget {
  final OpenPupColors colors;
  const _DrawerHeader({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.borderTertiary!, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: colors.accent!.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.pets, size: 20, color: colors.accent),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'openpup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    DefaultLlmConfig.providerName,
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section header ──────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final OpenPupColors colors;
  const _SectionHeader({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colors.textTertiary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Navigation tile ─────────────────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final OpenPupColors colors;
  final VoidCallback onTap;
  final String? badge;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.colors,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? colors.accent!.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? colors.accent : colors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? colors.accent : colors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.accent!.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
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

// ── Drawer footer ───────────────────────────────────────────────────────────
class _DrawerFooter extends StatelessWidget {
  final OpenPupColors colors;
  final String execMode;
  final VoidCallback onFinanceTap;
  final bool isFinanceActive;

  const _DrawerFooter({
    required this.colors,
    required this.execMode,
    required this.onFinanceTap,
    required this.isFinanceActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.borderTertiary!, width: 0.5)),
      ),
      child: Column(
        children: [
          _NavTile(
            icon: Icons.show_chart,
            label: 'Finance',
            isActive: isFinanceActive,
            colors: colors,
            onTap: onFinanceTap,
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  execMode == 'leashed' ? Icons.link : Icons.link_off,
                  size: 14,
                  color: execMode == 'leashed' ? colors.accent : colors.textWarning,
                ),
                const SizedBox(width: 6),
                Text(
                  execMode == 'leashed' ? 'Leashed Mode' : 'Free Run',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: execMode == 'leashed' ? colors.accent : colors.textWarning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
