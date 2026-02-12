import 'package:flutter/material.dart';

/// Defines the visual style for all components in the [UniversalChatView].
class ChatTheme {
  /// Creates a new [ChatTheme] instance with the specified properties.
  const ChatTheme({
    this.backgroundColor = Colors.white,
    this.userBubbleColor = const Color(0xFF007AFF),
    this.assistantBubbleColor = const Color(0xFFE9E9EB),
    this.userTextStyle = const TextStyle(color: Colors.white),
    this.assistantTextStyle = const TextStyle(color: Colors.black),
    this.bubbleRadius = 16.0,
    this.padding = const EdgeInsets.all(12.0),
  });

  /// The background color of the chat view.
  final Color backgroundColor;

  /// The color of the user's message bubbles.
  final Color userBubbleColor;

  /// The color of the assistant's message bubbles.
  final Color assistantBubbleColor;

  /// The text style for the user's messages.
  final TextStyle userTextStyle;

  /// The text style for the assistant's messages.
  final TextStyle assistantTextStyle;

  /// The radius of the corners of the message bubbles.
  final double bubbleRadius;

  /// The padding around the chat view.
  final EdgeInsets padding;
}
