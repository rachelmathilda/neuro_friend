import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/brain_dump_entry.dart';
import '../data/repositories/brain_dump_repository.dart';
import '../services/gemma_service.dart';

final brainDumpRepositoryProvider = Provider<BrainDumpRepository>((ref) {
  return BrainDumpRepository();
});

final gemmaServiceProvider = Provider<GemmaService>((ref) => GemmaService());

final brainDumpListProvider =
    StateNotifierProvider<BrainDumpListNotifier, List<BrainDumpEntry>>((ref) {
  return BrainDumpListNotifier(ref.watch(brainDumpRepositoryProvider));
});

class BrainDumpListNotifier extends StateNotifier<List<BrainDumpEntry>> {
  BrainDumpListNotifier(this._repo) : super(_repo.all());

  final BrainDumpRepository _repo;

  void refresh() {
    state = _repo.all();
  }
}

final brainDumpByIdProvider =
    Provider.family<BrainDumpEntry?, String>((ref, id) {
  // Watch the list so changes propagate to consumers.
  ref.watch(brainDumpListProvider);
  return ref.watch(brainDumpRepositoryProvider).byId(id);
});

/// Runs the Gemma brain-dump call for [transcript], saves the resulting entry,
/// refreshes the list, and returns the persisted [BrainDumpEntry].
final processBrainDumpProvider =
    FutureProvider.autoDispose.family<BrainDumpEntry, String>((ref, transcript) async {
  final gemma = ref.read(gemmaServiceProvider);
  final repo = ref.read(brainDumpRepositoryProvider);
  final json = await gemma.processBrainDump(transcript);
  final entry = await repo.add(rawTranscript: transcript, gemmaJson: json);
  ref.read(brainDumpListProvider.notifier).refresh();
  return entry;
});

final processEmotionalProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, transcript) async {
  final gemma = ref.read(gemmaServiceProvider);
  return gemma.processEmotionalCheckin(transcript);
});

final processTaskCoachProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, transcript) async {
  final gemma = ref.read(gemmaServiceProvider);
  return gemma.processTaskCoach(transcript);
});
