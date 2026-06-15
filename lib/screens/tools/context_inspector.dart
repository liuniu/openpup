import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';

/// Context inspector — replaces ContextInspector.tsx.
///
/// Shows detailed context stats per pup (token usage, message count,
/// compression status).
class ContextInspectorScreen extends ConsumerWidget {
  const ContextInspectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return Container(
      color: colors.backgroundPrimary,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 32, color: colors.textTertiary),
            const SizedBox(height: 8),
            Text('Context Inspector — Phase 5',
                style: TextStyle(fontSize: 13, color: colors.textTertiary)),
          ],
        ),
      ),
    );
  }
}
