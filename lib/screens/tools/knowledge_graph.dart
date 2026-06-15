import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';

/// Knowledge graph — replaces KnowledgeGraph.tsx.
///
/// Renders a force-directed graph of entities and their relationships.
/// TODO: Replace placeholder with CustomPainter + force simulation
/// (Phase 5 extension — D3.js equivalent).
class KnowledgeGraphScreen extends ConsumerWidget {
  const KnowledgeGraphScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return Container(
      color: colors.backgroundPrimary,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text('Knowledge Graph',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
                const Spacer(),
                Text('${0} entities',
                    style: TextStyle(fontSize: 11, color: colors.textTertiary)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Graph area placeholder
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hub_outlined, size: 40, color: colors.textTertiary),
                  const SizedBox(height: 12),
                  Text('Knowledge graph visualization',
                      style: TextStyle(fontSize: 13, color: colors.textTertiary)),
                  const SizedBox(height: 4),
                  Text('Powered by CustomPainter (D3.js replacement)',
                      style: TextStyle(fontSize: 11, color: colors.textTertiary)),
                  const SizedBox(height: 24),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: colors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.borderTertiary!, width: 0.5),
                    ),
                    child: CustomPaint(
                      painter: _GraphPlaceholderPainter(accent: colors.accent!, tertiary: colors.textTertiary!),
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

/// Placeholder painter that draws a simple network of dots and lines.
class _GraphPlaceholderPainter extends CustomPainter {
  final Color accent;
  final Color tertiary;

  _GraphPlaceholderPainter({required this.accent, required this.tertiary});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 3;

    // Draw connections
    final linePaint = Paint()
      ..color = tertiary.withOpacity(0.15)
      ..strokeWidth = 0.5;
    for (int i = 0; i < 6; i++) {
      final a = Offset(center.dx + r * cos(i * 2 * 3.1416 / 6),
          center.dy + r * sin(i * 2 * 3.1416 / 6));
      for (int j = i + 1; j < 6; j++) {
        final b = Offset(center.dx + r * cos(j * 2 * 3.1416 / 6),
            center.dy + r * sin(j * 2 * 3.1416 / 6));
        canvas.drawLine(a, b, linePaint);
      }
    }

    // Draw central node
    canvas.drawCircle(center, 6, Paint()..color = accent);
    canvas.drawCircle(center, 10, Paint()..color = accent.withOpacity(0.15));

    // Draw outer nodes
    for (int i = 0; i < 6; i++) {
      final pos = Offset(center.dx + r * cos(i * 2 * 3.1416 / 6),
          center.dy + r * sin(i * 2 * 3.1416 / 6));
      canvas.drawCircle(pos, 4, Paint()..color = accent.withOpacity(0.6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
