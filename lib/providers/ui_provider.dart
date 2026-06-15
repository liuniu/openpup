import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/navigation_item.dart';

/// UI state — replaces Zustand uiStore.ts.
class UIState {
  final bool isDarkMode;
  final NavItem activeNav;
  final bool channelDetailMode;
  final bool sidebarCollapsed;
  final bool membersExpanded;
  final bool toolsExpanded;
  final bool configExpanded;
  final String selectedPupKey;

  const UIState({
    this.isDarkMode = true,
    this.activeNav = NavItem.chat,
    this.channelDetailMode = false,
    this.sidebarCollapsed = false,
    this.membersExpanded = true,
    this.toolsExpanded = false,
    this.configExpanded = false,
    this.selectedPupKey = 'alpha',
  });

  UIState copyWith({
    bool? isDarkMode,
    NavItem? activeNav,
    bool? channelDetailMode,
    bool? sidebarCollapsed,
    bool? membersExpanded,
    bool? toolsExpanded,
    bool? configExpanded,
    String? selectedPupKey,
  }) {
    return UIState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      activeNav: activeNav ?? this.activeNav,
      channelDetailMode: channelDetailMode ?? this.channelDetailMode,
      sidebarCollapsed: sidebarCollapsed ?? this.sidebarCollapsed,
      membersExpanded: membersExpanded ?? this.membersExpanded,
      toolsExpanded: toolsExpanded ?? this.toolsExpanded,
      configExpanded: configExpanded ?? this.configExpanded,
      selectedPupKey: selectedPupKey ?? this.selectedPupKey,
    );
  }
}

class UINotifier extends StateNotifier<UIState> {
  UINotifier() : super(const UIState());

  void toggleTheme() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void setActiveNav(NavItem nav) {
    state = state.copyWith(activeNav: nav);
    // Auto-expand sections
    const toolsItems = [
      NavItem.finance,
      NavItem.memories,
      NavItem.timeline,
      NavItem.tasks,
      NavItem.skills,
      NavItem.knowledge,
    ];
    const configItems = [
      NavItem.pups,
      NavItem.mcp,
      NavItem.bridge,
      NavItem.settings,
    ];
    if (toolsItems.contains(nav)) state = state.copyWith(toolsExpanded: true);
    if (configItems.contains(nav)) {
      state = state.copyWith(configExpanded: true);
    }
  }

  void toggleSidebar() {
    state = state.copyWith(sidebarCollapsed: !state.sidebarCollapsed);
  }

  void setToolsExpanded(bool expanded) {
    state = state.copyWith(toolsExpanded: expanded);
  }

  void setConfigExpanded(bool expanded) {
    state = state.copyWith(configExpanded: expanded);
  }

  void setSelectedPupKey(String key) {
    state = state.copyWith(selectedPupKey: key);
  }
}

final uiProvider = StateNotifierProvider<UINotifier, UIState>((ref) {
  return UINotifier();
});
