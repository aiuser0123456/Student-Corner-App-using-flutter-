import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resources_provider.dart';
import '../../services/firestore_service.dart';
import 'add_edit_resource_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    context.read<ResourcesProvider>().loadResources();
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete resource?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _firestoreService.deleteResource(id);
      if (mounted) context.read<ResourcesProvider>().loadResources();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResourcesProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Resource'),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditResourceScreen()),
          );
          provider.loadResources();
        },
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    border: Border.all(color: Colors.amber.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Note: your website writes resources via a server-side '
                    'Admin SDK action, while this screen writes directly from '
                    'the device. Your deployed firestore.rules only allow writes '
                    'from accounts with an "isAdmin" custom auth claim — set that '
                    'claim (e.g. via a Cloud Function) for this screen to work, '
                    'or keep using the website\'s admin panel for now.',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ),
                Expanded(child: _resourceList(context, provider)),
              ],
            ),
    );
  }

  Widget _resourceList(BuildContext context, ResourcesProvider provider) {
    return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.allResources.length,
              itemBuilder: (context, index) {
                final r = provider.allResources[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(r.title,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${r.category} • ${r.subject}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditResourceScreen(
                                    existingResource: r),
                              ),
                            );
                            provider.loadResources();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => _delete(r.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
    );
  }
}
