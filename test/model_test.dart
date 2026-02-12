import 'package:flutter_test/flutter_test.dart';
import 'package:universal_ai_toolkit/universal_ai_toolkit.dart';

void main() {
  group('ChatMessage', () {
    test('Serialization (toJson) works correctly', () {
      final msg = ChatMessage(
        content: 'Hello AI',
        role: MessageRole.user,
      );
      
      final json = msg.toJson();
      expect(json['role'], equals('user'));
      expect(json['content'], equals('Hello AI'));
    });

    test('Deserialization (fromJson) works correctly', () {
      final json = {
        'role': 'assistant',
        'content': 'Hello Human',
      };
      
      final msg = ChatMessage.fromJson(json);
      expect(msg.role, equals(MessageRole.assistant));
      expect(msg.content, equals('Hello Human'));
    });
  });

  group('AIConfig', () {
    test('Defaults are set correctly', () {
      const config = AIConfig();
      expect(config.temperature, equals(0.7));
      expect(config.topP, equals(1.0));
    });
  });
}