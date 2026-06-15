import 'package:flutter_test/flutter_test.dart';
import 'package:openpup/models/chat_message.dart';
import 'package:openpup/models/pup_config.dart';
import 'package:openpup/models/navigation_item.dart';
import 'package:openpup/models/channel_models.dart';
import 'package:openpup/models/conversation_models.dart';
import 'package:openpup/models/finance_models.dart';

void main() {
  group('ChatMessage', () {
    test('fromJson creates correct message', () {
      final json = {
        'id': 'msg-1',
        'role': 'user',
        'content': 'Hello',
        'pup_key': 'alpha',
        'pup_name': 'Alpha',
      };
      final msg = ChatMessage.fromJson(json);
      expect(msg.id, 'msg-1');
      expect(msg.role, 'user');
      expect(msg.content, 'Hello');
      expect(msg.pupKey, 'alpha');
    });

    test('toJson round-trips correctly', () {
      final msg = ChatMessage(
        id: 'msg-2',
        role: 'assistant',
        content: 'Hi there!',
        pupKey: 'alpha',
        pupName: 'Alpha',
      );
      final json = msg.toJson();
      final restored = ChatMessage.fromJson(json);
      expect(restored.id, msg.id);
      expect(restored.role, msg.role);
      expect(restored.content, msg.content);
    });
  });

  group('PupConfig', () {
    test('fromJson with defaults', () {
      final json = {'key': 'dev', 'display_name': 'Dev'};
      final cfg = PupConfig.fromJson(json);
      expect(cfg.key, 'dev');
      expect(cfg.displayName, 'Dev');
      expect(cfg.enabled, true);
      expect(cfg.isCustom, false);
    });
  });

  group('NavItem', () {
    test('all items have non-empty labelKey', () {
      for (final item in NavItem.values) {
        expect(item.labelKey.isNotEmpty, true);
      }
    });
  });

  group('ChannelRecord', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'ch-1',
        'task_id': 'task-1',
        'title': 'Test Channel',
        'status': 'active',
        'created_at': 1000,
        'updated_at': 1001,
        'members': ['alpha', 'dev'],
      };
      final record = ChannelRecord.fromJson(json);
      expect(record.id, 'ch-1');
      expect(record.status, 'active');
      expect(record.statusLabel, 'Active');
      expect(record.members.length, 2);
    });
  });

  group('ConversationSpace', () {
    test('fromJson with defaults', () {
      final json = {'id': 'conv-1', 'title': 'Test Group'};
      final space = ConversationSpace.fromJson(json);
      expect(space.id, 'conv-1');
      expect(space.accent, '#378ADD');
      expect(space.transports, isEmpty);
    });
  });

  group('TokenUsage', () {
    test('fromJson parses correctly', () {
      final json = {
        'prompt_tokens': 100,
        'completion_tokens': 50,
        'total_tokens': 150,
      };
      final usage = TokenUsage.fromJson(json);
      expect(usage.promptTokens, 100);
      expect(usage.completionTokens, 50);
      expect(usage.totalTokens, 150);
    });
  });

  group('Finance models', () {
    test('FinanceOverviewSnapshot fromJson', () {
      final json = {
        'active_order_count': 3,
        'today_trade_count': 10,
      };
      final snap = FinanceOverviewSnapshot.fromJson(json);
      expect(snap.activeOrderCount, 3);
      expect(snap.todayTradeCount, 10);
    });

    test('WatchlistItem fromJson', () {
      final json = {
        'code': 'AAPL',
        'name': 'Apple Inc.',
        'price': 178.5,
        'change_pct': 1.2,
      };
      final item = WatchlistItem.fromJson(json);
      expect(item.code, 'AAPL');
      expect(item.price, 178.5);
    });
  });
}