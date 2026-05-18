import 'package:hive/hive.dart';

part 'brain_dump_entry.g.dart';

@HiveType(typeId: 10)
class BrainDumpEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String rawTranscript;

  @HiveField(3)
  final List<String> tasks;

  @HiveField(4)
  final List<String> ideas;

  @HiveField(5)
  final List<String> events;

  @HiveField(6)
  final List<String> worries;

  @HiveField(7)
  final String summary;

  BrainDumpEntry({
    required this.id,
    required this.timestamp,
    required this.rawTranscript,
    required this.tasks,
    required this.ideas,
    required this.events,
    required this.worries,
    required this.summary,
  });

  factory BrainDumpEntry.fromGemma({
    required String id,
    required DateTime timestamp,
    required String rawTranscript,
    required Map<String, dynamic> json,
  }) {
    List<String> readList(String key) {
      final v = json[key];
      if (v is List) {
        return v.map((e) => e.toString()).toList();
      }
      return const <String>[];
    }

    return BrainDumpEntry(
      id: id,
      timestamp: timestamp,
      rawTranscript: rawTranscript,
      tasks: readList('tasks'),
      ideas: readList('ideas'),
      events: readList('events'),
      worries: readList('worries'),
      summary: (json['summary'] ?? '').toString(),
    );
  }

  int get totalCount => tasks.length + ideas.length + events.length + worries.length;
}
