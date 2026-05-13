import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _collection =>
      _db.collection('users').doc(_uid).collection('tasks');

  Future<List<TaskModel>> fetchToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final snapshot = await _collection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('startTime')
        .get();

    return snapshot.docs
        .map((d) => TaskModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Future<List<TaskModel>> fetchByDateRange(DateTime from, DateTime to) async {
    final snapshot = await _collection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('date', isLessThan: Timestamp.fromDate(to))
        .orderBy('date')
        .get();

    return snapshot.docs
        .map((d) => TaskModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Future<void> add(TaskModel task) async {
    await _collection.doc(task.id).set(task.toMap());
  }

  Future<void> updateStatus(String taskId, TaskStatus status) async {
    await _collection.doc(taskId).update({'status': status.name});
  }

  Future<void> update(TaskModel task) async {
    await _collection.doc(task.id).update(task.toMap());
  }

  Future<void> delete(String taskId) async {
    await _collection.doc(taskId).delete();
  }

  Future<Map<String, int>> fetchWeeklyStats() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final tasks = await fetchByDateRange(
      DateTime(weekStart.year, weekStart.month, weekStart.day),
      now,
    );

    int done = 0;
    int missed = 0;
    final Map<String, List<String>> frequentMissed = {};

    for (final task in tasks) {
      if (task.status == TaskStatus.done) {
        done++;
      } else if (task.status == TaskStatus.delayed) {
        missed++;
        frequentMissed[task.title] = (frequentMissed[task.title] ?? [])
          ..add(task.id);
      }
    }

    return {'done': done, 'missed': missed};
  }
}
