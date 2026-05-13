import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_model.dart';

class MoodRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _collection =>
      _db.collection('users').doc(_uid).collection('moods');

  Future<List<MoodModel>> fetchRecent({int days = 7}) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final snapshot = await _collection
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((d) => MoodModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Future<void> add(MoodModel mood) async {
    await _collection.doc(mood.id).set(mood.toMap());
  }

  Future<MoodModel?> fetchToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final snapshot = await _collection
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('timestamp', isLessThan: Timestamp.fromDate(end))
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return MoodModel.fromMap(
      snapshot.docs.first.data() as Map<String, dynamic>,
      snapshot.docs.first.id,
    );
  }
}
