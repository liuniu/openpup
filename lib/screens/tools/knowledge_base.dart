import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';

/// Knowledge base manager — replaces KnowledgeBase.tsx + KnowledgeSettings.tsx.
class KnowledgeBaseScreen extends ConsumerWidget {
  const KnowledgeBaseScreen({super.key});

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
              Text('Knowledge Base',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.borderSecondary!, width: 0.5),
                  ),
                  child: Text('+ Ingest File', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.borderSecondary!, width: 0.5),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 16, color: colors.textTertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search knowledge base…',
                      hintStyle: TextStyle(fontSize: 13, color: colors.textTertiary),
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: TextStyle(fontSize: 13, color: colors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Empty state
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  Icon(Icons.menu_book, size: 32, color: colors.textTertiary),
                  const SizedBox(height: 8),
                  Text('No documents ingested', style: TextStyle(fontSize: 13, color: colors.textTertiary)),
                  const SizedBox(height: 4),
                  Text('Import PDF, TXT, or Markdown files',
                      style: TextStyle(fontSize: 11, color: colors.textTertiary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
