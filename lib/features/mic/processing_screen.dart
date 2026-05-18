import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/nf_mascot.dart';
import '../../core/widgets/nf_screen.dart';
import '../../data/models/task_step_model.dart';
import '../../providers/brain_dump_provider.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  /// Either:
  ///  * `Map<String,dynamic>` with `transcript` + `route` (brain dump flow), or
  ///  * `String` route name (legacy intent flow — just navigates after delay).
  final Object? arguments;
  const ProcessingScreen({super.key, this.arguments});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _dots;
  Timer? _legacyTimer;
  Object? _error;
  String? _transcript;
  String? _intent;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
    _dots = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) => _kickoff());
  }

  void _kickoff() {
    final args = widget.arguments ?? ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      _transcript = args['transcript'] as String?;
      _intent = args['intent'] as String?;
      final intent = _intent;
      if (_transcript == null || _transcript!.isEmpty) {
        Navigator.pop(context);
        return;
      }
      if (intent == 'emotional') {
        _runEmotional(_transcript!);
      } else if (intent == 'task') {
        _runTaskCoach(_transcript!);
      } else {
        _runBrainDump(_transcript!);
      }
    } else {
      // Legacy: arg is a route string. Just navigate after delay.
      final route = (args as String?) ?? AppRoutes.brainResult;
      _legacyTimer = Timer(const Duration(milliseconds: 1900), () {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, route);
      });
    }
  }

  Future<void> _runBrainDump(String transcript) async {
    try {
      final entry =
          await ref.read(processBrainDumpProvider(transcript).future);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.brainResult,
        arguments: entry.id,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<void> _runTaskCoach(String transcript) async {
    try {
      final result =
          await ref.read(processTaskCoachProvider(transcript).future);
      if (!mounted) return;
      final rawSteps = (result['steps'] is List)
          ? (result['steps'] as List)
          : const [];
      final steps = <TaskStepModel>[];
      for (var i = 0; i < rawSteps.length; i++) {
        final s = rawSteps[i];
        if (s is Map) {
          steps.add(TaskStepModel.fromJson(
              Map<String, dynamic>.from(s),
              index: i));
        }
      }
      final total = (result['totalMinutes'] as num?)?.toInt() ??
          steps.fold<int>(0, (sum, s) => sum + s.mins);
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.taskSteps,
        arguments: {
          'steps': steps,
          'taskTitle': (result['taskTitle'] as String?) ?? transcript,
          'totalMinutes': total,
          'firstMove': (result['firstMove'] as String?) ?? '',
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<void> _runEmotional(String transcript) async {
    try {
      final result =
          await ref.read(processEmotionalProvider(transcript).future);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.emotional,
        arguments: result,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    _dots.dispose();
    _legacyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NFScreen(
      hideTabs: true,
      child: Center(
        child: _error != null ? _ErrorView(onRetry: _retry) : _LoadingView(spin: _spin, dots: _dots),
      ),
    );
  }

  void _retry() {
    setState(() => _error = null);
    if (_transcript == null) return;
    if (_intent == 'emotional') {
      _runEmotional(_transcript!);
    } else if (_intent == 'task') {
      _runTaskCoach(_transcript!);
    } else {
      _runBrainDump(_transcript!);
    }
  }
}

class _LoadingView extends StatelessWidget {
  final AnimationController spin;
  final AnimationController dots;
  const _LoadingView({required this.spin, required this.dots});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Opacity(opacity: 0.9, child: NFMascot(size: 92, mood: MascotMood.calm)),
        const SizedBox(height: 24),
        RotationTransition(
          turns: spin,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.blueSoft, width: 3.5),
            ),
            child: CustomPaint(painter: _ArcPainter()),
          ),
        ),
        const SizedBox(height: 18),
        AnimatedBuilder(
          animation: dots,
          builder: (_, __) {
            final n = ((dots.value * 3).floor() % 3) + 1;
            return Text(
              'Gemma 4 processing${'.' * n}',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary),
            );
          },
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const NFMascot(size: 80, mood: MascotMood.calm),
          const SizedBox(height: 16),
          const Text(
            'Hmm, otakku lagi lambat.\nCoba lagi ya.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Coba lagi'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            child: const Text('Balik'),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: (size.width / 2) - 1.75);
    canvas.drawArc(rect, -1.57, 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
