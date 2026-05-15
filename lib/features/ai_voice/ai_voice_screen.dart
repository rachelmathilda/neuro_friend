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

  @override
  void initState() {
    super.initState();
    _tts.init();
    _stt.init();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stt.stopListening();

      setState(() {
        _isListening = false;
      });

      if (_transcript.isNotEmpty) {
        await _process();
      }
    } else {
      setState(() {
        _isListening = true;
        _transcript = '';
        _response = '';
      });

      await _stt.startListening(
        onResult: (text) {
          setState(() {
            _transcript = text;
          });
        },
      );
    }
  }

  Future<void> _process() async {
    try {
      final reply = await _gemma.focusCheckin(_transcript);

      setState(() => _response = reply);

      await _tts.speak(reply);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final focusSession = ref.watch(focusProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
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
              ),
            ),

            const SizedBox(height: 24),

            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.deepFocus);
              },
              child: Container(
                width: double.infinity,
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
                  ),
                ),
              ),
            ),

            const SizedBox(height: 38),

            GestureDetector(onTap: _toggleListening, child: const _SiriOrb()),

            const Spacer(),

            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Text(
                _transcript.isNotEmpty
                    ? _transcript
                    : _response.isNotEmpty
                    ? _response
                    : 'Hey.. can you help me to\narrange my schedule?',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 16,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 38),

            BottomNav(currentIndex: 2),
          ],
        ),
      ),
    );
  }
}

class _SiriOrb extends StatefulWidget {
  const _SiriOrb();

  @override
  State<_SiriOrb> createState() => _SiriOrbState();
}

class _SiriOrbState extends State<_SiriOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      height: 340,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return CustomPaint(painter: _SiriPainter(controller.value));
        },
      ),
    );
  }
}

class _SiriPainter extends CustomPainter {
  final double t;

  _SiriPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final rect = Rect.fromCenter(center: center, width: 240, height: 240);

    final layers = [
      (const Color(0xFF1F4FB8).withValues(alpha: 0.55), 0.0, 1.0),
      (const Color(0xFF5B8DEF).withValues(alpha: 0.45), 1.5, 0.92),
      (const Color(0xFF87B4FF).withValues(alpha: 0.40), 3.0, 0.84),
      (const Color(0xFFC3DAFF).withValues(alpha: 0.35), 4.5, 0.76),
    ];

    for (final layer in layers) {
      final color = layer.$1;
      final phase = layer.$2;
      final scale = layer.$3;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

      final path = Path();

      for (double a = 0; a <= math.pi * 2 + 0.1; a += 0.02) {
        final wave =
            math.sin(a * 5 + (t * math.pi * 2) + phase) * 16 +
            math.cos(a * 3 - (t * math.pi * 2) - phase) * 10;

        final radius = (88 * scale) + wave;

        final x = center.dx + radius * math.cos(a);
        final y = center.dy + radius * math.sin(a);

        if (a == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      path.close();

      canvas.drawPath(path, paint);
    }

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.9),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(rect);

    canvas.drawCircle(center, 62, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _SiriPainter oldDelegate) {
    return true;
  }
}
