import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/finance_models.dart';

/// Finance state — replaces Zustand financeStore.ts.
class FinanceState {
  final String activeTab; // 'overview' | 'research' | 'orders' | 'pipeline'
  final FinanceOverviewSnapshot? overview;
  final List<WatchlistItem> watchlist;
  final String? error;

  const FinanceState({
    this.activeTab = 'overview',
    this.overview,
    this.watchlist = const [],
    this.error,
  });

  FinanceState copyWith({
    String? activeTab,
    FinanceOverviewSnapshot? Function()? overview,
    List<WatchlistItem>? watchlist,
    String? Function()? error,
  }) {
    return FinanceState(
      activeTab: activeTab ?? this.activeTab,
      overview: overview != null ? overview() : this.overview,
      watchlist: watchlist ?? this.watchlist,
      error: error != null ? error() : this.error,
    );
  }
}

class FinanceNotifier extends StateNotifier<FinanceState> {
  FinanceNotifier() : super(const FinanceState());

  void setActiveTab(String tab) {
    state = state.copyWith(activeTab: tab);
  }

  void setOverview(FinanceOverviewSnapshot? overview) {
    state = state.copyWith(overview: () => overview);
  }

  void setWatchlist(List<WatchlistItem> watchlist) {
    state = state.copyWith(watchlist: watchlist);
  }

  void setError(String? error) {
    state = state.copyWith(error: () => error);
  }
}

final financeProvider =
    StateNotifierProvider<FinanceNotifier, FinanceState>((ref) {
  return FinanceNotifier();
});
