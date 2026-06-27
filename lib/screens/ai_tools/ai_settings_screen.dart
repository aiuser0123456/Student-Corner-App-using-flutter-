import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/ai_settings_service.dart';
import '../../theme/app_theme.dart';

class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  final _settingsService = AiSettingsService();
  AiProvider _selected = AiProvider.gemini;
  final Map<AiProvider, TextEditingController> _controllers = {
    for (final p in AiProvider.values) p: TextEditingController(),
  };
  final Map<AiProvider, bool> _obscure = {
    for (final p in AiProvider.values) p: true,
  };
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final provider = await _settingsService.getSelectedProvider();
    for (final p in AiProvider.values) {
      final key = await _settingsService.getApiKey(p);
      _controllers[p]!.text = key ?? '';
    }
    if (mounted) {
      setState(() {
        _selected = provider;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    await _settingsService.setSelectedProvider(_selected);
    for (final p in AiProvider.values) {
      await _settingsService.setApiKey(p, _controllers[p]!.text.trim());
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI settings saved.')),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AI Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Choose which AI provider powers the AI Tools, and use your own API key. '
            'Your key is stored only on this device and is sent directly to the '
            'provider you choose — never through our servers.',
            style: TextStyle(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 20),
          ...AiProvider.values.map(_buildProviderCard),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _save,
            child: const Text('Save settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(AiProvider provider) {
    final isActive = _selected == provider;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive ? AppColors.primary : AppColors.border,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Radio<AiProvider>(
                  value: provider,
                  groupValue: _selected,
                  onChanged: (v) => setState(() => _selected = v!),
                ),
                Expanded(
                  child: Text(
                    provider.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                if (isActive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Active',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(provider.description,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.mutedForeground)),
            const SizedBox(height: 12),
            TextField(
              controller: _controllers[provider],
              obscureText: _obscure[provider]!,
              decoration: InputDecoration(
                labelText: '${provider.label} API key',
                prefixIcon: const Icon(Icons.key_outlined),
                suffixIcon: IconButton(
                  icon: Icon(_obscure[provider]!
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () => setState(
                      () => _obscure[provider] = !_obscure[provider]!),
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => launchUrl(
                Uri.parse(provider.keyPageUrl),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: Text('Get a ${provider.label} API key'),
            ),
          ],
        ),
      ),
    );
  }
}
