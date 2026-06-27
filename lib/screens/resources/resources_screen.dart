import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resources_provider.dart';
import '../../services/saved_resources_service.dart';
import '../../widgets/resource_card.dart';
import '../../widgets/filter_sheet.dart';
import 'resource_detail_screen.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final _savedService = SavedResourcesService();
  Set<String> _savedIds = {};

  @override
  void initState() {
    super.initState();
    final provider = context.read<ResourcesProvider>();
    if (provider.allResources.isEmpty) {
      provider.loadResources();
    }
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final ids = await _savedService.getSavedIds();
    if (mounted) setState(() => _savedIds = ids.toSet());
  }

  Future<void> _toggleSave(String id) async {
    await _savedService.toggleSaved(id);
    _loadSaved();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResourcesProvider>();
    final hasActiveFilters = provider.selectedCategory != null ||
        provider.selectedSubject != null ||
        provider.selectedClass != null ||
        provider.selectedStream != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: hasActiveFilters,
              child: const Icon(Icons.tune),
            ),
            onPressed: () => showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search resources...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => provider.setSearchQuery(v),
            ),
          ),
          if (hasActiveFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: provider.clearFilters,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Clear filters'),
                ),
              ),
            ),
          Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? Center(child: Text('Error: ${provider.error}'))
                    : provider.filteredResources.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'No resources found. Try adjusting your filters or search.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: provider.loadResources,
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: provider.filteredResources.length,
                              itemBuilder: (context, index) {
                                final resource =
                                    provider.filteredResources[index];
                                return ResourceCard(
                                  resource: resource,
                                  isSaved: _savedIds.contains(resource.id),
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
          ),
        ],
      ),
    );
  }
}
