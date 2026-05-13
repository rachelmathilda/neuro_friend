import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/task_model.dart';

final taskProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<List<TaskModel>>>(
      (ref) => TaskNotifier(),
    );

class TaskNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  TaskNotifier() : super(const AsyncValue.loading());

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _collection =>
      _db.collection('users').doc(_uid).collection('tasks');

  Future<void> fetchToday() async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));

      final snapshot = await _collection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThan: Timestamp.fromDate(end))
          .orderBy('date')
          .get();

      state = AsyncValue.data(
        snapshot.docs
            .map(
              (d) => TaskModel.fromMap(d.data() as Map<String, dynamic>, d.id),
            )
            .toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTask(TaskModel task) async {
    await _collection.doc(task.id).set(task.toMap());
    await fetchToday();
  }

  Future<void> updateStatus(String taskId, TaskStatus status) async {
    await _collection.doc(taskId).update({'status': status.name});
    await fetchToday();
  }

  Future<void> deleteTask(String taskId) async {
    await _collection.doc(taskId).delete();
    await fetchToday();
  }
}
