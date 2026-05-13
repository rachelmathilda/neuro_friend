import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { now, notYet, done, delayed }

enum TaskCategory { sensory, health, eat, job, other }

class TaskModel {
  final String id;
  final String title;
  final TaskCategory category;
  final TaskStatus status;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime date;
  final bool isUrgent;

  TaskModel({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.date,
    this.isUrgent = false,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      category: TaskCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TaskCategory.other,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TaskStatus.notYet,
      ),
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      date: (map['date'] as Timestamp).toDate(),
      isUrgent: map['isUrgent'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category.name,
      'status': status.name,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'date': Timestamp.fromDate(date),
      'isUrgent': isUrgent,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    TaskCategory? category,
    TaskStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? date,
    bool? isUrgent,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      date: date ?? this.date,
      isUrgent: isUrgent ?? this.isUrgent,
    );
  }
}
