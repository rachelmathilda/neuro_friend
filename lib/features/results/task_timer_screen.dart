import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/task_step_model.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/nf_button.dart';
import '../../core/widgets/nf_screen.dart';

class TaskTimerScreen extends StatefulWidget {
  const TaskTimerScreen({super.key});

  @override
  State<TaskTimerScreen> createState() => _TaskTimerScreenState();
}

class _TaskTimerScreenState extends State<TaskTimerScreen> {
  late TaskStepModel _step;
  late int _total;
  late int _secs;
  late int _totalSteps;
  bool _paused = false;
  bool _loaded = false;
  Timer? _ticker;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      final int stepNumber;
      final List<TaskStepModel> steps;

      if (args is Map<String, dynamic>) {
        stepNumber = (args['stepNumber'] as int?) ?? 1;
        steps =
            (args['steps'] as List<TaskStepModel>?) ??
            TaskStepModel.fallback('');
      } else {
        stepNumber = (args as int?) ?? 1;
        steps = TaskStepModel.fallback('');
      }

      _totalSteps = steps.length;
      _step = steps.firstWhere(
        (s) => s.n == stepNumber,
        orElse: () => steps.first,
      );
      _total = _step.mins * 60;
      _secs = _total;

      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || _paused) return;
        if (_secs <= 0) return;
        setState(() => _secs--);
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = (_total - _secs) / _total;
    final mm = (_secs ~/ 60).toString();
    final ss = (_secs % 60).toString().padLeft(2, '0');
    final totalMm = _step.mins.toString();

    return NFScreen(
      hideTabs: true,
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NFHeader(title: 'Task Coach', onBack: () => Navigator.pop(context)),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'STEP ${_step.n} / $_totalSteps',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: AppColors.tasksAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Text(
                      _step.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        height: 1.3,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CustomPaint(
                      painter: _TimerRingPainter(progress: pct),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$mm:$ss',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'of $totalMm:00',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Text(
                      _step.hint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Material(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      onTap: () => setState(() => _paused = !_paused),
                      borderRadius: BorderRadius.circular(999),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          _paused ? '▶  Resume' : '⏸  Pause',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.creamAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      NFButton(
                        label: 'Done, next!',
                        small: true,
                        onPressed: () => Navigator.pop(context),
                      ),
                      NFButton(
                        label: 'Skip',
                        small: true,
                        variant: NFButtonVariant.ghost,
                        onPressed: () => Navigator.pop(context),
                      ),
                      NFButton(
                        label: "I'm stuck",
                        small: true,
                        variant: NFButtonVariant.ghost,
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.listening,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  _TimerRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const r = 58.0;
    final center = Offset(size.width / 2, size.height / 2);
    final bg = Paint()
      ..color = AppColors.border
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, r, bg);

    final fg = Paint()
      ..color = AppColors.orange
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -pi / 2,
      2 * pi * progress,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter old) =>
      old.progress != progress;
}
