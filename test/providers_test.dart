import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openpup/providers/ui_provider.dart';
import 'package:openpup/providers/chat_provider.dart';
import 'package:openpup/providers/app_provider.dart';
import 'package:openpup/providers/finance_provider.dart';
import 'package:openpup/models/navigation_item.dart';
import 'package:openpup/models/chat_message.dart';
import 'package:openpup/models/pup_config.dart';

void main() {
  group('UIProvider', () {
    test('initial state is dark mode, chat nav', () {
      final container = ProviderScope(overrides: [], child: const SizedBox());
      // Create the notifier directly
      final notifier = UINotifier();
      expect(notifier.state.isDarkMode, true);
      expect(notifier.state.activeNav, NavItem.chat);
      expect(notifier.state.sidebarCollapsed, false);
    });

    test('toggleTheme switches dark mode', () {
      final notifier = UINotifier();
      notifier.toggleTheme();
      expect(notifier.state.isDarkMode, false);
      notifier.toggleTheme();
      expect(notifier.state.isDarkMode, true);
    });

    test('setActiveNav changes nav and auto-expands sections', () {
      final notifier = UINotifier();
      notifier.setActiveNav(NavItem.timeline);
      expect(notifier.state.activeNav, NavItem.timeline);
      expect(notifier.state.toolsExpanded, true);

      notifier.setActiveNav(NavItem.pups);
      expect(notifier.state.activeNav, NavItem.pups);
      expect(notifier.state.configExpanded, true);
    });

    test('toggle sidebar', () {
      final notifier = UINotifier();
      notifier.toggleSidebar();
      expect(notifier.state.sidebarCollapsed, true);
      notifier.toggleSidebar();
      expect(notifier.state.sidebarCollapsed, false);
    });
  });

  group('ChatProvider', () {
    test('initial state has empty messages', () {
      final notifier = ChatNotifier();
      expect(notifier.state.messages, isEmpty);
      expect(notifier.state.sending, false);
      expect(notifier.state.streamingContent, '');
    });

    test('send message adds to list', () {
      final notifier = ChatNotifier();
      notifier.setSending(true);
      expect(notifier.state.sending, true);

      notifier.appendMessage(ChatMessage(
        id: '1', role: 'user', content: 'Hello',
      ));
      expect(notifier.state.messages.length, 1);

      notifier.appendStreamingContent('Hi');
      notifier.appendStreamingContent(' there');
      expect(notifier.state.streamingContent, 'Hi there');
    });

    test('reset streaming clears temp state', () {
      final notifier = ChatNotifier();
      notifier.setStreamingContent('Hello');
      notifier.addActivityStep(ActivityStep(kind: 'routing', label: 'Routing'));
      notifier.resetStreaming();
      expect(notifier.state.streamingContent, '');
      expect(notifier.state.streamingSteps, isEmpty);
    });
  });

  group('AppProvider', () {
    test('initial state has default values', () {
      final notifier = AppNotifier();
      expect(notifier.state.onboardingDone, isNull);
      expect(notifier.state.pups, isEmpty);
      expect(notifier.state.execMode, 'leashed');
    });

    test('setOnboardingDone works', () {
      final notifier = AppNotifier();
      notifier.setOnboardingDone(true);
      expect(notifier.state.onboardingDone, true);
    });

    test('setPups updates list', () {
      final notifier = AppNotifier();
      final pups = [
        PupConfig(key: 'alpha', displayName: 'Alpha'),
        PupConfig(key: 'dev', displayName: 'Dev'),
      ];
      notifier.setPups(pups);
      expect(notifier.state.pups.length, 2);
    });
  });

  group('FinanceProvider', () {
    test('initial state has overview tab', () {
      final notifier = FinanceNotifier();
      expect(notifier.state.activeTab, 'overview');
    });

    test('setActiveTab changes tab', () {
      final notifier = FinanceNotifier();
      notifier.setActiveTab('orders');
      expect(notifier.state.activeTab, 'orders');
    });
  });
}
