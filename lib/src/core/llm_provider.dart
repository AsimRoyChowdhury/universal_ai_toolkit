import 'dart:async';
import '../models/chat_message.dart';

/// An abstract interface defining the contract for an AI provider.
///
/// Any LLM service (e.g., OpenAI, Anthropic, or local Ollama) must extend
/// this class to integrate with the toolkit's UI components.
abstract class BaseLlmProvider {
  /// The conversational history maintained by this provider.
  ///
  /// This list is typically sent to the LLM with each new request
  /// to provide context for the response.
  final List<ChatMessage> history = [];

  /// A callback triggered when structured JSON is detected within
  /// a streaming response.
  ///
  /// Use this to handle custom UI components like itineraries or
  /// flight bookings without interrupting the text stream.
  void Function(Map<String, dynamic> json)? onJsonDetected;

  /// Generates a streaming response for the given [prompt].
  ///
  /// Returns a [Stream] of strings representing incremental chunks
  /// of the AI's response, enabling a real-time typing effect.
  Stream<String> generateStream(String prompt);

  /// Resets the conversation by clearing all [history].
  void clearHistory() {
    history.clear();
  }

  /// Adds a new [ChatMessage] to the provider's history.
  void addToHistory(ChatMessage message) {
    history.add(message);
  }
}
