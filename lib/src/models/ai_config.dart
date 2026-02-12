/// Configuration settings for fine-tuning AI model behavior.
///
/// Use [AIConfig] to control aspects like creativity ([temperature])
/// and response length ([maxTokens]).
class AIConfig {
  /// Creates a professional [AIConfig] with sensible default values.
  const AIConfig({
    this.temperature = 0.7,
    this.maxTokens,
    this.topP = 1.0,
    this.presencePenalty = 0.0,
  });

  /// Controls the randomness of the output.
  ///
  /// Values closer to 0.0 make the output more deterministic,
  /// while values closer to 1.0 make it more creative.
  final double temperature;

  /// The maximum number of tokens the AI should generate in a single response.
  final int? maxTokens;

  /// An alternative to sampling with temperature, called nucleus sampling.
  final double topP;

  /// Penalizes new tokens based on whether they appear in the text so far.
  final double presencePenalty;
}
