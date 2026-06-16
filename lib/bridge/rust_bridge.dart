/// Bridge between Flutter and the Rust backend via flutter_rust_bridge.
///
/// This file wraps the auto-generated FFI bindings and provides a clean
/// Dart API for the rest of the app.
///
/// After running flutter_rust_bridge_codegen, these stubs will call
/// the generated rust.openpup_flutter_bridge.* functions directly.



import 'dart:convert';
import 'package:window_manager/window_manager.dart';
import 'event_stream.dart';
import 'package:flutter/material.dart' show Size;

/// Main entry point for all Rust backend communication.
class OpenPupBridge {
  OpenPupBridge._();

  // ── Lifecycle ──────────────────────────────────────────────────────────

  /// Initialise desktop window (size, position, decorations).
  static Future<void> initDesktopWindow() async {
    try {
      await windowManager.ensureInitialized();
      await windowManager.waitUntilReadyToShow();
      await windowManager.setMinimumSize(const Size(860, 620));
      await windowManager.setTitle('OpenPup');
      await windowManager.show();
    } catch (e) {
      // window_manager not available on this platform
    }
  }

  /// Initialise the Rust backend. Call once at app startup.
  static Future<void> initApp() async {
    // TODO: Replace with flutter_rust_bridge call after codegen:
    //   final result = await rust.api.initApp(workspaceRoot: workspacePath);
    // For now, simulate init and connect event bus.
    await Future.delayed(const Duration(milliseconds: 300));

    // Start forwarding Rust events to the Dart EventBus.
    EventBus.instance.connect();
  }

  // ── Chat ──────────────────────────────────────────────────────────────

  /// Send a user message — response arrives via [EventBus.stream].
  static Future<void> sendMessage({
    required String input,
    String? forcedPup,
  }) async {
    // TODO: await rust.api.sendMessage(input: input, forcedPup: forcedPup);
    await Future.delayed(const Duration(milliseconds: 100));
    // The Rust side pushes stream_token / stream_done / stream_error
    // events into the broadcast channel, which EventBus forwards as Dart Stream.
  }

  /// Cancel the current streaming response.
  static Future<void> abortMessage() async {
    // TODO: await rust.api.abortMessage();
  }

  // ── LLM / Config ──────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getLlmConfig() async {
    // TODO: final raw = await rust.api.getLlmConfig();
    // return raw != null ? jsonDecode(raw) : null;
    return null;
  }

  static Future<Map<String, dynamic>?> getLlmSettingsSnapshot() async {
    // TODO: final raw = await rust.api.getLlmSettingsSnapshot();
    // return raw != null ? jsonDecode(raw) : null;
    return null;
  }

  static Future<List<dynamic>> listLlmProviders() async {
    // TODO: final raw = await rust.api.listLlmProviders();
    // return raw != null ? jsonDecode(raw) : [];
    return [];
  }

  static Future<void> saveLlmProvider(String providerJson) async {
    // TODO: await rust.api.saveLlmProvider(providerJson: providerJson);
  }

  static Future<void> deleteLlmProvider(String providerId) async {
    // TODO: await rust.api.deleteLlmProvider(providerId: providerId);
  }

  static Future<void> setLlmRouting(String routingJson) async {
    // TODO: await rust.api.setLlmRouting(routingJson: routingJson);
  }

  static Future<Map<String, dynamic>?> getLlmRouting() async {
    return null;
  }

  static Future<List<dynamic>> listLlmProviderCatalog() async {
    return [];
  }

  static Future<String?> testLlmProvider(String providerId) async {
    return null;
  }

  // ── Memory ────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getTopMemories({int limit = 5}) async {
    // TODO: final raw = await rust.api.getTopMemories(limit: limit);
    // return raw != null ? jsonDecode(raw) : [];
    return [];
  }

  static Future<List<dynamic>> listLongTermMemories(String queryJson) async {
    // TODO: final raw = await rust.api.listLongTermMemories(queryJson: queryJson);
    // return raw != null ? jsonDecode(raw) : [];
    return [];
  }

  // ── Pups ──────────────────────────────────────────────────────────────

  static Future<List<dynamic>> listPups() async {
    // TODO: final raw = await rust.api.listPups();
    // return raw != null ? jsonDecode(raw) : [];
    return [];
  }

  static Future<void> updatePup(String pupJson) async {
    // TODO: await rust.api.updatePup(pupJson: pupJson);
  }

  // ── Permissions ───────────────────────────────────────────────────────

  static Future<void> approvePermission(
    String requestId,
    bool remember,
  ) async {
    // TODO: await rust.api.approvePermission(requestId: requestId, remember: remember);
  }

  static Future<void> denyPermission(String requestId) async {
    // TODO: await rust.api.denyPermission(requestId: requestId);
  }

  // ── Context ───────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getContextStats(String pupKey) async {
    // TODO: final raw = await rust.api.getContextStats(pupKey: pupKey);
    // return raw != null ? jsonDecode(raw) : null;
    return null;
  }

  static Future<Map<String, dynamic>?> getTokenUsage() async {
    return null;
  }

  // ── Channel ───────────────────────────────────────────────────────────

  static Future<List<dynamic>> listChannels() async {
    return [];
  }

  static Future<List<dynamic>> getChannelMessages(String channelId) async {
    return [];
  }

  // ── Finance ───────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> financeOverviewSnapshot() async {
    return null;
  }

  static Future<Map<String, dynamic>?> financeOrdersSnapshot() async {
    return null;
  }

  // ── Knowledge ─────────────────────────────────────────────────────────

  static Future<List<dynamic>> kbSearch(String query) async {
    return [];
  }

  static Future<void> kbIngestFile(String path) async {
    // TODO: await rust.api.kbIngestFile(path: path);
  }

  // ── Tasks ─────────────────────────────────────────────────────────────

  static Future<List<dynamic>> listTasks() async {
    return [];
  }

  static Future<void> createTask(String taskJson) async {
    // TODO: await rust.api.createTask(taskJson: taskJson);
  }

  // ── Skills ────────────────────────────────────────────────────────────

  static Future<List<dynamic>> listSkills() async {
    return [];
  }

  static Future<void> runSkill(String skillName) async {
    // TODO: await rust.api.runSkill(skillName: skillName);
  }

  // ── MCP ───────────────────────────────────────────────────────────────

  static Future<List<dynamic>> listMcpServers() async {
    return [];
  }

  // ── Conversation ──────────────────────────────────────────────────────

  static Future<List<dynamic>> listConversationSpaces() async {
    return [];
  }

  // ── Desktop ───────────────────────────────────────────────────────────

  static Future<String> getExecutionMode() async {
    return 'leashed';
  }

  static Future<void> setExecutionMode(String mode) async {
    // TODO: await rust.api.setExecutionMode(mode: mode);
  }
}