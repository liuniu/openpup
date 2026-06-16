import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../config/llm_config.dart';

/// Onboarding flow — first-run wizard.
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

  final _steps = const ['Welcome', 'About You', 'Done'];

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
          child: Column(
            children: [
              // Step indicator
              _StepIndicator(
                total: _steps.length,
                current: _step,
                labels: _steps,
                colors: colors,
              ),

              const SizedBox(height: 32),

              // Content area
              Expanded(
                child: _buildStepContent(colors),
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _step--),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textSecondary,
                          side: BorderSide(color: colors.borderSecondary!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: _step > 0 ? 2 : 1,
                    child: ElevatedButton(
                      onPressed: _step < _steps.length - 1 ? _next : _finish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: Text(
                        _step < _steps.length - 1
                            ? 'Continue'
                            : (_saving ? 'Setting up...' : 'Get Started'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
        return _buildDone(colors);
      default:
        return const SizedBox();
    }
  }

  Widget _buildWelcome(OpenPupColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colors.accent!.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.pets, size: 40, color: colors.accent),
        ),
        const SizedBox(height: 28),
        Text(
          'openpup',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your local AI companion that remembers\nwho you are and works by your side.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: colors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.borderTertiary!),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 18, color: colors.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'LLM:  ()',
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutYou(OpenPupColors colors) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About you',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This helps me personalise your experience.',
            style: TextStyle(fontSize: 13, color: colors.textTertiary),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Your name',
              hintText: 'e.g. Alex',
              labelStyle: TextStyle(fontSize: 13, color: colors.textTertiary),
              hintStyle: TextStyle(fontSize: 13, color: colors.textTertiary!.withOpacity(0.4)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.borderSecondary!, width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.borderSecondary!, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.accent!, width: 1),
              ),
              fillColor: colors.backgroundSecondary,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            style: TextStyle(fontSize: 15, color: colors.textPrimary),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'A bit about you (optional)',
              hintText: 'e.g. I am a software developer who loves hiking...',
              labelStyle: TextStyle(fontSize: 13, color: colors.textTertiary),
              hintStyle: TextStyle(fontSize: 13, color: colors.textTertiary!.withOpacity(0.4)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.borderSecondary!, width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.borderSecondary!, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.accent!, width: 1),
              ),
              fillColor: colors.backgroundSecondary,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            style: TextStyle(fontSize: 15, color: colors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildDone(OpenPupColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colors.accent!.withOpacity(0.12),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(Icons.check_circle_rounded, size: 48, color: colors.accent),
        ),
        const SizedBox(height: 24),
        Text(
          'All set!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Your AI companion is ready to help.\nTap "Get Started" to begin.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: colors.textSecondary, height: 1.6),
        ),
      ],
    );
  }

  void _next() => setState(() => _step++);

  Future<void> _finish() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      ref.read(appProvider.notifier).setOnboardingDone(true);
      widget.onComplete();
    }
  }
}

/// Step indicator bar.
class _StepIndicator extends StatelessWidget {
  final int total;
  final int current;
  final List<String> labels;
  final OpenPupColors colors;

  const _StepIndicator({
    required this.total,
    required this.current,
    required this.labels,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final step = i ~/ 2;
          final done = step < current;
          return Container(
            width: 48,
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: done ? colors.accent : colors.borderTertiary,
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }
        // Step dot
        final step = i ~/ 2;
        final isDone = step < current;
        final isCurrent = step == current;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isCurrent ? 32 : 28,
              height: isCurrent ? 32 : 28,
              decoration: BoxDecoration(
                color: isDone
                    ? colors.accent
                    : isCurrent
                        ? colors.accent!.withOpacity(0.15)
                        : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone || isCurrent
                      ? colors.accent!
                      : colors.borderTertiary!,
                  width: isCurrent ? 2 : 1.5,
                ),
              ),
              child: Center(
                child: isDone
                    ? Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isCurrent ? colors.accent : colors.textTertiary,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              labels[step],
              style: TextStyle(
                fontSize: 10,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                color: isCurrent ? colors.textPrimary : colors.textTertiary,
              ),
            ),
          ],
        );
      }),
    );
  }
}
