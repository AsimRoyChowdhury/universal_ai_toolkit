import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/llm_provider.dart';

/// A professional provider for the Anthropic Claude API.
class ClaudeProvider extends BaseLlmProvider {
  /// Creates a new instance of [ClaudeProvider].
  ClaudeProvider({required this.model, required this.apiKey});

  /// The Claude model to use for generating responses (e.g., 'claude-3-opus-20040523').
  final String model;

  /// The API key for accessing the Claude API.
  final String apiKey;

  @override
  Stream<String> generateStream(String prompt) async* {
    final client = http.Client();
    final uri = Uri.parse('https://api.anthropic.com/v1/messages');

    try {
      final request = http.Request('POST', uri)
        ..headers.addAll({
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        })
        ..body = jsonEncode({
          'model': model,
          'messages': [
            ...history.map((m) => m.toJson()),
            {'role': 'user', 'content': prompt},
          ],
          'stream': true,
          'max_tokens': 1024,
        });

      final response = await client.send(request);

      await for (final line
          in response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
        if (line.startsWith('data: ')) {
          final data = jsonDecode(line.substring(6));
          if (data['type'] == 'content_block_delta') {
            yield data['delta']['text'] as String? ?? '';
          }
        }
      }
    } finally {
      client.close();
    }
  }
}
