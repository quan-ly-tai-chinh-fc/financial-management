import 'package:cloud_firestore/cloud_firestore.dart';

/// Generic ORM/repository cho Cloud Firestore.
/// Tách thao tác CRUD khỏi giao diện; mỗi model cung cấp toMap/fromMap.
class FirestoreRepository<T> {
  final FirebaseFirestore firestore;
  final String collection;
  final T Function(String id, Map<String, dynamic> data) fromMap;
  final Map<String, dynamic> Function(T value) toMap;

  FirestoreRepository({
    FirebaseFirestore? firestore,
    required this.collection,
    required this.fromMap,
    required this.toMap,
  }) : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection(collection);

  Future<String> create(T value) async {
    final ref = await _collection.add(toMap(value));
    return ref.id;
  }

  Future<T?> getById(String id) async {
    final snapshot = await _collection.doc(id).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    return fromMap(snapshot.id, snapshot.data()!);
  }

  Future<List<T>> getAll() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => fromMap(doc.id, doc.data())).toList();
  }

  Future<void> update(String id, T value) =>
      _collection.doc(id).set(toMap(value), SetOptions(merge: true));

  Future<void> delete(String id) => _collection.doc(id).delete();

  Stream<List<T>> watchAll() => _collection.snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => fromMap(doc.id, doc.data())).toList(),
      );
}
