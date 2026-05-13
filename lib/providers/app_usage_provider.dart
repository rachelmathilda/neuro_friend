import 'package:app_usage/app_usage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppUsageEntry {
  final String packageName;
  final String appName;
  final Duration usage;

  AppUsageEntry({
    required this.packageName,
    required this.appName,
    required this.usage,
  });
}

final appUsageProvider =
    StateNotifierProvider<AppUsageNotifier, AsyncValue<List<AppUsageEntry>>>(
      (ref) => AppUsageNotifier(),
    );

class AppUsageNotifier extends StateNotifier<AsyncValue<List<AppUsageEntry>>> {
  AppUsageNotifier() : super(const AsyncValue.loading());

  Future<void> fetchToday() async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final infos = await AppUsage().getAppUsage(start, now);

      final entries =
          infos
              .where((info) => info.usage.inMinutes > 0)
              .map(
                (info) => AppUsageEntry(
                  packageName: info.packageName,
                  appName: info.appName,
                  usage: info.usage,
                ),
              )
              .toList()
            ..sort((a, b) => b.usage.compareTo(a.usage));

      state = AsyncValue.data(entries);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Duration get totalUsageToday {
    if (state is! AsyncData) return Duration.zero;
    final entries = (state as AsyncData<List<AppUsageEntry>>).value;
    return entries.fold(Duration.zero, (sum, e) => sum + e.usage);
  }
}
