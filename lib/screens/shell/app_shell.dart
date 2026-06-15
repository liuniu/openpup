import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'titlebar.dart';
import 'sidebar.dart';
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
import '../../utils/pup_visuals.dart';

/// Main app shell — titlebar + sidebar + content area + overlays.
///
/// Replaces AppInner in App.tsx with full Flutter idioms.
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
  bool _isMaximized = false;
  late bool _isDesktop;

  @override
  void initState() {
    super.initState();
    _isDesktop = !(Platform.isAndroid || Platform.isIOS);
    if (_isDesktop) _initWindowState();
  }

  Future<void> _initWindowState() async {
    try {
      final maximized = await windowManager.isMaximized();
      if (mounted) setState(() => _isMaximized = maximized);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(uiProvider);
    final appState = ref.watch(appProvider);

    return Scaffold(
      body: Stack(
        children: [
          // ── Main layout ──────────────────────────────────────────────
          Column(
            children: [
              // Custom titlebar (desktop only)
              if (_isDesktop)
                OpenPupTitlebar(
                  onToggleSidebar: () =>
                      ref.read(uiProvider.notifier).toggleSidebar(),
                  onToggleTheme: () {
                    ref.read(uiProvider.notifier).toggleTheme();
                    widget.onThemeChanged?.call(
                      uiState.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                    );
                  },
                ),

              // Sidebar + Content
              Expanded(
                child: Row(
                  children: [
                    // Sidebar with collapse animation
                    if (uiState.sidebarCollapsed)
                      _CollapsedSidebarStrip(colors: Theme.of(context).extension<OpenPupColors>()!)
                    else
                      const OpenPupSidebar(width: 196),

                    // Content area with route transition
                    Expanded(
                      child: _buildContentArea(uiState),
                    ),
                  ],
                ),
              ),

              // Bottom status bar
              const StatusBar(),
            ],
          ),

          // ── Permission overlay ────────────────────────────────────────
          if (appState.permissionRequest != null)
            PermissionOverlay(
              request: appState.permissionRequest!,
            ),
        ],
      ),
    );
  }

  // ── Collapsed sidebar strip ─────────────────────────────────────────────
  Widget _CollapsedSidebarStrip({required OpenPupColors colors}) {
    return Container(
      width: 48,
      decoration: BoxDecoration(
        color: colors.backgroundPrimary,
        border: Border(
          right: BorderSide(color: colors.borderTertiary!, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Alpha dot
          _CollapsedDot(
            color: colors.accent!,
            onTap: () {
              ref.read(uiProvider.notifier).setActiveNav(NavItem.chat);
              ref.read(uiProvider.notifier).setSelectedPupKey('alpha');
            },
          ),
          // Other pup dots
          for (final pup in ref.watch(appProvider).pups.where((p) => p.key != 'alpha'))
            _CollapsedDot(
              color: pupAccentColor(pup.key),
              onTap: () {
                ref.read(uiProvider.notifier).setActiveNav(NavItem.chat);
                ref.read(uiProvider.notifier).setSelectedPupKey(pup.key);
              },
            ),
          const Spacer(),
          // Expand button
          GestureDetector(
            onTap: () => ref.read(uiProvider.notifier).toggleSidebar(),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.chevron_right,
                  size: 14, color: colors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }

  // ── Content area with AnimatedSwitcher transition ─────────────────────
  Widget _buildContentArea(UIState uiState) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: _contentForNav(uiState.activeNav),
    );
  }

  /// Returns the content widget for the given nav item.
  /// Each gets a unique [Key] so AnimatedSwitcher can diff them.
  Widget _contentForNav(NavItem nav) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;
    final keys = {
      NavItem.chat: const Key('chat'),
      NavItem.channel: const Key('channel'),
      NavItem.groups: const Key('groups'),
      NavItem.finance: const Key('finance'),
      NavItem.memories: const Key('memories'),
      NavItem.timeline: const Key('timeline'),
      NavItem.skills: const Key('skills'),
      NavItem.pups: const Key('pups'),
      NavItem.tasks: const Key('tasks'),
      NavItem.mcp: const Key('mcp'),
      NavItem.bridge: const Key('bridge'),
      NavItem.settings: const Key('settings'),
      NavItem.knowledge: const Key('knowledge'),
    };

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
                  '${_placeholderTitle(nav)} — Phase ${_placeholderPhase(nav)}',
                  style: TextStyle(fontSize: 13, color: colors.textTertiary),
                ),
              ],
            ),
          ),
        );
    }

    return SizedBox(key: keys[nav], child: content);
  }

  IconData _placeholderIcon(NavItem nav) {
    switch (nav) {
      case NavItem.chat:
        return Icons.chat_bubble_outline;
      case NavItem.settings:
        return Icons.settings_outlined;
      case NavItem.finance:
        return Icons.show_chart;
      case NavItem.memories:
        return Icons.memory;
      case NavItem.timeline:
        return Icons.timeline;
      case NavItem.knowledge:
        return Icons.menu_book;
      case NavItem.tasks:
        return Icons.check_circle_outline;
      case NavItem.pups:
        return Icons.pets;
      case NavItem.skills:
        return Icons.extension;
      case NavItem.mcp:
        return Icons.cable;
      case NavItem.bridge:
        return Icons.lan;
      case NavItem.channel:
        return Icons.account_tree_outlined;
      case NavItem.groups:
        return Icons.groups;
    }
  }

  String _placeholderTitle(NavItem nav) {
    switch (nav) {
      case NavItem.chat:
        return 'Chat';
      case NavItem.settings:
        return 'Settings';
      case NavItem.finance:
        return 'Finance Workbench';
      case NavItem.memories:
        return 'Memories';
      case NavItem.timeline:
        return 'Timeline';
      case NavItem.knowledge:
        return 'Knowledge Base';
      case NavItem.tasks:
        return 'Tasks';
      case NavItem.pups:
        return 'Pup Manager';
      case NavItem.skills:
        return 'Skill Claw';
      case NavItem.mcp:
        return 'MCP Settings';
      case NavItem.bridge:
        return 'Bridge Settings';
      case NavItem.channel:
        return 'Pack Channel';
      case NavItem.groups:
        return 'Group Chat';
    }
  }

  int _placeholderPhase(NavItem nav) {
    switch (nav) {
      case NavItem.chat:
        return 3;
      case NavItem.channel:
        return 6;
      case NavItem.groups:
        return 7;
      case NavItem.finance:
        return 8;
      case NavItem.memories:
      case NavItem.timeline:
      case NavItem.tasks:
        return 5;
      case NavItem.knowledge:
      case NavItem.skills:
      case NavItem.pups:
      case NavItem.mcp:
      case NavItem.bridge:
      case NavItem.settings:
        return 4;
    }
  }
}

// ── Tiny collapsed-sidebar dot ──────────────────────────────────────────────

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
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}