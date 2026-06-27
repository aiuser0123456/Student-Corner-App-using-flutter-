import 'package:shared_preferences/shared_preferences.dart';

/// Mirrors the website's use-saved-resources hook: keeps a local
/// list of bookmarked resource IDs on-device.
class SavedResourcesService {
  static const _key = 'saved_resource_ids';

  Future<List<String>> getSavedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<bool> isSaved(String id) async {
    final ids = await getSavedIds();
    return ids.contains(id);
  }

  Future<void> toggleSaved(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key) ?? [];
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await prefs.setStringList(_key, ids);
  }
}
