import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pup_config.dart';
import '../models/navigation_item.dart';

/// Application-wide state — replaces Zustand appStore.ts.
class AppState {
  final bool? onboardingDone;
  final List<PupConfig> pups;
  final List<MemoryChip> memoryChips;
  final int kbSourceCount;
  final PermissionRequest? permissionRequest;
  final ContextStats? contextStats;
  final String execMode; // 'leashed' | 'free_run'

  const AppState({
    this.onboardingDone,
    this.pups = const [],
    this.memoryChips = const [],
    this.kbSourceCount = 0,
    this.permissionRequest,
    this.contextStats,
    this.execMode = 'leashed',
  });

  AppState copyWith({
    bool? Function()? onboardingDone,
    List<PupConfig>? pups,
    List<MemoryChip>? memoryChips,
    int? kbSourceCount,
    PermissionRequest? Function()? permissionRequest,
    ContextStats? Function()? contextStats,
    String? execMode,
  }) {
    return AppState(
      onboardingDone:
          onboardingDone != null ? onboardingDone() : this.onboardingDone,
      pups: pups ?? this.pups,
      memoryChips: memoryChips ?? this.memoryChips,
      kbSourceCount: kbSourceCount ?? this.kbSourceCount,
      permissionRequest: permissionRequest != null
          ? permissionRequest()
          : this.permissionRequest,
      contextStats:
          contextStats != null ? contextStats() : this.contextStats,
      execMode: execMode ?? this.execMode,
    );
  }
}

class AppNotifier extends StateNotifier<AppState> {
  AppNotifier() : super(const AppState());

  void setOnboardingDone(bool done) {
    state = state.copyWith(onboardingDone: () => done);
  }

  void setPups(List<PupConfig> pups) {
    state = state.copyWith(pups: pups);
  }

  void setMemoryChips(List<MemoryChip> chips) {
    state = state.copyWith(memoryChips: chips);
  }

  void setKbSourceCount(int count) {
    state = state.copyWith(kbSourceCount: count);
  }

  void setPermissionRequest(PermissionRequest? request) {
    state = state.copyWith(permissionRequest: () => request);
  }

  void setContextStats(ContextStats? stats) {
    state = state.copyWith(contextStats: () => stats);
  }

  void setExecMode(String mode) {
    state = state.copyWith(execMode: mode);
  }
}

final appProvider = StateNotifierProvider<AppNotifier, AppState>((ref) {
  return AppNotifier();
});