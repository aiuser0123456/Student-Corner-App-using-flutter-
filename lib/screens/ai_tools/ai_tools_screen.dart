import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../services/ai_service.dart';
import '../../services/ai_settings_service.dart';
import '../../theme/app_theme.dart';
import 'ai_settings_screen.dart';

class AiToolsScreen extends StatefulWidget {
  const AiToolsScreen({super.key});

  @override
  State<AiToolsScreen> createState() => _AiToolsScreenState();
}

class _AiToolsScreenState extends State<AiToolsScreen> {
  final _aiService = AiService();
  final _settingsService = AiSettingsService();
  final _promptController = TextEditingController();
  String? _response;
  bool _loading = false;
  String? _error;
  AiProvider _provider = AiProvider.gemini;

  static const _suggestions = [
    'Summarize the key concepts of Newton\'s laws of motion',
    'Generate 5 practice questions on organic chemistry',
    'Explain photosynthesis for a Class 11 student',
    'Create short revision notes on the French Revolution',
  ];

  @override
  void initState() {
    super.initState();
    _loadProvider();
  }

  Future<void> _loadProvider() async {
    final p = await _settingsService.getSelectedProvider();
    if (mounted) setState(() => _provider = p);
  }

  Future<void> _generate([String? presetPrompt]) async {
    final prompt = presetPrompt ?? _promptController.text.trim();
    if (prompt.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _response = null;
    });
    try {
      final result = await _aiService.generateText(prompt);
      setState(() => _response = result);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tools'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'AI Settings',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiSettingsScreen()),
              );
              _loadProvider();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.smart_toy_outlined,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Using ${_provider.label}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AiSettingsScreen()),
                    );
                    _loadProvider();
                  },
                  child: const Text('Switch'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _promptController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Ask anything — get summaries, practice questions, or explanations...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loading ? null : () => _generate(),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Generate'),
          ),
          const SizedBox(height: 20),
          const Text('Try one of these:',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions
                .map((s) => ActionChip(
                      label: Text(s,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                      onPressed: _loading ? null : () => _generate(s),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_error!,
                      style: TextStyle(color: Colors.red.shade700)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AiSettingsScreen()),
                      );
                      _loadProvider();
                    },
                    child: const Text('Open AI Settings'),
                  ),
                ],
              ),
            ),
          if (_response != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: MarkdownBody(data: _response!),
            ),
        ],
      ),
    );
  }
}
