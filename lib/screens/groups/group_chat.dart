import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'group_list.dart';
import 'group_detail.dart';

/// Group Chat root — manages list ↔ detail navigation.
class GroupChatScreen extends ConsumerStatefulWidget {
  const GroupChatScreen({super.key});

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
  String? _activeSpaceId;

  void _openSpace(String id) => setState(() => _activeSpaceId = id);
  void _goBack() => setState(() => _activeSpaceId = null);

  @override
  Widget build(BuildContext context) {
    if (_activeSpaceId != null) {
      return GroupDetailScreen(
        key: ValueKey(_activeSpaceId),
        spaceId: _activeSpaceId!,
      );
    }
    return GroupListScreen(onOpenSpace: _openSpace);
  }
}
