import 'package:cloud_firestore/cloud_firestore.dart';

class BrainDumpModel {
  final String id;
  final DateTime createdAt;
  final String summary;
  final List<String> tasks;
  final List<String> ideas;
  final List<String> events;
  final List<String> worries;

  BrainDumpModel({
    required this.id,
    required this.createdAt,
    required this.summary,
    required this.tasks,
    required this.ideas,
    required this.events,
    required this.worries,
  });

  int get taskCount => tasks.length;
  int get ideaCount => ideas.length;
  int get eventCount => events.length;
  int get worryCount => worries.length;

  factory BrainDumpModel.fromAiResult(Map<String, dynamic> data) {
    return BrainDumpModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      summary: data['summary'] as String? ?? '',
      tasks: _toList(data['tasks']),
      ideas: _toList(data['ideas']),
      events: _toList(data['events']),
      worries: _toList(data['worries']),
    );
  }

  factory BrainDumpModel.fromMap(Map<String, dynamic> map, String id) {
    return BrainDumpModel(
      id: id,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      summary: map['summary'] as String? ?? '',
      tasks: _toList(map['tasks']),
      ideas: _toList(map['ideas']),
      events: _toList(map['events']),
      worries: _toList(map['worries']),
    );
  }

  Map<String, dynamic> toMap() => {
    'createdAt': Timestamp.fromDate(createdAt),
    'summary': summary,
    'tasks': tasks,
    'ideas': ideas,
    'events': events,
    'worries': worries,
  };

  static List<String> _toList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }
}
