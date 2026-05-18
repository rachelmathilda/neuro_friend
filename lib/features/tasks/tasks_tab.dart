import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/nf_screen.dart';
import '../../core/widgets/nf_tab_bar.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/models/task_model.dart';

class TasksTab extends StatefulWidget {
  final ValueChanged<NFTab> onTab;
  const TasksTab({super.key, required this.onTab});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  final _repo = TaskRepository();
  String _filter = 'all';
  List<TaskModel> _tasks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tasks = await _repo.fetchToday();
      if (mounted)
        setState(() {
          _tasks = tasks;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  List<TaskModel> get _filtered => _tasks.where((t) {
    switch (_filter) {
      case 'active':
        return t.status == TaskStatus.now || t.status == TaskStatus.notYet;
      case 'done':
        return t.status == TaskStatus.done;
      default:
        return true;
    }
  }).toList();

  @override
  Widget build(BuildContext context) {
    return NFScreen(
      tabActive: NFTab.tasks,
      onTab: widget.onTab,
      background: AppColors.bgSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Coach',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your tasks, broken down into small steps.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              for (final (id, label) in const [
                ('all', 'All'),
                ('active', 'Active'),
                ('done', 'Done'),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterPill(
                    label: label,
                    active: _filter == id,
                    onTap: () => setState(() => _filter = id),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.textTertiary,
              size: 32,
            ),
            const SizedBox(height: 10),
            Text(
              'Could not load tasks',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    final filtered = _filtered;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 8),
        itemCount: filtered.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          if (i == filtered.length) {
            return _AddTaskButton(onTap: () => widget.onTab(NFTab.mic));
          }
          return _TaskCard(
            task: filtered[i],
            onTap: () => Navigator.pushNamed(
              ctx,
              AppRoutes.taskSteps,
              arguments: filtered[i],
            ),
            onStatusChanged: (status) async {
              await _repo.updateStatus(filtered[i].id, status);
              _load();
            },
          );
        },
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.blue : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: active
            ? BorderSide.none
            : const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          decoration: active
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blue.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                )
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final ValueChanged<TaskStatus> onStatusChanged;
  const _TaskCard({
    required this.task,
    required this.onTap,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == TaskStatus.done;
    final isDelayed = task.status == TaskStatus.delayed;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: task.isUrgent
              ? AppColors.orange.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: isDone ? 0.78 : 1,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => onStatusChanged(
                    isDone ? TaskStatus.notYet : TaskStatus.done,
                  ),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.greenSoft
                          : AppColors.orangeSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isDone ? Icons.check_rounded : Icons.checklist_rounded,
                      size: 18,
                      color: isDone ? AppColors.green : AppColors.tasksAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: AppColors.textPrimary.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            _formatTime(task.startTime),
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (task.isUrgent) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.orangeSoft,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Urgent',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.tasksAccent,
                                ),
                              ),
                            ),
                          ],
                          if (isDelayed) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.pinkSoft,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Delayed',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.worriesAccent,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _categoryColor(task.category),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _categoryLabel(task.category),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Color _categoryColor(TaskCategory c) {
    switch (c) {
      case TaskCategory.sensory:
        return AppColors.lavenderSoft;
      case TaskCategory.health:
        return AppColors.greenSoft;
      case TaskCategory.eat:
        return AppColors.orangeSoft;
      case TaskCategory.job:
        return AppColors.blueSoft;
      case TaskCategory.other:
        return AppColors.cream;
    }
  }

  String _categoryLabel(TaskCategory c) {
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

class _AddTaskButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddTaskButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.blueSoft, width: 1.5),
        ),
        padding: const EdgeInsets.all(14),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 16, color: AppColors.blue),
            SizedBox(width: 8),
            Text(
              'Add via voice',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
