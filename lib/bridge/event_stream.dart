/// Event stream bridge — consumes Rust-side events and emits them as a Dart Stream.
///
/// Replaces Tauri's pp.listen('stream_token', ...) pattern.
/// Events from Rust: stream_token, stream_activity, stream_done, stream_error,
/// permission_request, etc.

import 'dart:async';
import 'dart:convert';

/// A single event from the Rust backend.
class RustEvent {
  final String kind;
  final String payload;

  const RustEvent({required this.kind, required this.payload});

  /// Convenience: parse payload as JSON.
  T parseAs<T>(T Function(Map<String, dynamic>) fromJson) {
    final map = jsonDecode(payload) as Map<String, dynamic>;
    return fromJson(map);
  }

  /// Quick-access: is this a stream token event?
  bool get isStreamToken => kind == 'stream_token';
  bool get isStreamDone => kind == 'stream_done';
  bool get isStreamError => kind == 'stream_error';
  bool get isPermissionRequest => kind == 'permission_request';
}

/// Singleton event bus that Flutter widgets can listen on.
class EventBus {
  EventBus._();
  static final EventBus _instance = EventBus._();
  static EventBus get instance => _instance;

  final StreamController<RustEvent> _controller =
      StreamController<RustEvent>.broadcast();

  Stream<RustEvent> get stream => _controller.stream;

  /// Subscribe to a specific event kind.
  Stream<RustEvent> on(String kind) {
    return _controller.stream.where((e) => e.kind == kind);
  }

  /// Push an event from the Rust bridge layer.
  void emit(RustEvent event) {
    _controller.add(event);
  }

  /// Start listening to the Rust event broadcast channel.
  /// Called once after [OpenPupBridge.initApp].
  void connect() {
    // TODO: After flutter_rust_bridge codegen, subscribe to the Rust broadcast
    // receiver returned by rust.api.subscribeEvents() and forward each event.
    //
    // Example:
    //   final rx = await rust.api.subscribeEvents();
    //   rx.listen((EventPayload payload) {
    //     _controller.add(RustEvent(
    //       kind: payload.kind,
    //       payload: payload.payload,
    //     ));
    //   });
    //
    // For now, the event bus is ready but idle until the FFI bridge is wired.
  }

  void dispose() {
    _controller.close();
  }
}