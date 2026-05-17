import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/nf_screen.dart';
import '../../core/widgets/nf_tab_bar.dart';

enum _TaskStatus { active, fresh, done }

class _Task {
  final String id, title, due;
  final int done, total, mins;
  final _TaskStatus status;
  const _Task(this.id, this.title, this.done, this.total, this.mins,
      this.status, this.due);
}

const _tasks = <_Task>[
  _Task('t1', 'Make Q2 presentation', 2, 6, 47, _TaskStatus.active, 'Today'),
  _Task('t2', 'Send proposal email', 0, 3, 18, _TaskStatus.fresh, 'Tomorrow'),
  _Task('t3', 'Weekly groceries', 4, 4, 25, _TaskStatus.done, 'Yesterday'),
];

class TasksTab extends StatefulWidget {
  final ValueChanged<NFTab> onTab;
  const TasksTab({super.key, required this.onTab});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final filtered = _tasks.where((t) {
      switch (_filter) {
        case 'active':
          return t.status == _TaskStatus.active || t.status == _TaskStatus.fresh;
        case 'done':
          return t.status == _TaskStatus.done;
        default:
          return true;
      }
    }).toList();

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
                Text('Task Coach',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimary)),
                SizedBox(height: 4),
                Text('Your tasks, broken down into small steps.',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
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
          Expanded(
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
                  onTap: () => Navigator.pushNamed(ctx, AppRoutes.taskSteps),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterPill({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.blue : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: active ? BorderSide.none : const BorderSide(color: AppColors.border),
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
                      color: AppColors.blue.withOpacity(0.25),
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
  final _Task task;
  final VoidCallback onTap;
  const _TaskCard({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == _TaskStatus.done;
    final pct = task.total == 0 ? 0.0 : task.done / task.total;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: isDone ? 0.78 : 1,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
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
                              decorationColor:
                                  AppColors.textPrimary.withOpacity(0.4),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${task.due}  ·  ±${task.mins} min',
                            style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDone ? AppColors.greenSoft : AppColors.cream,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${task.done}/${task.total}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDone
                              ? AppColors.greenAccent
                              : AppColors.tasksAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(
                        isDone ? AppColors.green : AppColors.orange),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
          border: Border.all(
            color: AppColors.blueSoft,
            width: 1.5,
            style: BorderStyle.solid,
          ),
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
