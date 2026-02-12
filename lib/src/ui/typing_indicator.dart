import 'dart:math';
import 'package:flutter/material.dart';
import 'chat_theme.dart';

/// A professional "three-dot" animation that simulates typing.
///
/// This widget is typically displayed at the bottom of the chat list
/// when [isStreaming] is true, providing visual feedback that the AI
/// is generating a response.
class TypingIndicator extends StatefulWidget {
  /// Creates a typing indicator
  const TypingIndicator({
    super.key,
    required this.theme,
    this.dotRadius = 4.0,
    this.spacing = 4.0,
  });

  /// The theme used for coloring the dots (uses [assistantBubbleColor]).
  final ChatTheme theme;

  /// The radius of each dot.
  final double dotRadius;

  /// The horizontal space between dots.
  final double spacing;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Stagger the animations so they wave: 0.0 -> 0.2 -> 0.4 start times
    _dotAnimations = List.generate(3, (index) {
      final start = index * 0.2;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, 0.6 + start, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We wrap it in a container that matches the assistant's bubble style
    // so it looks like it's coming from the AI.
    return Container(
      padding: widget.theme.padding,
      decoration: BoxDecoration(
        color: widget.theme.assistantBubbleColor,
        borderRadius: BorderRadius.circular(
          widget.theme.bubbleRadius,
        ).copyWith(bottomLeft: const Radius.circular(0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Create a "Wave" effect using sine
              final value = _dotAnimations[index].value;
              final offset = sin(value * pi) * 6; // Move up by 6 pixels

              return Transform.translate(
                offset: Offset(0, -offset),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
                  width: widget.dotRadius * 2,
                  height: widget.dotRadius * 2,
                  decoration: BoxDecoration(
                    color:
                        widget.theme.assistantTextStyle.color?.withAlpha(120) ??
                        Colors.black54,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
