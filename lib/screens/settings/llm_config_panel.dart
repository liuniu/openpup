import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';

/// LLM Configuration panel — replaces App.tsx LlmConfigPanel.
///
/// Shows:
/// - Provider chips (with enable/disable, select for editing)
/// - Routing section (primary / mini / embedding model assignment)
/// - Provider editor modal (add/edit provider)
class LlmConfigPanel extends ConsumerWidget {
  const LlmConfigPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LLM Configuration',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),

        // Provider chips
        _buildProviderSection(context, colors),

        const SizedBox(height: 16),

        // Routing section
        _buildRoutingSection(colors),

        const SizedBox(height: 12),

        // Stats
        _buildStatsRow(colors),
      ],
    );
  }

  Widget _buildProviderSection(BuildContext context, OpenPupColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Provider chip list
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              // Placeholder for providers
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.borderSecondary!, width: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'OpenAI (Compatible)',
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _showProviderEditor(context, colors),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: colors.borderSecondary!, width: 0.5, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('+ New', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
          ),
        ),
      ],
    );
  }

  Widget _buildRoutingSection(OpenPupColors colors) {
    final models = ['gpt-4o', 'gpt-4o-mini', 'text-embedding-ada-002'];

    return Column(
      children: [
        _RoutingRow(
          label: 'Main Model',
          value: 'gpt-4o',
          provider: 'OpenAI',
          colors: colors,
          models: models,
        ),
        const SizedBox(height: 8),
        _RoutingRow(
          label: 'Mini Model',
          value: 'gpt-4o-mini',
          provider: 'OpenAI',
          colors: colors,
          models: models,
        ),
        const SizedBox(height: 8),
        _RoutingRow(
          label: 'Embedding',
          value: 'text-embedding-ada-002',
          provider: 'OpenAI',
          colors: colors,
          models: models,
        ),
      ],
    );
  }

  Widget _buildStatsRow(OpenPupColors colors) {
    return Row(
      children: [
        Text('1 provider', style: TextStyle(fontSize: 11, color: colors.textTertiary)),
        const SizedBox(width: 16),
        Text('1 ready', style: TextStyle(fontSize: 11, color: colors.textTertiary)),
        const SizedBox(width: 16),
        Text('3 routes', style: TextStyle(fontSize: 11, color: colors.textTertiary)),
        const Spacer(),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: colors.textPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('Save', style: TextStyle(fontSize: 13, color: colors.backgroundPrimary)),
          ),
        ),
      ],
    );
  }

  void _showProviderEditor(BuildContext context, OpenPupColors colors) {
    showDialog(
      context: context,
      builder: (ctx) => _ProviderEditorDialog(colors: colors),
    );
  }
}

// ── Routing row ─────────────────────────────────────────────────────────────

class _RoutingRow extends StatelessWidget {
  final String label;
  final String value;
  final String provider;
  final OpenPupColors colors;
  final List<String> models;

  const _RoutingRow({
    required this.label,
    required this.value,
    required this.provider,
    required this.colors,
    required this.models,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: TextStyle(fontSize: 12, color: colors.textTertiary)),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            decoration: BoxDecoration(
              border: Border.all(color: colors.borderSecondary!, width: 0.5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                // Provider segment
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: colors.borderSecondary!, width: 0.5)),
                  ),
                  child: Text(provider, style: TextStyle(fontSize: 12, color: colors.textPrimary)),
                ),
                // Model segment
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(value, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Provider editor dialog ──────────────────────────────────────────────────

class _ProviderEditorDialog extends StatefulWidget {
  final OpenPupColors colors;
  const _ProviderEditorDialog({required this.colors});

  @override
  State<_ProviderEditorDialog> createState() => _ProviderEditorDialogState();
}

class _ProviderEditorDialogState extends State<_ProviderEditorDialog> {
  final _idCtrl = TextEditingController(text: 'openai-compatible-main');
  final _nameCtrl = TextEditingController(text: 'OpenAI (Compatible)');
  final _baseCtrl = TextEditingController(text: 'https://api.openai.com/v1');
  final _keyCtrl = TextEditingController();
  final _modelsCtrl = TextEditingController(text: 'gpt-4o, gpt-4o-mini');

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    _baseCtrl.dispose();
    _keyCtrl.dispose();
    _modelsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    return Dialog(
      backgroundColor: colors.backgroundPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.borderPrimary!, width: 0.5),
      ),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Provider', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
            const SizedBox(height: 4),
            Text('OpenAI (Compatible)', style: TextStyle(fontSize: 11, color: colors.textTertiary)),
            const SizedBox(height: 16),

            _Field(label: 'ID', controller: _idCtrl, colors: colors),
            const SizedBox(height: 12),
            _Field(label: 'Name', controller: _nameCtrl, colors: colors),
            const SizedBox(height: 12),
            _Field(label: 'API Base', controller: _baseCtrl, colors: colors),
            const SizedBox(height: 12),
            _Field(label: 'API Key', controller: _keyCtrl, colors: colors, obscure: true),
            const SizedBox(height: 12),

            // Models
            Text('Models', style: TextStyle(fontSize: 12, color: colors.textTertiary)),
            const SizedBox(height: 4),
            TextField(
              controller: _modelsCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.borderSecondary!, width: 0.5),
                ),
                fillColor: colors.backgroundSecondary,
                filled: true,
              ),
              style: TextStyle(fontSize: 13, color: colors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text('Comma-separated model names', style: TextStyle(fontSize: 11, color: colors.textTertiary)),
            const SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
                    child: Text('Save', style: TextStyle(fontSize: 13, color: colors.backgroundPrimary, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final OpenPupColors colors;
  final bool obscure;

  const _Field({
    required this.label,
    required this.controller,
    required this.colors,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: colors.textTertiary)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
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
