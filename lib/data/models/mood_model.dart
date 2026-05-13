import 'package:cloud_firestore/cloud_firestore.dart';

enum MoodType { happy, calm, angry, anxious }

class MoodModel {
  final String id;
  final MoodType mood;
  final DateTime timestamp;
  final String? note;

  MoodModel({
    required this.id,
    required this.mood,
    required this.timestamp,
    this.note,
  });

  factory MoodModel.fromMap(Map<String, dynamic> map, String id) {
    return MoodModel(
      id: id,
      mood: MoodType.values.firstWhere(
        (e) => e.name == map['mood'],
        orElse: () => MoodType.calm,
      ),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mood': mood.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'note': note,
    };
  }
}
