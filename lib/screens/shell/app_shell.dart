import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'titlebar.dart';
import 'sidebar.dart';
import 'mobile_drawer.dart';
import '../../models/navigation_item.dart';
import '../../providers/ui_provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/permission_overlay.dart';
import '../../widgets/status_bar.dart';
import '../chat/chat_screen.dart';
import '../settings/desktop_settings.dart';
import '../settings/pup_manager.dart';
import '../settings/mcp_settings.dart';
import '../settings/bridge_settings.dart';
import '../skills/skill_claw.dart';
import '../tools/knowledge_base.dart';
import '../tools/memory_screen.dart';
import '../tools/timeline_screen.dart';
import '../tools/task_screen.dart';
import '../channel/pack_channel.dart';
import '../groups/group_chat.dart';
import '../finance/finance_shell.dart';

/// Main app shell.
class AppShell extends ConsumerStatefulWidget {
  final void Function(ThemeMode)? onThemeChanged;
  final void Function(Locale)? onLocaleChanged;

  const AppShell({
    super.key,
    this.onThemeChanged,
    this.onLocaleChanged,
  });

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _isDesktop = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _isDesktop = !(Platform.isAndroid || Platform.isIOS);
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(uiProvider);
    final appState = ref.watch(appProvider);
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return _isDesktop
        ? _buildDesktop(uiState, appState, colors)
        : _buildMobile(uiState, appState, colors);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Desktop layout
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDesktop(UIState uiState, AppState appState, OpenPupColors colors) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              OpenPupTitlebar(
                onToggleSidebar: () => ref.read(uiProvider.notifier).toggleSidebar(),
                onToggleTheme: () {
                  ref.read(uiProvider.notifier).toggleTheme();
                  widget.onThemeChanged?.call(
                    uiState.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                  );
                },
              ),
              Expanded(
                child: Row(
                  children: [
                    if (uiState.sidebarCollapsed)
                      _CollapsedSidebarStrip(colors: colors)
                    else
                      const OpenPupSidebar(width: 196),
                    Expanded(child: _buildContentArea(uiState, colors)),
                  ],
                ),
              ),
              const StatusBar(),
            ],
          ),
          if (appState.permissionRequest != null)
            PermissionOverlay(request: appState.permissionRequest!),
        ],
      ),
    );
  }

  Widget _CollapsedSidebarStrip({required OpenPupColors colors}) {
    return Container(
      width: 48,
      decoration: BoxDecoration(
        color: colors.backgroundPrimary,
        border: Border(right: BorderSide(color: colors.borderTertiary!, width: 0.5)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _CollapsedDot(
            color: colors.accent!,
            onTap: () {
              ref.read(uiProvider.notifier).setActiveNav(NavItem.chat);
              ref.read(uiProvider.notifier).setSelectedPupKey('alpha');
              ref.read(uiProvider.notifier).toggleSidebar();
            },
          ),
          const Spacer(),
          _CollapsedDot(
            color: colors.textTertiary!,
            onTap: () => ref.read(uiProvider.notifier).toggleSidebar(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Mobile layout
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMobile(UIState uiState, AppState appState, OpenPupColors colors) {
    final currentNav = uiState.activeNav;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: colors.backgroundPrimary,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: colors.textPrimary),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          _navTitle(currentNav),
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(
              uiState.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: colors.textSecondary,
            ),
            onPressed: () {
              ref.read(uiProvider.notifier).toggleTheme();
              widget.onThemeChanged?.call(
                uiState.isDarkMode ? ThemeMode.light : ThemeMode.dark,
              );
            },
          ),
        ],
      ),
      drawer: OpenPupMobileDrawer(
        colors: colors,
        uiState: uiState,
        appState: appState,
        onNavTap: (nav) {
          ref.read(uiProvider.notifier).setActiveNav(nav);
          Navigator.pop(context);
        },
      ),
      body: Stack(
        children: [
          _buildContentArea(uiState, colors),
          if (appState.permissionRequest != null)
            PermissionOverlay(request: appState.permissionRequest!),
        ],
      ),
    );
  }

  String _navTitle(NavItem nav) {
    switch (nav) {
      case NavItem.chat: return 'Chat';
      case NavItem.channel: return 'Pack Channel';
      case NavItem.groups: return 'Group Chat';
      case NavItem.finance: return 'Finance';
      case NavItem.timeline: return 'Timeline';
      case NavItem.memories: return 'Memories';
      case NavItem.knowledge: return 'Knowledge';
      case NavItem.tasks: return 'Tasks';
      case NavItem.pups: return 'Pup Manager';
      case NavItem.skills: return 'Skill Claw';
      case NavItem.mcp: return 'MCP';
      case NavItem.bridge: return 'Bridge';
      case NavItem.settings: return 'Settings';
    }
  }

  Widget _buildContentArea(UIState uiState, OpenPupColors colors) {
    final nav = uiState.activeNav;

    switch (nav) {
      case NavItem.chat: return const ChatScreen();
      case NavItem.settings: return const DesktopSettingsScreen();
      case NavItem.pups: return const PupManagerScreen();
      case NavItem.mcp: return const McpSettingsScreen();
      case NavItem.bridge: return const BridgeSettingsScreen();
      case NavItem.skills: return const SkillClawScreen();
      case NavItem.knowledge: return const KnowledgeBaseScreen();
      case NavItem.memories: return const MemoryScreen();
      case NavItem.timeline: return const TimelineScreen();
      case NavItem.tasks: return const TaskScreen();
      case NavItem.channel: return const PackChannelScreen();
      case NavItem.groups: return const GroupChatScreen();
      case NavItem.finance: return const FinanceShell();
    }
  }
}

class _CollapsedDot extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  const _CollapsedDot({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
