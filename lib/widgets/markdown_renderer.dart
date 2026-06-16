import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../theme/app_theme.dart';

/// Markdown renderer — replaces react-markdown + rehype-highlight.
class AppMarkdownRenderer extends StatelessWidget {
  final String data;
  final bool shrinkWrap;

  const AppMarkdownRenderer({
    super.key,
    required this.data,
    this.shrinkWrap = true,  // Default to true for safe nesting
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<OpenPupColors>()!;

    return Markdown(
      data: data,
      shrinkWrap: shrinkWrap,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(fontSize: 13, color: colors.textPrimary, height: 1.6),
        h1: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary),
        h2: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary),
        h3: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
        strong: TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary),
        em: TextStyle(fontStyle: FontStyle.italic, color: colors.textPrimary),
        del: TextStyle(decoration: TextDecoration.lineThrough, color: colors.textTertiary),
        a: TextStyle(color: colors.link, decoration: TextDecoration.underline),
        listBullet: TextStyle(fontSize: 13, color: colors.textSecondary),
        code: TextStyle(
          fontSize: 12,
          fontFamily: 'monospace',
          color: colors.textPrimary,
          backgroundColor: colors.backgroundSecondary,
        ),
        codeblockDecoration: BoxDecoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.borderSecondary!, width: 0.5),
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(left: BorderSide(color: colors.accent!, width: 3)),
          color: colors.backgroundSecondary,
        ),
        blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        tableBorder: TableBorder.all(color: colors.borderSecondary!, width: 0.5),
        tableHead: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: colors.textPrimary),
        tableBody: TextStyle(fontSize: 12, color: colors.textSecondary),
        tableCellsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.borderTertiary!, width: 0.5)),
        ),
        checkbox: TextStyle(color: colors.accent),
      ),
    );
  }
}
