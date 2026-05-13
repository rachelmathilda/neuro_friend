import 'package:cloud_firestore/cloud_firestore.dart';

enum SensoryLevel { mild, moderate, heavy }

enum SensoryTrigger { crowd, brightLight, loudSound, texture, smell, other }

class SensoryLogModel {
  final String id;
  final SensoryLevel level;
  final List<SensoryTrigger> triggers;
  final DateTime timestamp;
  final String? note;

  SensoryLogModel({
    required this.id,
    required this.level,
    required this.triggers,
    required this.timestamp,
    this.note,
  });

  factory SensoryLogModel.fromMap(Map<String, dynamic> map, String id) {
    return SensoryLogModel(
      id: id,
      level: SensoryLevel.values.firstWhere(
        (e) => e.name == map['level'],
        orElse: () => SensoryLevel.mild,
      ),
      triggers: (map['triggers'] as List<dynamic>? ?? [])
          .map(
            (t) => SensoryTrigger.values.firstWhere(
              (e) => e.name == t,
              orElse: () => SensoryTrigger.other,
            ),
          )
          .toList(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level.name,
      'triggers': triggers.map((t) => t.name).toList(),
      'timestamp': Timestamp.fromDate(timestamp),
      'note': note,
    };
  }
}
