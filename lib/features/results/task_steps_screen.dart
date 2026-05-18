import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/task_step_model.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/nf_button.dart';
import '../../core/widgets/nf_screen.dart';

class TaskStepsScreen extends StatefulWidget {
  const TaskStepsScreen({super.key});

  @override
  State<TaskStepsScreen> createState() => _TaskStepsScreenState();
}

class _TaskStepsScreenState extends State<TaskStepsScreen> {
  List<TaskStepModel> _steps = [];
  String _taskTitle = '';
  int _totalMinutes = 0;
  String _firstMove = '';
  final Set<int> _completed = {};
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _steps = (args['steps'] as List<TaskStepModel>?) ?? [];
        _taskTitle = (args['taskTitle'] as String?) ?? '';
        _totalMinutes = (args['totalMinutes'] as int?) ?? 0;
        _firstMove = (args['firstMove'] as String?) ?? '';
      }
      if (_steps.isEmpty) {
        _steps = TaskStepModel.fallback(_taskTitle);
        _totalMinutes = _steps.fold(0, (sum, s) => sum + s.mins);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = _completed.length;
    final total = _steps.length;

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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"$_taskTitle"',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$total steps · ≈$_totalMinutes min',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
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
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$done/$total',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.creamAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_firstMove.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.orangeSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Start here: $_firstMove',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tasksAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: _steps.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final step = _steps[i];
                final isDone = _completed.contains(step.n);
                return _StepCard(
                  step: step,
                  completed: isDone,
                  onStartTap: () =>
                      Navigator.pushNamed(
                        context,
                        AppRoutes.taskTimer,
                        arguments: {'stepNumber': step.n, 'steps': _steps},
                      ).then((_) {
                        setState(() => _completed.add(step.n));
                      }),
                );
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              alignment: Alignment.center,
              child: Text(
                '🎯 $done/$total done — you\'re on fire!',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.greenAccent,
                ),
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
                color: AppColors.tasksAccent,
              ),
            ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final TaskStepModel step;
  final bool completed;
  final VoidCallback onStartTap;

  const _StepCard({
    required this.step,
    required this.completed,
    required this.onStartTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = completed ? AppColors.greenSoft : AppColors.surface;
    final borderColor = completed
        ? AppColors.green.withValues(alpha: 0.5)
        : AppColors.border;
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
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        )
                      : Text(
                          '${step.n}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.tasksAccent,
                          ),
                        ),
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
                          decorationColor: AppColors.textPrimary.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        step.hint,
                        style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.4,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${step.mins} min',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
            if (!completed)
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 42),
                child: NFButton(
                  label: 'Start this step',
                  variant: NFButtonVariant.pillSmall,
                  onPressed: onStartTap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
