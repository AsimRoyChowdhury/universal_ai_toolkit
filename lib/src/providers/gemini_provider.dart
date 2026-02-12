import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/llm_provider.dart';
import '../core/response_parser.dart';
import '../core/stream_transformer.dart';
import '../models/chat_message.dart';
import '../models/ai_exception.dart';

/// A professional provider for the Google Gemini API (AI Studio).
class GeminiProvider extends BaseLlmProvider {
  /// Creates a new instance of [GeminiProvider].
  GeminiProvider({required this.model, required this.apiKey});

  /// The specific Gemini model (e.g., 'gemini-1.5-flash').
  final String model;

  /// Your Google AI Studio API Key.
  final String apiKey;

  @override
  Stream<String> generateStream(String prompt) async* {
    final client = http.Client();
    final parser = ResponseParser();
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:streamGenerateContent?key=$apiKey',
    );

    final requestBody = {
      'contents': [
        ...history.map(
          (m) => {
            'role': m.role == MessageRole.user ? 'user' : 'model',
            'parts': [
              {'text': m.content},
            ],
          },
        ),
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
          ],
        },
      ],
    };

    try {
      final request = http.Request('POST', uri)
        ..headers.addAll({'Content-Type': 'application/json'})
        ..body = jsonEncode(requestBody);

      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw NetworkException('Gemini API Error: ${response.statusCode}');
      }

      final contentStream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .expand(_parseGeminiEvents);

      await for (final rawChunk in contentStream.transform(
        const StreamTransformer(),
      )) {
        final result = parser.processChunk(rawChunk);
        if (result.parsedJson != null) onJsonDetected?.call(result.parsedJson!);
        if (result.cleanedText.isNotEmpty) yield result.cleanedText;
      }
    } finally {
      client.close();
    }
  }

  Iterable<String> _parseGeminiEvents(String line) sync* {
    if (line.isEmpty || line == '[' || line == ']') return;
    try {
      final cleanedLine = line.startsWith(',') ? line.substring(1) : line;
      final decoded = jsonDecode(cleanedLine) as Map<String, dynamic>;
      final text =
          decoded['candidates'][0]['content']['parts'][0]['text'] as String?;
      if (text != null) yield text;
    } catch (_) {}
  }
}
