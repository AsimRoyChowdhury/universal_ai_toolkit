import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/llm_provider.dart';
import '../core/response_parser.dart';
import '../core/stream_transformer.dart';
import '../models/ai_exception.dart';

/// A professional provider for any OpenAI-compatible API.
///
/// This provider handles streaming, mixed JSON parsing, and smooth text delivery.
class OpenAICompatibleProvider extends BaseLlmProvider {
  /// Creates a new [OpenAICompatibleProvider].
  OpenAICompatibleProvider({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
  });

  /// The base URL (e.g., 'https://api.openai.com/v1').
  final String baseUrl;

  /// The API key for authentication.
  final String apiKey;

  /// The model name (e.g., 'gpt-4o' or 'llama3').
  final String model;

  @override
  Stream<String> generateStream(String prompt) async* {
    final client = http.Client();
    final parser = ResponseParser();
    final uri = Uri.parse('$baseUrl/chat/completions');

    final request = http.Request('POST', uri)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      })
      ..body = jsonEncode({
        'model': model,
        'messages': [
          ...history.map((m) => m.toJson()),
          {'role': 'user', 'content': prompt},
        ],
        'stream': true,
      });

    try {
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw NetworkException(
          'API Error: ${response.statusCode}',
          response.statusCode.toString(),
        );
      }

      // 1. Decode bytes to string lines
      final lineStream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      // 2. Extract content from OpenAI JSON format
      final contentStream = _extractContent(lineStream);

      // 3. Separate Text from JSON and Smooth it
      await for (final rawChunk in contentStream.transform(
        const StreamTransformer(),
      )) {
        final result = parser.processChunk(rawChunk);

        if (result.parsedJson != null) {
          onJsonDetected?.call(result.parsedJson!);
        }

        if (result.cleanedText.isNotEmpty) {
          yield result.cleanedText;
        }
      }
    } finally {
      client.close();
    }
  }

  /// Internal helper to extract 'content' from OpenAI SSE lines.
  Stream<String> _extractContent(Stream<String> lines) async* {
    await for (final line in lines) {
      if (line.startsWith('data: ')) {
        final data = line.substring(6);
        if (data == '[DONE]') break;
        try {
          final decoded = jsonDecode(data) as Map<String, dynamic>;
          final content = decoded['choices'][0]['delta']['content'] as String?;
          if (content != null) yield content;
        } catch (_) {
          /* Skip malformed lines */
        }
      }
    }
  }
}
