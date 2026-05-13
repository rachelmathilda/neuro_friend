import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/repositories/task_repository.dart';

class SchedulerRecapScreen extends ConsumerStatefulWidget {
  const SchedulerRecapScreen({super.key});

  @override
  ConsumerState<SchedulerRecapScreen> createState() =>
      _SchedulerRecapScreenState();
}

class _SchedulerRecapScreenState extends ConsumerState<SchedulerRecapScreen> {
  final _repo = TaskRepository();
  int _done = 0;
  int _missed = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await _repo.fetchWeeklyStats();
    setState(() {
      _done = stats['done'] ?? 0;
      _missed = stats['missed'] ?? 0;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduler Recap'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: '$_done',
                          label: 'Done',
                          color: AppColors.moodAnxious,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          value: '$_missed',
                          label: 'Missed',
                          color: AppColors.moodHappy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _WeeklyStreaks(),
                  const SizedBox(height: 16),
                  _FrequentMissedCard(
                    items: const ['Reply email', 'Exercise', 'Report'],
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headlineLarge.copyWith(color: color),
          ),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _WeeklyStreaks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final now = DateTime.now();
    final todayIndex = now.weekday % 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Streaks', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(days.length, (i) {
              final isToday = i == todayIndex;
              final isPast = i < todayIndex;
              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.streakToday
                      : isPast
                      ? AppColors.streakActive
                      : AppColors.streakInactive,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  days[i],
                  style: AppTextStyles.bodySmall.copyWith(
                    color: (isToday || isPast)
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FrequentMissedCard extends StatelessWidget {
  final List<String> items;
  const _FrequentMissedCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Frequent Missed Tasks', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(item, style: AppTextStyles.bodyMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
