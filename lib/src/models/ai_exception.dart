/// Base class for all exceptions thrown by the Universal AI Toolkit.
abstract class AIException implements Exception {
  /// Creates an [AIException] with a required [message].
  const AIException(this.message, [this.code]);

  /// A human-readable message describing the error.
  final String message;

  /// An optional error code from the underlying AI service.
  final String? code;

  @override
  String toString() => 'AIException: $message ${code != null ? '($code)' : ''}';
}

/// Exception thrown when an API key is missing or invalid.
class ApiKeyException extends AIException {
  /// Creates an [ApiKeyException] with a required [message].
  const ApiKeyException([
    super.message = 'Invalid or missing API key.',
    super.code,
  ]);
}

/// Exception thrown when the AI service rate limit is exceeded.
class RateLimitException extends AIException {
  /// Creates a [RateLimitException] with a required [message].
  const RateLimitException([
    super.message = 'Rate limit exceeded. Please try again later.',
    super.code,
  ]);
}

/// Exception thrown when a network-related error occurs.
class NetworkException extends AIException {
  /// Creates a [NetworkException] with a required [message].
  const NetworkException([
    super.message = 'Network error. Please check your connection.',
    super.code,
  ]);
}
