import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message.dart';
import 'chat_theme.dart';

/// The Chat bubble widget for user and model conversations
class ChatBubble extends StatelessWidget {
  /// Creates a chat bubble
  const ChatBubble({super.key, required this.message, required this.theme});

  /// The chat message to display
  final ChatMessage message;

  /// The chat theme to use for styling the bubble
  final ChatTheme theme;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final backgroundColor = isUser
        ? theme.userBubbleColor
        : theme.assistantBubbleColor;
    final textStyle = isUser ? theme.userTextStyle : theme.assistantTextStyle;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: theme.padding,
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(theme.bubbleRadius).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : null,
            bottomLeft: !isUser ? const Radius.circular(0) : null,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: message.content,
              selectable: true,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  .copyWith(
                    p: textStyle,
                    code: TextStyle(
                      backgroundColor: isUser ? Colors.white24 : Colors.black12,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: isUser ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
            ),
            // Only show actions for Assistant messages that aren't loading
            if (!isUser && message.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildActions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: message.content));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Copied to clipboard'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Icon(
            Icons.copy_rounded,
            size: 16,
            color: theme.assistantTextStyle.color?.withAlpha(100),
          ),
        ),
      ],
    );
  }
}
