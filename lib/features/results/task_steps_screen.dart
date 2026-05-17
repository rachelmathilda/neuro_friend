import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/nf_button.dart';
import '../../core/widgets/nf_screen.dart';

class TaskStep {
  final int n;
  final String title, hint;
  final int mins;
  const TaskStep(this.n, this.title, this.mins, this.hint);
}

const taskSteps = <TaskStep>[
  TaskStep(1, 'Open PowerPoint, pick a clean template', 2,
      "Don't start from scratch. Any template will do."),
  TaskStep(2, 'Write 10 slide titles', 5, 'Titles only — no content yet.'),
  TaskStep(3, 'Fill slides 1–3: key data', 10,
      'Copy-paste numbers from the spreadsheet.'),
  TaskStep(4, 'Fill slides 4–7: analysis & charts', 15,
      'Add 2–3 simple charts.'),
  TaskStep(5, 'Fill slides 8–10: conclusion', 10,
      '3 challenge points, 3 plan points.'),
  TaskStep(6, 'Review & polish', 5,
      "Check typos. Don't be a perfectionist — 80% is enough!"),
];

class TaskStepsScreen extends StatelessWidget {
  final List<int> completed;
  const TaskStepsScreen({super.key, this.completed = const []});

  @override
  Widget build(BuildContext context) {
    final done = completed.length;
    return NFScreen(
      hideTabs: true,
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NFHeader(title: 'Task Coach', onBack: () => Navigator.pop(context)),
          Container(
            decoration: BoxDecoration(
              color: AppColors.creamSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('"Make Q2 presentation"',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      SizedBox(height: 2),
                      Text('6 steps · ≈47 min',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('$done/6',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.creamAccent)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: taskSteps.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final step = taskSteps[i];
                final isDone = completed.contains(step.n);
                return _StepCard(step: step, completed: isDone);
              },
            ),
          ),
          const SizedBox(height: 12),
          if (done > 0)
            Container(
              decoration: BoxDecoration(
                color: AppColors.greenSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              alignment: Alignment.center,
              child: Text(
                '🎯 $done/6 done — you\'re on fire!',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greenAccent),
              ),
            )
          else
            const Text(
              '"Start at step 1? Just 2 minutes!"',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: AppColors.tasksAccent),
            ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final TaskStep step;
  final bool completed;
  const _StepCard({required this.step, required this.completed});

  @override
  Widget build(BuildContext context) {
    final bg = completed ? AppColors.greenSoft : AppColors.surface;
    final borderColor =
        completed ? AppColors.green.withOpacity(0.5) : AppColors.border;
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Opacity(
        opacity: completed ? 0.85 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: completed ? AppColors.green : AppColors.orangeSoft,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: completed
                      ? const Icon(Icons.check_rounded,
                          size: 16, color: Colors.white)
                      : Text('${step.n}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.tasksAccent)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          decoration: completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor:
                              AppColors.textPrimary.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(step.hint,
                          style: const TextStyle(
                              fontSize: 11.5,
                              height: 1.4,
                              color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('${step.mins} min',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary)),
                ),
              ],
            ),
            if (!completed)
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 42),
                child: NFButton(
                  label: 'Start this step',
                  variant: NFButtonVariant.pillSmall,
                  onPressed: () => Navigator.pushNamed(
                      context, AppRoutes.taskTimer,
                      arguments: step.n),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
