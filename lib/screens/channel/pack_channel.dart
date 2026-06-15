import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'channel_list.dart';
import 'channel_detail.dart';

/// Pack Channel root — manages list ↔ detail navigation.
///
/// Replaces PackChannel.tsx with its `detailMode` toggle.
class PackChannelScreen extends ConsumerStatefulWidget {
  const PackChannelScreen({super.key});

  @override
  ConsumerState<PackChannelScreen> createState() => _PackChannelScreenState();
}

class _PackChannelScreenState extends ConsumerState<PackChannelScreen> {
  String? _activeChannelId;

  void _openChannel(String id) {
    setState(() => _activeChannelId = id);
  }

  void _goBack() {
    setState(() => _activeChannelId = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_activeChannelId != null) {
      return ChannelDetailScreen(
        key: ValueKey(_activeChannelId),
        channelId: _activeChannelId!,
      );
    }

    return ChannelListScreen(onOpenChannel: _openChannel);
  }
}
