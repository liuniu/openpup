import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/navigation_item.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

/// Permission request overlay — replaces PermissionDialog.tsx.
///
/// Dark modal overlay with approval/deny controls.
/// Appears on top of all content when `appState.permissionRequest != null`.
class PermissionOverlay extends ConsumerWidget {
  final PermissionRequest request;

  const PermissionOverlay({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return GestureDetector(
      onTap: () {}, // Don't dismiss on background tap for security
      child: Container(
        color: Colors.black.withOpacity(0.28),
        child: Center(
          child: Container(
            width: 400,
            constraints: const BoxConstraints(maxHeight: 360),
            decoration: BoxDecoration(
              color: colors.backgroundPrimary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.borderPrimary!, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  blurRadius: 48,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined,
                          size: 18, color: _riskColor(colors)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _riskLabel(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _riskColor(colors),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Skill / command description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    request.description.isNotEmpty
                        ? request.description
                        : '${request.skillName} 请求执行操作',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Risk level badge
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _riskColor(colors).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Risk: ${request.riskLevel.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _riskColor(colors),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // "Remember" checkbox
                      StatefulBuilder(
                        builder: (context, setLocalState) {
                          bool remember = false;
                          return Row(
                            children: [
                              SizedBox(
                                height: 18,
                                width: 18,
                                child: Checkbox(
                                  value: remember,
                                  onChanged: (v) =>
                                      setLocalState(() => remember = v ?? false),
                                  side: BorderSide(color: colors.borderSecondary!),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Remember this decision',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                ref
                                    .read(appProvider.notifier)
                                    .setPermissionRequest(null);
                                // TODO: call deny_permission on Rust backend
                              },
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                side: BorderSide(color: colors.borderSecondary!),
                              ),
                              child: Text(
                                'Deny',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(appProvider.notifier)
                                    .setPermissionRequest(null);
                                // TODO: call approve_permission on Rust backend
                              },
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                backgroundColor: colors.accent,
                                foregroundColor: colors.backgroundPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Approve',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _riskColor(OpenPupColors colors) {
    switch (request.riskLevel) {
      case 'high':
        return colors.textDanger!;
      case 'medium':
        return colors.textWarning!;
      default:
        return colors.accent!;
    }
  }

  String _riskLabel() {
    switch (request.riskLevel) {
      case 'high':
        return 'High-Risk Action Required';
      case 'medium':
        return 'Medium-Risk Action';
      default:
        return 'Low-Risk Action';
    }
  }
}
