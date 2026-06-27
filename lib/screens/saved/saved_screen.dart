import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resources_provider.dart';
import '../../services/saved_resources_service.dart';
import '../../widgets/resource_card.dart';
import '../resources/resource_detail_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final _savedService = SavedResourcesService();
  Set<String> _savedIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final provider = context.read<ResourcesProvider>();
    if (provider.allResources.isEmpty) {
      await provider.loadResources();
    }
    final ids = await _savedService.getSavedIds();
    if (mounted) {
      setState(() {
        _savedIds = ids.toSet();
        _loading = false;
      });
    }
  }

  Future<void> _toggleSave(String id) async {
    await _savedService.toggleSaved(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResourcesProvider>();
    final saved =
        provider.allResources.where((r) => _savedIds.contains(r.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Resources')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : saved.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bookmark_border,
                            size: 56, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          "You haven't saved any resources yet.\nTap the bookmark icon on a resource to save it here.",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: saved.length,
                    itemBuilder: (context, index) {
                      final resource = saved[index];
                      return ResourceCard(
                        resource: resource,
                        isSaved: true,
                        onToggleSave: () => _toggleSave(resource.id),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResourceDetailScreen(
                                resourceId: resource.id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
