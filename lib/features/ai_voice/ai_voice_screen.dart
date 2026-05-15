import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/focus_provider.dart';
import '../../services/gemma_service.dart';
import '../../services/stt_service.dart';
import '../../services/tts_service.dart';
import 'dart:math' as math;

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

  @override
  void initState() {
    super.initState();
    _tts.init();
    _stt.init();
  }

  Future<void> toggleListening() async {
    if (_isListening) {
      await _stt.stopListening();
      setState(() => _isListening = false);
      if (_transcript.isNotEmpty) await _process();
    } else {
      setState(() {
        _isListening = true;
        _transcript = '';
        _response = '';
      });
      await _stt.startListening(
        onResult: (text) => setState(() => _transcript = text),
      );
    }
  }

  Future<void> _process() async {
    setState(() => _isThinking = true);
    try {
      final reply = await _gemma.focusCheckin(_transcript);
      setState(() => _response = reply);
      await _tts.speak(reply);
    } finally {
      setState(() => _isThinking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final focusSession = ref.watch(focusProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Center(
                child: Text(
                  'Neuro Friend Assistant',
                  style: AppTextStyles.titleLarge,
                ),
              ),
            ),
            if (focusSession != null)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.butter,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Deep Focus Mode',
                  style: AppTextStyles.titleMedium,
                ),
              ),
            const SizedBox(height: 24),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: toggleListening,
                    child: _AnimatedOrb(
                      isListening: _isListening,
                      isThinking: _isThinking,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_transcript.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(_transcript, style: AppTextStyles.bodyMedium),
                    ),
                  if (_response.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.butter,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(_response, style: AppTextStyles.bodyMedium),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedOrb extends StatefulWidget {
  final bool isListening;
  final bool isThinking;

  const _AnimatedOrb({required this.isListening, required this.isThinking});

  @override
  State<_AnimatedOrb> createState() => _AnimatedOrbState();
}

class _AnimatedOrbState extends State<_AnimatedOrb>
    with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotateController, _pulseController]),
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isListening ? _pulseAnimation.value : 1.0,
            child: CustomPaint(
              painter: _OrbPainter(
                rotation: _rotateController.value,
                isListening: widget.isListening,
                isThinking: widget.isThinking,
              ),
              child: Center(
                child: widget.isThinking
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Icon(
                        widget.isListening ? Icons.mic : Icons.mic_none,
                        size: 48,
                        color: Colors.white,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double rotation;
  final bool isListening;
  final bool isThinking;

  _OrbPainter({
    required this.rotation,
    required this.isListening,
    required this.isThinking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.9),
          AppColors.primaryDark.withValues(alpha: 0.7),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, bgPaint);

    final blobPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = Colors.white.withValues(alpha: 0.25);

    for (int i = 0; i < 5; i++) {
      final angle = rotation * 2 * math.pi + (i * math.pi * 2 / 5);
      final path = Path();
      final blobRadius = radius * (0.55 + i * 0.07);
      final points = 8;

      for (int j = 0; j <= points; j++) {
        final t = j / points;
        final a = angle + t * 2 * math.pi;
        final r =
            blobRadius +
            math.sin(a * 3 + rotation * 2 * math.pi) * radius * 0.08;
        final x = center.dx + r * math.cos(a);
        final y = center.dy + r * math.sin(a);
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, blobPaint);
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) => true;
}
