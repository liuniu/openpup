/// Financial data models — maps to stores/financeStore.ts interfaces.

class FinanceOverviewSnapshot {
  final int activeOrderCount;
  final int todayTradeCount;
  // Simplified — expand as needed

  const FinanceOverviewSnapshot({
    this.activeOrderCount = 0,
    this.todayTradeCount = 0,
  });

  factory FinanceOverviewSnapshot.fromJson(Map<String, dynamic> json) =>
      FinanceOverviewSnapshot(
        activeOrderCount: json['active_order_count'] as int? ?? 0,
        todayTradeCount: json['today_trade_count'] as int? ?? 0,
      );
}

class WatchlistItem {
  final String code;
  final String name;
  final double? price;
  final double? changePct;

  const WatchlistItem({
    required this.code,
    required this.name,
    this.price,
    this.changePct,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) => WatchlistItem(
        code: json['code'] as String,
        name: json['name'] as String,
        price: (json['price'] as num?)?.toDouble(),
        changePct: (json['change_pct'] as num?)?.toDouble(),
      );
}
