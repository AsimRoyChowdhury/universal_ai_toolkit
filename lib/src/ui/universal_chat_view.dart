import 'dart:async';
import 'package:flutter/material.dart';

import '../../universal_ai_toolkit.dart';

/// A customizable builder for chat messages.
typedef MessageBuilder =
    Widget Function(BuildContext context, ChatMessage message);

/// A flexible, professional chat interface component that connects to any [BaseLlmProvider].
///
/// The [UniversalChatView] handles the core chat logic:
/// * Displaying the conversation history.
/// * Managing user input and "Stop Generating" functionality.
/// * Streaming AI responses with real-time updates.
/// * Providing "Surface" features like suggested prompts.
class UniversalChatView extends StatefulWidget {
  /// Creates a new [UniversalChatView].
  const UniversalChatView({
    super.key,
    required this.provider,
    this.chatTheme,
    this.itemBuilder,
    this.inputDecoration,
    this.inputStyle,
    this.inputAreaDecoration,
    this.suggestions = const [],
  });

  /// The AI provider responsible for intelligence, networking, and state.
  final BaseLlmProvider provider;

  /// A custom theme for styling chat bubbles and text.
  ///
  /// If null, a default professional theme will be used.
  final ChatTheme? chatTheme;

  /// An optional builder to completely customize the appearance of each message.
  ///
  /// Use this if you need to render custom widgets (e.g., itinerary cards)
  /// instead of the standard Markdown bubbles.
  final MessageBuilder? itemBuilder;

  /// Custom decoration for the input text field.
  final InputDecoration? inputDecoration;

  /// The text style for the input field.
  final TextStyle? inputStyle;

  /// Decoration for the container wrapping the input area.
  final BoxDecoration? inputAreaDecoration;

  /// A list of suggested prompts to display when the conversation history is empty.
  final List<String> suggestions;

  @override
  State<UniversalChatView> createState() => _UniversalChatViewState();
}

class _UniversalChatViewState extends State<UniversalChatView> {
  /// Controls the text input field.
  final TextEditingController _controller = TextEditingController();

  /// Manages the scrolling behavior of the message list.
  final ScrollController _scrollController = ScrollController();

  /// Manages the active stream subscription to allow for cancellation.
  StreamSubscription<String>? _streamSubscription;

  /// Tracks whether the AI is currently generating a response.
  bool _isStreaming = false;

  /// Gets the active theme, falling back to the default if none is provided.
  ChatTheme get _theme => widget.chatTheme ?? const ChatTheme();

  @override
  void dispose() {
    // Always cancel the subscription to prevent memory leaks.
    _streamSubscription?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Smoothly scrolls the list to the bottom-most message.
  void _scrollToBottom() {
    // We use addPostFrameCallback to ensure the list has finished rendering
    // the new message before we attempt to scroll to it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Cancels the active AI stream and resets the UI state.
  void _stopStreaming() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    if (mounted) {
      setState(() => _isStreaming = false);
    }
  }

  /// Handles the complete flow of sending a message and processing the response.
  Future<void> _handleSend() async {
    final text = _controller.text.trim();

    // Prevent sending empty messages or multiple concurrent requests.
    if (text.isEmpty || _isStreaming) return;

    _controller.clear();

    setState(() {
      // 1. Add User Message
      widget.provider.addToHistory(
        ChatMessage(content: text, role: MessageRole.user),
      );
      _isStreaming = true;
    });

    _scrollToBottom();

    // 2. Add Assistant Placeholder (empty message to be filled by stream)
    final aiMessage = ChatMessage(content: "", role: MessageRole.assistant);
    setState(() => widget.provider.addToHistory(aiMessage));

    String accumulatedResponse = "";

    try {
      // 3. Listen to the stream
      _streamSubscription = widget.provider
          .generateStream(text)
          .listen(
            (chunk) {
              accumulatedResponse += chunk;
              if (mounted) {
                setState(() {
                  // Efficiently update the last message in the history list
                  widget.provider.history.last = ChatMessage(
                    content: accumulatedResponse,
                    role: MessageRole.assistant,
                  );
                });
                _scrollToBottom();
              }
            },
            onError: (Object error) {
              if (mounted) {
                setState(() {
                  widget.provider.history.last = ChatMessage(
                    content: "Error: ${error.toString()}",
                    role: MessageRole.system,
                  );
                });
              }
              _stopStreaming();
            },
            onDone: () => _stopStreaming(),
            cancelOnError: true,
          );
    } catch (e) {
      // Catch synchronous errors (e.g. invalid API key format)
      if (mounted) {
        setState(() {
          widget.provider.history.last = ChatMessage(
            content: "Initialization Error: ${e.toString()}",
            role: MessageRole.system,
          );
        });
      }
      _stopStreaming();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = widget.provider.history.isEmpty;

    return Container(
      color: _theme.backgroundColor,
      child: Column(
        children: [
          Expanded(
            child: isEmpty
                ? _buildWelcomeSurface()
                : ListView.builder(
                    controller: _scrollController,
                    padding: _theme.padding,
                    // Add +1 to itemCount if we are streaming to make room for the indicator
                    itemCount:
                        widget.provider.history.length + (_isStreaming ? 1 : 0),
                    itemBuilder: (context, index) {
                      // If we are at the last index and streaming, show the indicator
                      if (_isStreaming &&
                          index == widget.provider.history.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TypingIndicator(theme: _theme),
                          ),
                        );
                      }
                      final message = widget.provider.history[index];

                      // Use the user's custom builder if provided,
                      // otherwise use the standardized ChatBubble.
                      return widget.itemBuilder?.call(context, message) ??
                          ChatBubble(message: message, theme: _theme);
                    },
                  ),
          ),
          // Show suggestions only when the chat is empty and suggestions exist
          if (isEmpty && widget.suggestions.isNotEmpty)
            _buildSuggestionsSurface(),
          _buildInputArea(),
        ],
      ),
    );
  }

  /// Builds a friendly welcome message when the chat is empty.
  Widget _buildWelcomeSurface() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 64,
            color: _theme.userBubbleColor.withAlpha(50),
          ),
          const SizedBox(height: 16),
          Text(
            "How can I help you today?",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _theme.assistantTextStyle.color,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the horizontal list of suggested prompt chips.
  Widget _buildSuggestionsSurface() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      // Ensure the surface stands out slightly or matches the theme
      color: _theme.backgroundColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: widget.suggestions.map((text) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                label: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.secondaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide.none,
                onPressed: () {
                  _controller.text = text;
                  _handleSend();
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Builds the input text field and the Send/Stop button.
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration:
          widget.inputAreaDecoration ??
          BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: widget.inputStyle,
                decoration:
                    widget.inputDecoration ??
                    const InputDecoration(
                      hintText: 'Ask me anything...',
                      border: InputBorder.none,
                    ),
                // Allow sending by pressing "Enter" on keyboard
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            const SizedBox(width: 8),
            // The Action Button (Send vs Stop)
            IconButton(
              icon: _isStreaming
                  ? Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.stop_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.send_rounded, color: _theme.userBubbleColor),
              onPressed: () {
                if (_isStreaming) {
                  _stopStreaming();
                } else {
                  _handleSend();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
