import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../data/models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../core/widgets/bottom_nav.dart';

class TodosScreen extends ConsumerStatefulWidget {
  const TodosScreen({super.key});

  @override
  ConsumerState<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends ConsumerState<TodosScreen> {
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
    ref.read(taskProvider.notifier).fetchToday();
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('TODOs', style: AppTextStyles.headlineSmall)],
              ),
            ),
            const SizedBox(height: 12),
            _FilterChips(
              selected: _filterIndex,
              onSelected: (i) => setState(() => _filterIndex = i),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: taskState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (tasks) {
                  final filtered = _filter(tasks);
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: filtered.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      if (i == 0) return _BrainDumpCard();
                      return _TaskCard(task: filtered[i - 1]);
                    },
                  );
                },
              ),
            ),
            BottomNav(currentIndex: 1),
          ],
        ),
      ),
    );
  }

  List<TaskModel> _filter(List<TaskModel> tasks) {
    switch (_filterIndex) {
      case 1:
        return tasks.where((t) => t.isUrgent).toList();
      case 2:
        return tasks.where((t) => t.status == TaskStatus.delayed).toList();
      default:
        return tasks;
    }
  }
}

class _FilterChips extends StatelessWidget {
  final int selected;
  final void Function(int) onSelected;

  const _FilterChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final labels = ['All', 'Urgent', 'Delayed'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isSelected = i == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  labels[i],
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BrainDumpCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.brainDump),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Brain Dump', style: AppTextStyles.titleMedium),
                Text(
                  'Write your thought here..',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final isNow = task.status == TaskStatus.now;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNow ? const Color(0xFFFFF3CC) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(task.title, style: AppTextStyles.titleMedium),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusLabel(task.status),
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _CategoryChip(category: task.category),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${_fmt(task.startTime)} - ${_fmt(task.endTime)}',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(_fmtDate(task.date), style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(TaskStatus s) {
    switch (s) {
      case TaskStatus.now:
        return 'Now';
      case TaskStatus.notYet:
        return 'Not Yet';
      case TaskStatus.done:
        return 'Done';
      case TaskStatus.delayed:
        return 'Delayed';
    }
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')}';

  String _fmtDate(DateTime dt) => '${dt.day} ${_month(dt.month)} ${dt.year}';

  String _month(int m) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m];
  }
}

class _CategoryChip extends StatelessWidget {
  final TaskCategory category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _color(category),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _label(category),
        style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      ),
    );
  }

  Color _color(TaskCategory c) {
    switch (c) {
      case TaskCategory.sensory:
        return AppColors.tagSensory;
      case TaskCategory.health:
        return AppColors.tagHealth;
      case TaskCategory.eat:
        return AppColors.tagEat;
      case TaskCategory.job:
        return AppColors.tagJob;
      case TaskCategory.other:
        return AppColors.textSecondary;
    }
  }

  String _label(TaskCategory c) {
    switch (c) {
      case TaskCategory.sensory:
        return 'Sensory';
      case TaskCategory.health:
        return 'Health';
      case TaskCategory.eat:
        return 'Eat';
      case TaskCategory.job:
        return 'Job';
      case TaskCategory.other:
        return 'Other';
    }
  }
}
