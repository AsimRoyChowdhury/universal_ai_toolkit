/// A universal AI toolkit for Flutter that works with any LLM provider.
///
/// This library exports the core interfaces, data models, concrete provider
/// implementations (OpenAI, Gemini, Claude), and the pre-built UI widgets.
library;

// -----------------------------------------------------------------------------
// Core Interfaces & Models
// -----------------------------------------------------------------------------
export 'src/core/llm_provider.dart';
export 'src/models/chat_message.dart';
export 'src/models/ai_config.dart';
export 'src/models/ai_exception.dart';

// -----------------------------------------------------------------------------
// Concrete Providers (The Workers)
// -----------------------------------------------------------------------------
export 'src/providers/openai_compatible_provider.dart';
export 'src/providers/gemini_provider.dart';
export 'src/providers/claude_provider.dart';
export 'src/providers/mock_provider.dart';

// -----------------------------------------------------------------------------
// UI Components (The Presentation Layer)
// -----------------------------------------------------------------------------
export 'src/ui/universal_chat_view.dart';
export 'src/ui/chat_bubble.dart';
export 'src/ui/chat_theme.dart';
export 'src/ui/typing_indicator.dart';
