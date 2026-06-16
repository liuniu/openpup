/// Default LLM provider configuration — hardcoded for now.
class DefaultLlmConfig {
  DefaultLlmConfig._();

  /// Base URL for the OpenAI-compatible API endpoint.
  static const String baseUrl = 'https://api.deepseek.com/v1';

  /// API key.
  static const String apiKey = 'sk-62d06f6d0149406b8bc22475115265a5';

  /// Model name to use by default.
  static const String model = 'deepseek-v4-flash';

  /// Provider display name.
  static const String providerName = 'DeepSeek';
}
