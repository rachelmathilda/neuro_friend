import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../data/models/task_model.dart';
import '../../providers/task_provider.dart';

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
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Text(
              'TODOs',
              style: AppTextStyles.titleLarge.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w100,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (i) {
                  final labels = ['All', 'Urgent', 'Delayed'];
                  final isSelected = i == _filterIndex;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i == 2 ? 0 : 10),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _filterIndex = i;
                        }),
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF4D83D9)
                                : const Color(0xFF43639C),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            labels[i],
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 18),

            Expanded(
              child: taskState.when(
                loading: () => const Center(child: CircularProgressIndicator()),

                error: (_, __) =>
                    const Center(child: Text('Failed loading tasks')),

                data: (tasks) {
                  final filtered = _filter(tasks);

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: filtered.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return _BrainDumpCard();
                      }

                      final task = filtered[i - 1];

                      return _TaskCard(task: task);
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

class _BrainDumpCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.brainDump),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Brain Dump',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Write your thought here..',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const Icon(Icons.edit_outlined, size: 24, color: Colors.black87),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isNow ? const Color(0xFFF5E8BF) : const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.title,
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isNow ? Colors.black : Colors.grey,
                ),
              ),

              Container(
                width: 100,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  _statusLabel(task.status),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _CategoryChip(category: task.category),

          const SizedBox(height: 18),

          Row(
            children: [
              const Icon(Icons.access_time, size: 24, color: Colors.grey),

              const SizedBox(width: 8),

              Text(
                '${_fmt(task.startTime)} - ${_fmt(task.endTime)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),

              const Spacer(),

              const Icon(
                Icons.calendar_today_outlined,
                size: 22,
                color: Colors.grey,
              ),

              const SizedBox(width: 8),

              Text(
                _fmtDate(task.date),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
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
      'may',
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
      width: 80,
      height: 28,
      decoration: BoxDecoration(
        color: _color(category),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        _label(category),
        style: AppTextStyles.bodySmall.copyWith(
          color: Colors.black87,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _color(TaskCategory c) {
    switch (c) {
      case TaskCategory.sensory:
        return const Color(0xFFF5A9B2);

      case TaskCategory.health:
        return const Color(0xFFFFA126);

      case TaskCategory.eat:
        return const Color(0xFF8FD063);

      case TaskCategory.job:
        return const Color(0xFFD8C9F5);

      case TaskCategory.other:
        return Colors.grey.shade300;
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
