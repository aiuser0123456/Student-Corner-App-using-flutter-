import 'package:flutter/material.dart';
import '../../models/resource.dart';
import '../../services/firestore_service.dart';
import '../../widgets/filter_sheet.dart' show kCategories, kSubjects, kClasses, kStreams;

class AddEditResourceScreen extends StatefulWidget {
  final Resource? existingResource;
  const AddEditResourceScreen({super.key, this.existingResource});

  @override
  State<AddEditResourceScreen> createState() => _AddEditResourceScreenState();
}

class _AddEditResourceScreenState extends State<AddEditResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _contentController;
  late TextEditingController _imageUrlController;
  late TextEditingController _pdfUrlController;
  late TextEditingController _downloadUrlController;

  late String _category;
  late String _subject;
  late String _studentClass;
  late String _stream;
  late bool _isDownloadable;
  bool _saving = false;

  bool get _isEditing => widget.existingResource != null;

  @override
  void initState() {
    super.initState();
    final r = widget.existingResource;
    _titleController = TextEditingController(text: r?.title ?? '');
    _descriptionController = TextEditingController(text: r?.description ?? '');
    _contentController = TextEditingController(text: r?.content ?? '');
    _imageUrlController = TextEditingController(text: r?.imageUrl ?? '');
    _pdfUrlController = TextEditingController(text: r?.pdfUrl ?? '');
    _downloadUrlController = TextEditingController(text: r?.downloadUrl ?? '');
    _category = r?.category ?? kCategories.first;
    _subject = r?.subject ?? kSubjects.first;
    _studentClass = r?.studentClass ?? kClasses.first;
    _stream = r?.stream ?? kStreams.first;
    _isDownloadable = r?.isDownloadable ?? false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final resource = Resource(
      id: widget.existingResource?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      subject: _subject,
      content: _contentController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      imageHint: '',
      studentClass: _studentClass,
      stream: _stream,
      pdfUrl: _pdfUrlController.text.trim().isEmpty
          ? null
          : _pdfUrlController.text.trim(),
      downloadUrl: _downloadUrlController.text.trim().isEmpty
          ? null
          : _downloadUrlController.text.trim(),
      isDownloadable: _isDownloadable,
    );

    try {
      if (_isEditing) {
        await _firestoreService.updateResource(
            widget.existingResource!.id, resource);
      } else {
        await _firestoreService.addResource(resource);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _dropdown(String label, String value, List<String> options,
      void Function(String) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: options
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      onChanged: (v) => onChanged(v!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_isEditing ? 'Edit Resource' : 'Add Resource')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                  labelText: 'Content (markdown supported)'),
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            _dropdown('Category', _category, kCategories,
                (v) => setState(() => _category = v)),
            const SizedBox(height: 16),
            _dropdown('Subject', _subject, kSubjects,
                (v) => setState(() => _subject = v)),
            const SizedBox(height: 16),
            _dropdown(
                'Class',
                _studentClass,
                kClasses,
                (v) => setState(() => _studentClass = v)),
            const SizedBox(height: 16),
            _dropdown('Stream', _stream, kStreams,
                (v) => setState(() => _stream = v)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pdfUrlController,
              decoration: const InputDecoration(labelText: 'PDF URL (optional)'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _downloadUrlController,
              decoration:
                  const InputDecoration(labelText: 'Download URL (optional)'),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Downloadable'),
              value: _isDownloadable,
              onChanged: (v) => setState(() => _isDownloadable = v),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_isEditing ? 'Save Changes' : 'Add Resource'),
            ),
          ],
        ),
      ),
    );
  }
}
