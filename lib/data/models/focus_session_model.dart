import 'package:cloud_firestore/cloud_firestore.dart';

class FocusSessionModel {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration reminderInterval;
  final bool allowAppSwitch;
  final String? currentTaskId;
  final List<String> distractions;

  FocusSessionModel({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.reminderInterval,
    required this.allowAppSwitch,
    this.currentTaskId,
    this.distractions = const [],
  });

  bool get isActive => endTime == null;

  Duration get elapsed {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  factory FocusSessionModel.fromMap(Map<String, dynamic> map, String id) {
    return FocusSessionModel(
      id: id,
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: map['endTime'] != null
          ? (map['endTime'] as Timestamp).toDate()
          : null,
      reminderInterval: Duration(minutes: map['reminderMinutes'] ?? 60),
      allowAppSwitch: map['allowAppSwitch'] ?? false,
      currentTaskId: map['currentTaskId'],
      distractions: List<String>.from(map['distractions'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'reminderMinutes': reminderInterval.inMinutes,
      'allowAppSwitch': allowAppSwitch,
      'currentTaskId': currentTaskId,
      'distractions': distractions,
    };
  }
}
