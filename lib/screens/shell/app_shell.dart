import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'titlebar.dart';
import 'sidebar.dart';
import 'mobile_drawer.dart';
import '../../models/navigation_item.dart';
import '../../providers/ui_provider.dart';
import '../../providers/chat_provider.dart';
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
import '../tools/context_inspector.dart';
import '../tools/knowledge_graph.dart';
import '../channel/pack_channel.dart';
import '../groups/group_chat.dart';
import '../finance/finance_shell.dart';

/// Main app shell.
///
/// Desktop: titlebar + sidebar + content + status bar.
/// Mobile:  AppBar with hamburger + drawer + full-width content.
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
  late bool _isDesktop;
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

    return _isDesktop ? _buildDesktop(uiState, appState, colors) : _buildMobile(uiState, appState, colors);
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
    final title = _navTitle(currentNav);

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
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
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
        onPupSelected: (key) {
          ref.read(uiProvider.notifier).setActiveNav(NavItem.chat);
          ref.read(uiProvider.notifier).setSelectedPupKey(key);
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

  // ═══════════════════════════════════════════════════════════════════════════
  // Content area
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildContentArea(UIState uiState, OpenPupColors colors) {
    final nav = uiState.activeNav;

    Widget content;
    switch (nav) {
      case NavItem.chat:
        content = const ChatScreen();
        break;
      case NavItem.settings:
        content = const DesktopSettingsScreen();
        break;
      case NavItem.pups:
        content = const PupManagerScreen();
        break;
      case NavItem.mcp:
        content = const McpSettingsScreen();
        break;
      case NavItem.bridge:
        content = const BridgeSettingsScreen();
        break;
      case NavItem.skills:
        content = const SkillClawScreen();
        break;
      case NavItem.knowledge:
        content = const KnowledgeBaseScreen();
        break;
      case NavItem.memories:
        content = const MemoryScreen();
        break;
      case NavItem.timeline:
        content = const TimelineScreen();
        break;
      case NavItem.tasks:
        content = const TaskScreen();
        break;
      case NavItem.channel:
        content = const PackChannelScreen();
        break;
      case NavItem.groups:
        content = const GroupChatScreen();
        break;
      case NavItem.finance:
        content = const FinanceShell();
        break;
      default:
        content = Container(
          color: colors.backgroundPrimary,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_placeholderIcon(nav), size: 32, color: colors.textTertiary),
                const SizedBox(height: 8),
                Text(
                  ' — Phase ',
                  style: TextStyle(fontSize: 13, color: colors.textTertiary),
                ),
              ],
            ),
          ),
        );
    }

    return content;
  }

  IconData _placeholderIcon(NavItem nav) {
    switch (nav) {
      case NavItem.chat: return Icons.chat_bubble_outline;
      case NavItem.settings: return Icons.settings_outlined;
      case NavItem.finance: return Icons.show_chart;
      case NavItem.memories: return Icons.memory;
      case NavItem.timeline: return Icons.timeline;
      case NavItem.knowledge: return Icons.menu_book;
      case NavItem.tasks: return Icons.check_circle_outline;
      case NavItem.pups: return Icons.pets;
      case NavItem.skills: return Icons.extension;
      case NavItem.mcp: return Icons.cable;
      case NavItem.bridge: return Icons.lan;
      case NavItem.channel: return Icons.account_tree_outlined;
      case NavItem.groups: return Icons.groups;
    }
  }

  String _placeholderTitle(NavItem nav) {
    switch (nav) {
      case NavItem.chat: return 'Chat';
      case NavItem.settings: return 'Settings';
      case NavItem.finance: return 'Finance Workbench';
      case NavItem.memories: return 'Memories';
      case NavItem.timeline: return 'Timeline';
      case NavItem.knowledge: return 'Knowledge Base';
      case NavItem.tasks: return 'Tasks';
      case NavItem.pups: return 'Pup Manager';
      case NavItem.skills: return 'Skill Claw';
      case NavItem.mcp: return 'MCP Settings';
      case NavItem.bridge: return 'Bridge Settings';
      case NavItem.channel: return 'Pack Channel';
      case NavItem.groups: return 'Group Chat';
    }
  }

  int _placeholderPhase(NavItem nav) {
    switch (nav) {
      case NavItem.chat: return 3;
      case NavItem.channel: return 6;
      case NavItem.groups: return 7;
      case NavItem.finance: return 8;
      case NavItem.memories: case NavItem.timeline: case NavItem.tasks: return 5;
      case NavItem.knowledge: case NavItem.skills: case NavItem.pups:
      case NavItem.mcp: case NavItem.bridge: case NavItem.settings: return 4;
    }
  }
}

// ── Desktop collapsed dot ───────────────────────────────────────────────────
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
