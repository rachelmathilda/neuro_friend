import 'package:hive/hive.dart';
import '../models/brain_dump_entry.dart';

class BrainDumpRepository {
  static const String boxName = 'brain_dumps';

  Box<BrainDumpEntry> get _box => Hive.box<BrainDumpEntry>(boxName);

  Future<BrainDumpEntry> add({
    required String rawTranscript,
    required Map<String, dynamic> gemmaJson,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final entry = BrainDumpEntry.fromGemma(
      id: id,
      timestamp: DateTime.now(),
      rawTranscript: rawTranscript,
      json: gemmaJson,
    );
    await _box.put(id, entry);
    return entry;
  }

  List<BrainDumpEntry> all() {
    final items = _box.values.toList();
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  BrainDumpEntry? byId(String id) => _box.get(id);

  Future<void> delete(String id) => _box.delete(id);

  Future<List<BrainDumpEntry>> fetchRecent({int limit = 100}) async {
    final items = all();
    return items.take(limit).toList();
  }
}
