import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../providers/focus_provider.dart';
import '../../services/gemma_service.dart';
import '../../services/stt_service.dart';
import '../../services/tts_service.dart';
import '../../providers/task_provider.dart';
import '../../data/models/task_model.dart';

class AiVoiceScreen extends ConsumerStatefulWidget {
  const AiVoiceScreen({super.key});

  @override
  ConsumerState<AiVoiceScreen> createState() => _AiVoiceScreenState();
}

class _AiVoiceScreenState extends ConsumerState<AiVoiceScreen> {
  final _stt = SttService();
  final _tts = TtsService();
  final _gemma = GemmaService();

  String _transcript = '';
  String _response = '';

  bool _isListening = false;
  bool _isThinking = false;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _tts.init();
    _stt.init();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stt.stopListening();

      if (!mounted) return;

      setState(() {
        _isListening = false;
      });

      if (_transcript.trim().isNotEmpty) {
        await _process();
      }
    } else {
      setState(() {
        _isListening = true;
        _transcript = '';
      });

      await _stt.startListening(
        onResult: (text) {
          if (!mounted) return;

          setState(() {
            _transcript = text;
          });
        },
      );
    }
  }

  Future<void> _process() async {
    if (_transcript.trim().isEmpty) return;

    setState(() {
      _isThinking = true;
    });

    try {
      final brainDump = await _gemma.processBrainDump(_transcript);

      final tasks = List<Map<String, dynamic>>.from(brainDump['tasks'] ?? []);

      if (tasks.isNotEmpty) {
        final notifier = ref.read(taskProvider.notifier);

        for (final task in tasks) {
          final now = DateTime.now();

          final suggestedHour = _suggestedHour(task['suggested_time']);

          DateTime startTime = DateTime(
            now.year,
            now.month,
            now.day,
            suggestedHour,
          );

          if (startTime.isBefore(now)) {
            startTime = startTime.add(const Duration(days: 1));
          }

          final endTime = startTime.add(
            Duration(minutes: (task['estimated_minutes'] ?? 30) as int),
          );

          final taskModel = TaskModel(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: task['title'] ?? 'Untitled Task',

            category: TaskCategory.values.firstWhere(
              (e) => e.name == (task['category'] ?? 'other'),
              orElse: () => TaskCategory.other,
            ),

            date: startTime,

            startTime: startTime,
            endTime: endTime,

            status: TaskStatus.notYet,
          );

          await notifier.addTask(taskModel);
        }

        final titles = tasks.map((e) => e['title']).join(', ');

        final reply =
            'I added ${tasks.length} task${tasks.length > 1 ? 's' : ''}: $titles';

        if (!mounted) return;

        setState(() {
          _response = reply;
          _isThinking = false;
          _isSpeaking = true;
        });

        await _tts.speak(reply);
      } else {
        final reply = await _gemma.focusCheckin(_transcript);

        if (!mounted) return;

        setState(() {
          _response = reply;
          _isThinking = false;
          _isSpeaking = true;
        });

        await _tts.speak(reply);
      }

      if (!mounted) return;

      setState(() {
        _isSpeaking = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        _response = 'Something went wrong.';
        _isThinking = false;
        _isSpeaking = false;
      });
    }
  }

  int _suggestedHour(String? value) {
    switch (value) {
      case 'morning':
        return 9;
      case 'afternoon':
        return 14;
      case 'evening':
        return 19;
      default:
        return 10;
    }
  }

  @override
  Widget build(BuildContext context) {
    final focusSession = ref.watch(focusProvider);

    final hasContent =
        _transcript.trim().isNotEmpty ||
        _response.trim().isNotEmpty ||
        _isThinking;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F3),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),

            Text(
              'Neuro Friend Assistant',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w100,
                color: Colors.black87,
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 24),

            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.deepFocus);
              },
              child: Container(
                height: 54,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.butter,
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: Text(
                  focusSession != null
                      ? 'Deep Focus Mode'
                      : 'Start Deep Focus Mode',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 34),

            GestureDetector(
              onTap: _toggleListening,
              child: _CurlyOrb(
                isListening: _isListening,
                isThinking: _isThinking,
                isSpeaking: _isSpeaking,
              ),
            ),

            const Spacer(),

            if (hasContent)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: _isThinking
                    ? Row(
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Thinking...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        _response.isNotEmpty ? _response : _transcript,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 16,
                          height: 1.45,
                          color: Colors.black87,
                        ),
                      ),
              ),

            SizedBox(height: hasContent ? 32 : 0),

            BottomNav(currentIndex: 2),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _CurlyOrb extends StatefulWidget {
  final bool isListening;
  final bool isThinking;
  final bool isSpeaking;

  const _CurlyOrb({
    required this.isListening,
    required this.isThinking,
    required this.isSpeaking,
  });

  @override
  State<_CurlyOrb> createState() => _CurlyOrbState();
}

class _CurlyOrbState extends State<_CurlyOrb> with TickerProviderStateMixin {
  late final AnimationController _rotation;
  late final AnimationController _wave;

  @override
  void initState() {
    super.initState();

    _rotation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _wave = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _rotation.dispose();
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 310,
      height: 310,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotation, _wave]),
        builder: (_, __) {
          return CustomPaint(
            painter: _CurlyOrbPainter(
              rotation: _rotation.value,
              wave: _wave.value,
              isListening: widget.isListening,
              isThinking: widget.isThinking,
              isSpeaking: widget.isSpeaking,
            ),
          );
        },
      ),
    );
  }
}

class _CurlyOrbPainter extends CustomPainter {
  final double rotation;
  final double wave;

  final bool isListening;
  final bool isThinking;
  final bool isSpeaking;

  _CurlyOrbPainter({
    required this.rotation,
    required this.wave,
    required this.isListening,
    required this.isThinking,
    required this.isSpeaking,
  });

  double get _waveStrength {
    if (isSpeaking) return 18;
    if (isListening) return 14;
    if (isThinking) return 8;
    return 10;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final rect = Rect.fromCenter(center: center, width: 250, height: 250);

    final paints = [
      Paint()
        ..shader = SweepGradient(
          colors: [
            const Color(0xFF17388E).withValues(alpha: 0.95),
            const Color(0xFF3D6FE8).withValues(alpha: 0.55),
            const Color(0xFF9CC1FF).withValues(alpha: 0.22),
            const Color(0xFF3D6FE8).withValues(alpha: 0.55),
            const Color(0xFF17388E).withValues(alpha: 0.95),
          ],
          stops: const [0.0, 0.28, 0.5, 0.72, 1.0],
          transform: GradientRotation(rotation * math.pi * 2),
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..blendMode = BlendMode.srcOver,

      Paint()
        ..shader = SweepGradient(
          colors: [
            const Color(0xFFBFD4FF).withValues(alpha: 0.08),
            const Color(0xFF7EA8FF).withValues(alpha: 0.4),
            Colors.white.withValues(alpha: 0.9),
            const Color(0xFF7EA8FF).withValues(alpha: 0.4),
            const Color(0xFFBFD4FF).withValues(alpha: 0.08),
          ],
          stops: const [0.0, 0.32, 0.5, 0.68, 1.0],
          transform: GradientRotation(-rotation * math.pi * 2),
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..blendMode = BlendMode.plus,
    ];

    for (int i = 0; i < paints.length; i++) {
      final path = _buildRingPath(center, 92 + (i * 2), 0.4 + (i * 0.7));

      canvas.drawPath(path, paints[i]);
    }

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.55),
          const Color(0xFF7EA8FF).withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 120));

    canvas.drawCircle(center, 110, glow);
  }

  Path _buildRingPath(Offset center, double radius, double phase) {
    final path = Path();

    const total = 420;

    for (int i = 0; i <= total; i++) {
      final t = (i / total) * math.pi * 2;

      final distortion =
          math.sin((t * 8) + (wave * math.pi * 2) + phase) * _waveStrength +
          math.cos((t * 5) - (wave * math.pi) + phase) * 7;

      final r = radius + distortion;

      final x = center.dx + r * math.cos(t);
      final y = center.dy + r * math.sin(t);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant _CurlyOrbPainter oldDelegate) {
    return true;
  }
}
