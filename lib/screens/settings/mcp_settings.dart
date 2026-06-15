import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';

/// MCP server management — replaces McpSettings.tsx.
class McpSettingsScreen extends ConsumerWidget {
  const McpSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return Container(
      color: colors.backgroundPrimary,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Text('MCP Servers',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAddServerDialog(context, colors),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.borderSecondary!, width: 0.5),
                  ),
                  child: Text('+ Add Server', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Empty state
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  Icon(Icons.cable, size: 32, color: colors.textTertiary),
                  const SizedBox(height: 8),
                  Text('No MCP servers configured',
                      style: TextStyle(fontSize: 13, color: colors.textTertiary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddServerDialog(BuildContext context, OpenPupColors colors) {
    showDialog(
      context: context,
      builder: (ctx) => _McpServerDialog(colors: colors),
    );
  }
}

class _McpServerDialog extends StatelessWidget {
  final OpenPupColors colors;
  const _McpServerDialog({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: colors.backgroundPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.borderPrimary!, width: 0.5),
      ),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add MCP Server', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
            const SizedBox(height: 16),
            _buildField('Name', colors),
            const SizedBox(height: 12),
            _buildField('Base URL', colors),
            const SizedBox(height: 12),
            _buildField('Token', colors, obscure: true),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.borderSecondary!, width: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Cancel', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: colors.textPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Add', style: TextStyle(fontSize: 13, color: colors.backgroundPrimary, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, OpenPupColors colors, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: colors.textTertiary)),
        const SizedBox(height: 4),
        TextField(
          obscureText: obscure,
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: const EdgeInsets.all(10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.borderSecondary!, width: 0.5),
            ),
            fillColor: colors.backgroundSecondary,
            filled: true,
          ),
          style: TextStyle(fontSize: 13, color: colors.textPrimary),
        ),
      ],
    );
  }
}
