import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../services/firestore_service.dart';

class ResourcesProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Resource> _allResources = [];
  bool _loading = false;
  String? _error;

  String? selectedCategory;
  String? selectedSubject;
  String? selectedClass;
  String? selectedStream;
  String searchQuery = '';

  List<Resource> get allResources => _allResources;
  bool get loading => _loading;
  String? get error => _error;

  List<Resource> get filteredResources {
    return _allResources.where((r) {
      if (selectedCategory != null && r.category != selectedCategory) {
        return false;
      }
      if (selectedSubject != null && r.subject != selectedSubject) {
        return false;
      }
      if (selectedClass != null && r.studentClass != selectedClass) {
        return false;
      }
      if (selectedStream != null && r.stream != selectedStream) {
        return false;
      }
      if (searchQuery.isNotEmpty &&
          !r.title.toLowerCase().contains(searchQuery.toLowerCase()) &&
          !r.description.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  List<String> get categories =>
      _allResources.map((r) => r.category).toSet().toList()..sort();
  List<String> get subjects =>
      _allResources.map((r) => r.subject).toSet().toList()..sort();

  Future<void> loadResources() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _allResources = await _firestoreService.getAllResources();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  void setFilters({
    String? category,
    String? subject,
    String? studentClass,
    String? stream,
  }) {
    selectedCategory = category;
    selectedSubject = subject;
    selectedClass = studentClass;
    selectedStream = stream;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    selectedCategory = null;
    selectedSubject = null;
    selectedClass = null;
    selectedStream = null;
    searchQuery = '';
    notifyListeners();
  }
}
