class FocusSessionModel {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int duration;

  FocusSessionModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.duration,
  });
}
