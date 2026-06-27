import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/resource.dart';

/// Mirrors src/lib/data.ts and src/lib/firestore.ts from the website —
/// all resources live in the `resources` Firestore collection.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _resources => _db.collection('resources');

  Future<List<Resource>> getAllResources() async {
    final snapshot = await _resources.get();
    return snapshot.docs
        .map((doc) =>
            Resource.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<List<Resource>> watchAllResources() {
    return _resources.snapshots().map((snapshot) => snapshot.docs
        .map((doc) =>
            Resource.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<Resource?> getResourceById(String id) async {
    final doc = await _resources.doc(id).get();
    if (doc.exists) {
      return Resource.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> addResource(Resource resource) {
    return _resources.add(resource.toMap());
  }

  Future<void> updateResource(String id, Resource resource) {
    return _resources.doc(id).update(resource.toMap());
  }

  Future<void> deleteResource(String id) {
    return _resources.doc(id).delete();
  }

  Future<List<String>> getCategories() async {
    final resources = await getAllResources();
    return resources.map((r) => r.category).toSet().toList();
  }

  Future<List<String>> getSubjects() async {
    final resources = await getAllResources();
    return resources.map((r) => r.subject).toSet().toList();
  }
}
