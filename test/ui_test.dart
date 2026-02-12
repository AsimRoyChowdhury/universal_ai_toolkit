import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_ai_toolkit/universal_ai_toolkit.dart';

// A controllable Mock Provider for UI testing
class TestLlmProvider extends BaseLlmProvider {
  final StreamController<String> _controller = StreamController<String>();

  @override
  Stream<String> generateStream(String prompt) {
    // Return a stream we can control from the test
    return _controller.stream;
  }

  void emitChunk(String chunk) {
    _controller.add(chunk);
  }
}

void main() {
  testWidgets('UniversalChatView sends message and displays response', (WidgetTester tester) async {
    // 1. Setup
    final provider = TestLlmProvider();
    
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: UniversalChatView(provider: provider),
      ),
    ));

    // 2. Verify initial state
    expect(find.text('How can I help you today?'), findsOneWidget);

    // 3. User types "Hello"
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pump();

    // 4. User taps Send
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();

    // 5. Verify user message is in history and UI
    expect(provider.history.first.content, equals('Hello'));
    expect(find.text('Hello'), findsOneWidget);

    // 6. Simulate AI Response Stream
    // The UI is now listening. Let's emit data.
    provider.emitChunk('Hi ');
    await tester.pump(); // Rebuild UI
    
    provider.emitChunk('there!');
    await tester.pump();

    // 7. Verify AI response is on screen
    expect(find.text('Hi there!'), findsOneWidget);
  });

  testWidgets('Stop button appears when streaming', (WidgetTester tester) async {
    final provider = TestLlmProvider();
    
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: UniversalChatView(provider: provider)),
    ));

    // Start sending
    await tester.enterText(find.byType(TextField), 'Go');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();

    // Look for the Stop button (it replaces the Send button)
    expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
    expect(find.byIcon(Icons.send_rounded), findsNothing);
  });
}