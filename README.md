
# 🤖 Universal AI Toolkit

  

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)   [![Style: flutter_lints](https://img.shields.io/badge/style-flutter__lints-blue.svg)](https://pub.dev/packages/flutter_lints)

  

The missing link between your Flutter app and the world of AI.

  

**Universal AI Toolkit** allows you to build professional, streaming AI chat interfaces that work with **any** LLM provider (OpenAI, Gemini, Claude, or Local Models) using a single, unified API.

  

---

  

## ✨ Features

  

*  **Provider Agnostic:** Switch between OpenAI, Google Gemini, Anthropic Claude, or local models (via Ollama) with one line of code.

*  **Smooth Streaming:** Built-in `StreamTransformer` logic ensures text flows naturally, word-by-word, smoothing out network jitter.

*  **Professional UI:** Includes a production-ready `UniversalChatView` with:

*  **Structured Data:** Automatically detects and parses JSON (like flight data or tool calls) from the stream while showing plain text to the user.

*  **Developer Friendly:** Built with strict linting, clean architecture, and Mock providers for zero-cost testing.

  

---

  

##  Getting Started

  

Add the package to your `pubspec.yaml`:

  

```yaml

dependencies:

universal_ai_toolkit: ^1.0.0

```

  

##  Usage

  

1. Initialize a Provider

	  Select the brain you want to use. You can swap this out later without changing your UI code!

```Dart
import 'package:universal_ai_toolkit/universal_ai_toolkit.dart'; 

// Option A: OpenAI (or compatible services like Groq/DeepSeek) 
final openAiProvider = OpenAICompatibleProvider( 
	apiKey: 'sk-rs...', 
	baseUrl: '[https://api.openai.com/v1](https://api.openai.com/v1)', // or your local Ollama URL 
	model: 'gpt-4o', ); 

// Option B: Google Gemini 
final geminiProvider = GeminiProvider( 
	apiKey: 'AIzaSy...', 
	model: 'gemini-1.5-flash', 
); 

// Option C: Anthropic Claude 
final claudeProvider = ClaudeProvider( 
	apiKey: 'sk-ant...', 
	model: 'claude-3-5-sonnet-20240620', 
); 

// Option D: Mock (For testing UI without API costs) 
final mockProvider = MockLlmProvider();
```

2. Add the Chat View

	Drop the UniversalChatView anywhere in your app. It handles the state, text input, and scrolling automatically.

  

```Dart

class ChatScreen extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text("Universal AI Chat")),
			body: UniversalChatView(
				provider: openAiProvider, // Pass your chosen provider here
				suggestions: const [
					"✨ Plan a trip to Paris",
					"📝 Summarize this text",
					"💻 Debug my Flutter code",
				],
			),
		);
	}
}
```

---
## 🎨 Customization

Theming

Don't like the default blue? Create your own ChatTheme to match your brand.

```Dart
UniversalChatView(
	provider: provider,
	chatTheme: ChatTheme(
		userBubbleColor: Colors.deepPurple,
		assistantBubbleColor: Colors.grey[200]!,
		userTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
		assistantTextStyle: const TextStyle(color: Colors.black87, fontSize: 16),
	),
)
```

---
## Handling Structured Data (JSON)

If your AI returns mixed content (text + JSON), use the onJsonDetected callback in your provider. This is perfect for handling tool calls or app-specific data. 

```Dart
provider.onJsonDetected = (Map<String,  dynamic> data) {
	print("Tool Call Detected: $data"); // Handle booking a flight, showing a map, etc.
};
```
---
## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](https://github.com/AsimRoyChowdhury/universal_ai_toolkit/CONTRIBUTING.md) for details on how to set up the project, our coding standards, and how to submit a Pull Request.

  

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/AsimRoyChowdhury/universal_ai_toolkit/LICENSE) file for details.