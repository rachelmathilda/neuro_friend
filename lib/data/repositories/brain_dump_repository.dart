import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/brain_dump_model.dart';

class BrainDumpRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _collection =>
      _db.collection('users').doc(_uid).collection('brain_dumps');

  Future<void> save(BrainDumpModel dump) async {
    await _collection.doc(dump.id).set(dump.toMap());
  }

  Future<List<BrainDumpModel>> fetchRecent({int limit = 20}) async {
    final snapshot = await _collection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map(
          (d) => BrainDumpModel.fromMap(d.data() as Map<String, dynamic>, d.id),
        )
        .toList();
  }

  Future<Map<String, int>> fetchTotals() async {
    final dumps = await fetchRecent(limit: 100);
    return {
      'tasks': dumps.fold(0, (acc, d) => acc + d.taskCount),
      'ideas': dumps.fold(0, (acc, d) => acc + d.ideaCount),
      'events': dumps.fold(0, (acc, d) => acc + d.eventCount),
      'worries': dumps.fold(0, (acc, d) => acc + d.worryCount),
    };
  }

  Future<void> delete(String dumpId) async {
    await _collection.doc(dumpId).delete();
  }
}
