import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/focus_session_model.dart';

class FocusRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _collection =>
      _db.collection('users').doc(_uid).collection('focus_sessions');

  Future<void> save(FocusSessionModel session) async {
    await _collection.doc(session.id).set(session.toMap());
  }

  Future<void> end(String sessionId) async {
    await _collection.doc(sessionId).update({
      'endTime': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<List<FocusSessionModel>> fetchRecent({int days = 30}) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final snapshot = await _collection
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('startTime', descending: true)
        .get();

    return snapshot.docs
        .map(
          (d) =>
              FocusSessionModel.fromMap(d.data() as Map<String, dynamic>, d.id),
        )
        .toList();
  }

  Future<Map<String, dynamic>> fetchStats() async {
    final sessions = await fetchRecent(days: 30);
    if (sessions.isEmpty) return {'avgHours': 0.0, 'bestHour': 0};

    final completed = sessions.where((s) => s.endTime != null).toList();
    final totalMinutes = completed.fold<int>(
      0,
      (acc, s) => acc + s.elapsed.inMinutes,
    );

    final avgHours = completed.isEmpty
        ? 0.0
        : totalMinutes / completed.length / 60;

    final hourCounts = <int, int>{};
    for (final s in completed) {
      final hour = s.startTime.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    final bestHour = hourCounts.isEmpty
        ? 9
        : hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final allDistractions = completed.expand((s) => s.distractions).toList();

    final distractionCounts = <String, int>{};
    for (final d in allDistractions) {
      distractionCounts[d] = (distractionCounts[d] ?? 0) + 1;
    }

    final topDistractions = distractionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'avgHours': avgHours,
      'bestHour': bestHour,
      'topDistractions': topDistractions.take(3).map((e) => e.key).toList(),
    };
  }
}
