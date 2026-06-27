import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/resource.dart';
import '../../services/firestore_service.dart';
import '../../services/saved_resources_service.dart';
import '../../theme/app_theme.dart';
import 'pdf_viewer_screen.dart';

class ResourceDetailScreen extends StatefulWidget {
  final String resourceId;
  const ResourceDetailScreen({super.key, required this.resourceId});

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  final _firestoreService = FirestoreService();
  final _savedService = SavedResourcesService();
  Resource? _resource;
  bool _loading = true;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final resource =
        await _firestoreService.getResourceById(widget.resourceId);
    final isSaved = await _savedService.isSaved(widget.resourceId);
    if (mounted) {
      setState(() {
        _resource = resource;
        _isSaved = isSaved;
        _loading = false;
      });
    }
  }

  Future<void> _toggleSave() async {
    await _savedService.toggleSaved(widget.resourceId);
    setState(() => _isSaved = !_isSaved);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    if (_resource == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Resource not found.')),
      );
    }
    final r = _resource!;

    return Scaffold(
      appBar: AppBar(
        title: Text(r.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _toggleSave,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (r.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                r.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: AppColors.muted,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(r.category)),
              Chip(label: Text(r.subject)),
              Chip(
                  label: Text(
                      r.studentClass == 'class11' ? 'Class 11' : 'Class 12')),
              Chip(label: Text(r.stream)),
            ],
          ),
          const SizedBox(height: 16),
          Text(r.title,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(r.description,
              style: const TextStyle(color: AppColors.mutedForeground)),
          const Divider(height: 32),
          MarkdownBody(data: r.content),
          const SizedBox(height: 24),
          if (r.pdfUrl != null && r.pdfUrl!.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PdfViewerScreen(
                      url: r.pdfUrl!, title: r.title),
                ),
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('View PDF'),
            ),
          if (r.isDownloadable &&
              r.downloadUrl != null &&
              r.downloadUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: OutlinedButton.icon(
                onPressed: () =>
                    launchUrl(Uri.parse(r.downloadUrl!),
                        mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.download_outlined),
                label: const Text('Download'),
              ),
            ),
        ],
      ),
    );
  }
}
