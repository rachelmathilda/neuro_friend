import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/task_step_model.dart';
import '../../core/widgets/nf_mascot.dart';
import '../../core/widgets/nf_screen.dart';
import '../../services/gemma_service.dart';

class ProcessingScreen extends StatefulWidget {
  final String nextRoute;
  final String transcript;
  final String intent;

  const ProcessingScreen({
    super.key,
    required this.nextRoute,
    required this.transcript,
    required this.intent,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _dots;
  final GemmaService _gemma = GemmaService();

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _dots = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) => _process());
  }

  Future<void> _process() async {
    debugPrint(
      'ProcessingScreen intent: ${widget.intent}, transcript: ${widget.transcript}',
    );
    try {
      switch (widget.intent) {
        case 'brain':
          await _processBrain(widget.transcript, widget.nextRoute);
        case 'emotional':
          await _processEmotional(widget.transcript, widget.nextRoute);
        case 'task':
          await _processTask(widget.transcript, widget.nextRoute);
        default:
          await _processBrain(widget.transcript, widget.nextRoute);
      }
    } catch (e) {
      debugPrint('ProcessingScreen error: $e');
      _navigateTo(widget.nextRoute, {'error': e.toString()});
    }
  }

  Future<void> _processBrain(String transcript, String nextRoute) async {
    final result = await _gemma.processBrainDump(transcript);
    _navigateTo(nextRoute, result);
  }

  Future<void> _processEmotional(String transcript, String nextRoute) async {
    final result = await _gemma.processEmotionalCheckin(transcript);
    _navigateTo(nextRoute, result);
  }

  Future<void> _processTask(String transcript, String nextRoute) async {
    final result = await _gemma.breakdownTask(transcript);
    final rawSteps = result['steps'] as List<dynamic>? ?? [];
    final steps = rawSteps.isEmpty
        ? TaskStepModel.fallback(transcript)
        : rawSteps
              .asMap()
              .entries
              .map(
                (e) => TaskStepModel.fromJson(
                  e.value as Map<String, dynamic>,
                  index: e.key,
                ),
              )
              .toList();
    _navigateTo(nextRoute, {
      'steps': steps,
      'taskTitle': (result['task_title'] as String?) ?? transcript,
      'totalMinutes': steps.fold<int>(0, (sum, s) => sum + s.mins),
      'whyHard': (result['why_hard'] as String?) ?? '',
      'firstMove': (result['first_move'] as String?) ?? '',
    });
  }

  void _navigateTo(String route, Object? arguments) {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route, arguments: arguments);
  }

  @override
  void dispose() {
    _spin.dispose();
    _dots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NFScreen(
      hideTabs: true,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Opacity(
              opacity: 0.9,
              child: NFMascot(size: 92, mood: MascotMood.calm),
            ),
            const SizedBox(height: 24),
            RotationTransition(
              turns: _spin,
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
              animation: _dots,
              builder: (_, __) {
                final n = ((_dots.value * 3).floor() % 3) + 1;
                return Text(
                  'Gemma 4 processing${'.' * n}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
          ],
        ),
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
      radius: (size.width / 2) - 1.75,
    );
    canvas.drawArc(rect, -1.57, 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
