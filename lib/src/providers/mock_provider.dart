import 'dart:async';
import '../core/llm_provider.dart';
import '../core/stream_transformer.dart';

/// A mock provider for zero-cost UI testing.
///
/// Simulates a real-time streaming response with a customizable delay.
class MockLlmProvider extends BaseLlmProvider {
  @override
  Stream<String> generateStream(String prompt) async* {
    // Simulate initial network latency
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final response =
        "This is a smooth mock response to: '$prompt'. "
        "I am currently testing the Universal AI Toolkit UI components.";

    // Pipe the response through the StreamTransformer
    final controller = StreamController<String>();
    controller.add(response);
    controller.close();

    yield* controller.stream.transform(const StreamTransformer());
  }
}
