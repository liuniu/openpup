import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../bridge/rust_bridge.dart';

/// Onboarding flow — replaces Onboarding.tsx.
///
/// First-run wizard: welcome → identify → configure → done.
class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _saving = false;

  final _steps = ['Welcome', 'About You', 'Configure', 'Done'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Steps indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _steps.asMap().entries.map((entry) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StepDot(
                        index: entry.key,
                        current: _step,
                        colors: colors,
                      ),
                      if (entry.key < _steps.length - 1)
                        Container(
                          width: 40,
                          height: 2,
                          color: entry.key < _step
                              ? colors.accent
                              : colors.borderTertiary,
                        ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),

              // Content
              Expanded(child: _buildStepContent(colors)),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_step > 0)
                    TextButton(
                      onPressed: () => setState(() => _step--),
                      child: Text('Back', style: TextStyle(color: colors.textSecondary)),
                    )
                  else
                    const SizedBox(),
                  ElevatedButton(
                    onPressed: _step < _steps.length - 1 ? _next : _finish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      _step < _steps.length - 1 ? 'Continue' : (_saving ? 'Setting up…' : 'Get Started'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(OpenPupColors colors) {
    switch (_step) {
      case 0:
        return _buildWelcome(colors);
      case 1:
        return _buildAboutYou(colors);
      case 2:
        return _buildConfigure(colors);
      case 3:
        return _buildDone(colors);
      default:
        return const SizedBox();
    }
  }

  Widget _buildWelcome(OpenPupColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'openpup',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: colors.accent,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'A local AI companion that remembers who you are.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: colors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 24),
        Icon(Icons.pets, size: 64, color: colors.accent!.withOpacity(0.3)),
      ],
    );
  }

  Widget _buildAboutYou(OpenPupColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Tell me about yourself',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary)),
        const SizedBox(height: 4),
        Text(
          'This helps me personalise your experience.',
          style: TextStyle(fontSize: 12, color: colors.textTertiary),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameCtrl,
          decoration: InputDecoration(
            labelText: 'Your name',
            labelStyle: TextStyle(fontSize: 12, color: colors.textTertiary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.borderSecondary!, width: 0.5),
            ),
            fillColor: colors.backgroundSecondary,
            filled: true,
          ),
          style: TextStyle(fontSize: 14, color: colors.textPrimary),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'A bit about you (optional)',
            labelStyle: TextStyle(fontSize: 12, color: colors.textTertiary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.borderSecondary!, width: 0.5),
            ),
            fillColor: colors.backgroundSecondary,
            filled: true,
          ),
          style: TextStyle(fontSize: 14, color: colors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildConfigure(OpenPupColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Configure your LLM',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary)),
        const SizedBox(height: 4),
        Text(
          'Set up your first LLM provider to get started.',
          style: TextStyle(fontSize: 12, color: colors.textTertiary),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.backgroundSecondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'API Base URL',
                  labelStyle: TextStyle(fontSize: 12, color: colors.textTertiary),
                  hintText: 'https://api.openai.com/v1',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.all(10),
                ),
                style: TextStyle(fontSize: 13, color: colors.textPrimary),
              ),
              const SizedBox(height: 8),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  labelStyle: TextStyle(fontSize: 12, color: colors.textTertiary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.all(10),
                ),
                style: TextStyle(fontSize: 13, color: colors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDone(OpenPupColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle, size: 64, color: colors.accent),
        const SizedBox(height: 16),
        Text('All set!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: colors.textPrimary)),
        const SizedBox(height: 8),
        Text(
          'Your AI companion is ready to help.',
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        ),
      ],
    );
  }

  void _next() => setState(() => _step++);

  Future<void> _finish() async {
    setState(() => _saving = true);
    // TODO: call save_onboarding_data via rust bridge
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      ref.read(appProvider.notifier).setOnboardingDone(true);
      widget.onComplete();
    }
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final int current;
  final OpenPupColors colors;

  const _StepDot({required this.index, required this.current, required this.colors});

  @override
  Widget build(BuildContext context) {
    final isDone = index < current;
    final isCurrent = index == current;

    return Container(
      width: isCurrent ? 12 : 8,
      height: isCurrent ? 12 : 8,
      decoration: BoxDecoration(
        color: isDone ? colors.accent : (isCurrent ? colors.accent : colors.borderTertiary),
        shape: BoxShape.circle,
      ),
    );
  }
}
