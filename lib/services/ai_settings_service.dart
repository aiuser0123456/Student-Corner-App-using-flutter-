import 'package:shared_preferences/shared_preferences.dart';

enum AiProvider { gemini, openai, openrouter }

extension AiProviderX on AiProvider {
  String get label {
    switch (this) {
      case AiProvider.gemini:
        return 'Google Gemini';
      case AiProvider.openai:
        return 'OpenAI';
      case AiProvider.openrouter:
        return 'OpenRouter';
    }
  }

  /// Where the student can sign up / generate a free API key.
  String get keyPageUrl {
    switch (this) {
      case AiProvider.gemini:
        return 'https://aistudio.google.com/app/apikey';
      case AiProvider.openai:
        return 'https://platform.openai.com/api-keys';
      case AiProvider.openrouter:
        return 'https://openrouter.ai/keys';
    }
  }

  String get description {
    switch (this) {
      case AiProvider.gemini:
        return 'Google\'s Gemini models. Free tier available. '
            'Sign in with your Google account, click "Create API key", and paste it below.';
      case AiProvider.openai:
        return 'OpenAI\'s GPT models. Requires a paid account with available '
            'credit. Create a key from your account dashboard and paste it below.';
      case AiProvider.openrouter:
        return 'OpenRouter gives access to many models (including free ones) '
            'through a single key. Sign up, create a key, and paste it below.';
    }
  }

  String get prefsKey => 'api_key_${toString()}';
}

/// Stores the user's own API keys and chosen provider locally on-device.
/// Keys are never sent anywhere except directly to the chosen provider's API.
class AiSettingsService {
  static const _providerKey = 'ai_selected_provider';

  Future<AiProvider> getSelectedProvider() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_providerKey);
    return AiProvider.values.firstWhere(
      (p) => p.toString() == value,
      orElse: () => AiProvider.gemini,
    );
  }

  Future<void> setSelectedProvider(AiProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_providerKey, provider.toString());
  }

  Future<String?> getApiKey(AiProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(provider.prefsKey);
  }

  Future<void> setApiKey(AiProvider provider, String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(provider.prefsKey, key);
  }

  Future<void> clearApiKey(AiProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(provider.prefsKey);
  }
}
