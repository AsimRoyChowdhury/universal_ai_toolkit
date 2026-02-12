import 'dart:convert';

/// A utility for parsing and extracting structured data from AI streams.
///
/// The [ResponseParser] monitors incoming text chunks for JSON patterns,
/// allowing the system to separate display text from background data
/// (e.g., flight bookings or itinerary details).
class ResponseParser {
  String _buffer = '';

  /// Processes a new [chunk] of text from the stream.
  ///
  /// Returns a record containing the [cleanedText] (with JSON removed)
  /// and an optional [parsedJson] if a complete object was detected.
  ({String cleanedText, Map<String, dynamic>? parsedJson}) processChunk(
    String chunk,
  ) {
    _buffer += chunk;

    // Attempt to find a JSON block starting with '{' and ending with '}'
    final jsonMatch = RegExp(r'\{[\s\S]*?\}').firstMatch(_buffer);

    if (jsonMatch != null) {
      final potentialJson = jsonMatch.group(0)!;

      try {
        // Attempt to decode. If it fails, the JSON is likely incomplete.
        final decoded = jsonDecode(potentialJson) as Map<String, dynamic>;

        // Success! Remove the JSON from the buffer and the current chunk
        _buffer = _buffer.replaceFirst(potentialJson, '');
        final cleanedChunk = chunk.replaceFirst(potentialJson, '');

        return (cleanedText: cleanedChunk, parsedJson: decoded);
      } catch (_) {
        // JSON is incomplete (waiting for more chunks); return text as is
      }
    }

    return (cleanedText: chunk, parsedJson: null);
  }

  /// Resets the internal buffer.
  void reset() => _buffer = '';
}
