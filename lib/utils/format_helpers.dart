/// Formatting utilities — replaces inline formatting in App.tsx.

/// Format large token numbers.
String formatTokens(int n) {
  if (n >= 1_000_000) return '${(n / 1_000_000).toStringAsFixed(1)}M';
  if (n >= 1_000) return '${(n / 1_000).toStringAsFixed(1)}k';
  return n.toString();
}
