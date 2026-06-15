import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../../providers/chat_provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

/// Custom window titlebar — replaces the titlebar in App.tsx.
///
/// macOS: extended left drag region for traffic lights (78px inset).
/// Windows/Linux: hamburger + title + center stats + window buttons.
class OpenPupTitlebar extends ConsumerStatefulWidget {
  final VoidCallback onToggleSidebar;
  final VoidCallback onToggleTheme;

  const OpenPupTitlebar({
    super.key,
    required this.onToggleSidebar,
    required this.onToggleTheme,
  });

  @override
  ConsumerState<OpenPupTitlebar> createState() => _OpenPupTitlebarState();
}

class _OpenPupTitlebarState extends ConsumerState<OpenPupTitlebar> {
  bool _isMaximized = false;
  bool _isMacOS = false;

  @override
  void initState() {
    super.initState();
    _isMacOS = Platform.isMacOS;
    _initWindowState();
  }

  Future<void> _initWindowState() async {
    try {
      final maximized = await windowManager.isMaximized();
      if (mounted) setState(() => _isMaximized = maximized);
      windowManager.addListener(_onWindowEvent);
    } catch (_) {}
  }

  void _onWindowEvent() {
    windowManager.isMaximized().then((maximized) {
      if (mounted) setState(() => _isMaximized = maximized);
    });
  }

  @override
  void dispose() {
    try {
      windowManager.removeListener(_onWindowEvent);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;
    final appState = ref.watch(appProvider);
    final chatState = ref.watch(chatProvider);

    // macOS: extra left padding for native traffic lights, no window buttons
    final double leftPad = _isMacOS ? 78 : 12;
    final EdgeInsetsGeometry rightPad = _isMacOS
        ? const EdgeInsets.only(right: 12)
        : EdgeInsets.zero;

    return GestureDetector(
      // Double-click titlebar to toggle maximize (Windows behaviour)
      onDoubleTap: () async {
        if (!_isMacOS) {
          await windowManager.isMaximized().then((max) =>
              max ? windowManager.unmaximize() : windowManager.maximize());
        }
      },
      child: Container(
        height: 35,
        padding: EdgeInsets.only(left: leftPad),
        decoration: BoxDecoration(
          color: colors.backgroundSecondary,
          border: Border(
            bottom: BorderSide(color: colors.borderTertiary!, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Sidebar toggle (hidden on macOS — conflicts with traffic lights)
            if (!_isMacOS) ...[
              GestureDetector(
                onTap: widget.onToggleSidebar,
                child: Icon(Icons.menu, size: 14, color: colors.textSecondary),
              ),
              const SizedBox(width: 8),
            ],

            // App title (draggable)
            SizedBox(
              // Drag region for custom titlebar
              onTap: () {},
              onPanStart: (_) {},
              child: Text.rich(
                TextSpan(
                  text: 'open',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                  children: [
                    TextSpan(
                      text: 'pup',
                      style: TextStyle(color: colors.accent),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Context stats
            if (appState.contextStats != null)
              ..._buildContextStats(context, appState),

            // Token usage
            if (chatState.tokenUsage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _TokenUsageDisplay(
                  promptTokens: chatState.tokenUsage!.promptTokens,
                  completionTokens: chatState.tokenUsage!.completionTokens,
                ),
              ),

            // Theme toggle
            GestureDetector(
              onTap: widget.onToggleTheme,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.light_mode_outlined,
                  size: 13,
                  color: colors.textTertiary,
                ),
              ),
            ),

            // Window controls (Windows/Linux only)
            if (!_isMacOS) ..._buildWindowControls(colors),
          ],
        ),
      ),
    );
  }

  // ── Context stats (centre) ──────────────────────────────────────────────
  List<Widget> _buildContextStats(BuildContext context, AppState appState) {
    final stats = appState.contextStats!;
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    final ratio = stats.contextLimit > 0
        ? stats.contextTokens / stats.contextLimit
        : 0.0;
    final ratioColor = ratio > 0.8
        ? colors.textDanger!
        : ratio > 0.5
            ? colors.textWarning!
            : colors.textTertiary!;

    return [
      Text(
        '${_fmt(stats.contextTokens)}/${_fmt(stats.contextLimit)} ctx',
        style: TextStyle(
          fontSize: 10,
          fontFamily: 'monospace',
          color: ratioColor,
        ),
      ),
      if (stats.compressionStatus.isCompressed)
        Text(
          ' compressed',
          style: TextStyle(fontSize: 9, color: colors.textTertiary),
        ),
      if (!stats.compressionStatus.isCompressed && stats.messageCount > 10)
        GestureDetector(
          onTap: () {
            // TODO: invoke compress_pup_context on Rust backend
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Icon(Icons.compress, size: 10, color: colors.textTertiary),
          ),
        ),
    ];
  }

  // ── Window control buttons ──────────────────────────────────────────────
  List<Widget> _buildWindowControls(OpenPupColors colors) {
    return [
      const SizedBox(width: 8),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _WinBtn(
            icon: Icons.minimize,
            onTap: () => windowManager.minimize(),
            color: colors.textTertiary!,
          ),
          _WinBtn(
            icon: _isMaximized ? Icons.filter_none : Icons.crop_square,
            onTap: () => windowManager.isMaximized().then((max) =>
                max ? windowManager.unmaximize() : windowManager.maximize()),
            color: colors.textTertiary!,
          ),
          _WinBtn(
            icon: Icons.close,
            onTap: () => windowManager.close(),
            color: colors.textTertiary!,
            hoverColor: Colors.red,
          ),
        ],
      ),
    ];
  }

  String _fmt(int n) {
    if (n >= 1_000_000) return '${(n / 1_000_000).toStringAsFixed(1)}M';
    if (n >= 1_000) return '${(n / 1_000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

// ── Token usage indicator ────────────────────────────────────────────────────
class _TokenUsageDisplay extends StatelessWidget {
  final int promptTokens;
  final int completionTokens;
  const _TokenUsageDisplay(
      {required this.promptTokens, required this.completionTokens});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;
    final f = (int n) {
      if (n >= 1_000_000) return '${(n / 1_000_000).toStringAsFixed(1)}M';
      if (n >= 1_000) return '${(n / 1_000).toStringAsFixed(1)}k';
      return n.toString();
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.arrow_drop_up, size: 10, color: colors.textSuccess),
        Text(f(promptTokens),
            style: TextStyle(fontSize: 10, color: colors.textTertiary)),
        const SizedBox(width: 6),
        Icon(Icons.arrow_drop_down, size: 10, color: colors.textWarning),
        Text(f(completionTokens),
            style: TextStyle(fontSize: 10, color: colors.textTertiary)),
      ],
    );
  }
}

// ── Window button ────────────────────────────────────────────────────────────
class _WinBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color? hoverColor;
  const _WinBtn(
      {required this.icon,
      required this.onTap,
      required this.color,
      this.hoverColor});

  @override
  State<_WinBtn> createState() => _WinBtnState();
}

class _WinBtnState extends State<_WinBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: 46,
          height: 35,
          color: _hovered
              ? (widget.hoverColor ?? Colors.white.withOpacity(0.12))
              : Colors.transparent,
          child: Icon(
            widget.icon,
            size: 12,
            color: _hovered && widget.hoverColor != null
                ? Colors.white
                : widget.color,
          ),
        ),
      ),
    );
  }
}
