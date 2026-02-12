import 'dart:async';

/// A utility to smooth out irregular text chunks from an AI stream.
///
/// AI APIs often return chunks of varying lengths at irregular intervals.
/// [StreamTransformer] buffers these chunks and releases them as a
/// steady stream to create a more natural "typing" effect in the UI.
class StreamTransformer extends StreamTransformerBase<String, String> {
  /// Creates a [StreamTransformer] with a default [typingDelay]
  /// of 20 milliseconds.
  const StreamTransformer({
    this.typingDelay = const Duration(milliseconds: 20),
  });

  /// The delay between emitting each character or word.
  final Duration typingDelay;

  @override
  Stream<String> bind(Stream<String> stream) {
    // asyncExpand is safer than a manual StreamController.
    // It waits for the loop (and the delays) to finish before processing
    // the next chunk or closing the stream.
    return stream.asyncExpand((chunk) async* {
      for (int i = 0; i < chunk.length; i++) {
        // Delay before each character to simulate typing
        await Future<void>.delayed(typingDelay);
        yield chunk[i];
      }
    });
  }
}
