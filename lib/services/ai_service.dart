import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_settings_service.dart';

class AiServiceException implements Exception {
  final String message;
  AiServiceException(this.message);
  @override
  String toString() => message;
}

/// Sends a prompt to whichever provider the student has configured,
/// using their own API key. Replaces the website's server-side Genkit
/// flows (src/ai/flows/*) with direct client-side calls, since Flutter
/// has no equivalent server runtime.
class AiService {
  final AiSettingsService _settings = AiSettingsService();

  Future<String> generateText(String prompt) async {
    final provider = await _settings.getSelectedProvider();
    final key = await _settings.getApiKey(provider);

    if (key == null || key.trim().isEmpty) {
      throw AiServiceException(
          'No API key set for ${provider.label}. Add one in AI Settings.');
    }

    switch (provider) {
      case AiProvider.gemini:
        return _callGemini(prompt, key);
      case AiProvider.openai:
        return _callOpenAi(prompt, key);
      case AiProvider.openrouter:
        return _callOpenRouter(prompt, key);
    }
  }

  Future<String> _callGemini(String prompt, String key) async {
    final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$key');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [{'text': prompt}]
          }
        ]
      }),
    );
    if (res.statusCode != 200) {
      throw AiServiceException('Gemini error (${res.statusCode}): ${res.body}');
    }
    final data = jsonDecode(res.body);
    return data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
        'No response generated.';
  }

  Future<String> _callOpenAi(String prompt, String key) async {
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $key',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      }),
    );
    if (res.statusCode != 200) {
      throw AiServiceException('OpenAI error (${res.statusCode}): ${res.body}');
    }
    final data = jsonDecode(res.body);
    return data['choices']?[0]?['message']?['content'] ??
        'No response generated.';
  }

  Future<String> _callOpenRouter(String prompt, String key) async {
    final uri = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $key',
      },
      body: jsonEncode({
        'model': 'openrouter/auto',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      }),
    );
    if (res.statusCode != 200) {
      throw AiServiceException(
          'OpenRouter error (${res.statusCode}): ${res.body}');
    }
    final data = jsonDecode(res.body);
    return data['choices']?[0]?['message']?['content'] ??
        'No response generated.';
  }
}
