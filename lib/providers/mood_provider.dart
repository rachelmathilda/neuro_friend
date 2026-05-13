import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/mood_model.dart';

final moodProvider =
    StateNotifierProvider<MoodNotifier, AsyncValue<List<MoodModel>>>(
      (ref) => MoodNotifier(),
    );

class MoodNotifier extends StateNotifier<AsyncValue<List<MoodModel>>> {
  MoodNotifier() : super(const AsyncValue.loading());

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _collection =>
      _db.collection('users').doc(_uid).collection('moods');

  Future<void> fetchRecent({int days = 7}) async {
    try {
      final since = DateTime.now().subtract(Duration(days: days));
      final snapshot = await _collection
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
          .orderBy('timestamp', descending: true)
          .get();

      state = AsyncValue.data(
        snapshot.docs
            .map(
              (d) => MoodModel.fromMap(d.data() as Map<String, dynamic>, d.id),
            )
            .toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logMood(MoodType mood, {String? note}) async {
    final entry = MoodModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mood: mood,
      timestamp: DateTime.now(),
      note: note,
    );
    await _collection.doc(entry.id).set(entry.toMap());
    await fetchRecent();
  }

  MoodType? get todayMood {
    if (state is! AsyncData) return null;
    final moods = (state as AsyncData<List<MoodModel>>).value;
    final today = DateTime.now();
    final todayMoods = moods.where(
      (m) =>
          m.timestamp.year == today.year &&
          m.timestamp.month == today.month &&
          m.timestamp.day == today.day,
    );
    return todayMoods.isEmpty ? null : todayMoods.first.mood;
  }
}
