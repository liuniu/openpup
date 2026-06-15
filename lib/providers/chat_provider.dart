import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';

/// Chat state — replaces Zustand chatStore.ts.
class ChatState {
  final List<ChatMessage> messages;
  final String streamingContent;
  final String streamingReasoningContent;
  final StreamingPupState? streamingPup;
  final List<ActivityStep> streamingSteps;
  final String input;
  final bool sending;
  final TokenUsage? tokenUsage;

  const ChatState({
    this.messages = const [],
    this.streamingContent = '',
    this.streamingReasoningContent = '',
    this.streamingPup,
    this.streamingSteps = const [],
    this.input = '',
    this.sending = false,
    this.tokenUsage,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    String? streamingContent,
    String? streamingReasoningContent,
    StreamingPupState? Function()? streamingPup,
    List<ActivityStep>? streamingSteps,
    String? input,
    bool? sending,
    TokenUsage? Function()? tokenUsage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      streamingContent: streamingContent ?? this.streamingContent,
      streamingReasoningContent:
          streamingReasoningContent ?? this.streamingReasoningContent,
      streamingPup: streamingPup != null ? streamingPup() : this.streamingPup,
      streamingSteps: streamingSteps ?? this.streamingSteps,
      input: input ?? this.input,
      sending: sending ?? this.sending,
      tokenUsage: tokenUsage != null ? tokenUsage() : this.tokenUsage,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState());

  void setMessages(List<ChatMessage> messages) {
    state = state.copyWith(messages: messages);
  }

  void appendMessage(ChatMessage msg) {
    state = state.copyWith(messages: [...state.messages, msg]);
  }

  void appendStreamingContent(String token) {
    state = state.copyWith(streamingContent: state.streamingContent + token);
  }

  void setStreamingContent(String content) {
    state = state.copyWith(streamingContent: content);
  }

  void setStreamingReasoningContent(String content) {
    state = state.copyWith(streamingReasoningContent: content);
  }

  void setStreamingPup(StreamingPupState? pup) {
    state = state.copyWith(streamingPup: () => pup);
  }

  void addActivityStep(ActivityStep step) {
    state = state.copyWith(streamingSteps: [...state.streamingSteps, step]);
  }

  void setInput(String input) {
    state = state.copyWith(input: input);
  }

  void setSending(bool sending) {
    state = state.copyWith(sending: sending);
  }

  void setTokenUsage(TokenUsage? usage) {
    state = state.copyWith(tokenUsage: () => usage);
  }

  void resetStreaming() {
    state = state.copyWith(
      streamingContent: '',
      streamingReasoningContent: '',
      streamingPup: () => null,
      streamingSteps: [],
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
