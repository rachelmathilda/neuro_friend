import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/nf_mascot.dart';
import '../../core/widgets/nf_mic_button.dart';
import '../../core/widgets/nf_screen.dart';

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  int _secs = 0;
  Timer? _ticker;
  Timer? _auto;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _secs++);
    });
    _auto = Timer(const Duration(milliseconds: 4200), _next);
  }

  void _next() {
    _ticker?.cancel();
    _auto?.cancel();
    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.intent);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _auto?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mm = (_secs ~/ 60).toString();
    final ss = (_secs % 60).toString().padLeft(2, '0');

    return NFScreen(
      hideTabs: true,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Listening…',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            const NFMascot(size: 90, mood: MascotMood.listening),
            const SizedBox(height: 8),
            Container(
              width: 240,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.blueSoft,
                borderRadius: BorderRadius.circular(28),
              ),
              alignment: Alignment.center,
              child: const _Waveform(),
            ),
            const SizedBox(height: 12),
            Text('$mm:$ss',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 22),
            NFMicButton(recording: true, onTap: _next),
            const Padding(
              padding: EdgeInsets.only(top: 0),
              child: Text('Tap to finish',
                  style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Waveform extends StatefulWidget {
  const _Waveform();

  @override
  State<_Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<_Waveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const count = 26;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < count; i++) ...[
                _bar(i),
                if (i < count - 1) const SizedBox(width: 3),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _bar(int i) {
    final baseHeight = 8 + (i * 7) % 32;
    final phase = ((_c.value + (i % 8) * 0.09) % 1.0);
    final scaleY = 0.4 + 1.2 * (0.5 + 0.5 * sin(phase * 2 * pi));
    final opacity = 0.45 + ((i * 13) % 6) / 10;
    return Container(
      width: 3,
      height: baseHeight * scaleY,
      decoration: BoxDecoration(
        color: AppColors.blue.withOpacity(opacity.clamp(0, 1)),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
