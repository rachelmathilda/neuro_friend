import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/nf_mascot.dart';
import '../../core/widgets/nf_mic_button.dart';
import '../../core/widgets/nf_screen.dart';
import '../../services/stt_service.dart';

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  final SttService _stt = SttService();

  int _secs = 0;
  Timer? _ticker;
  Timer? _silenceTimer;

  String _transcript = '';
  String _latestTranscript = '';
  bool _listening = false;
  bool _finishing = false;
  String _statusMsg = 'Initialising…';

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _secs++);
    });
    _initAndStart();
  }

  Future<void> _initAndStart() async {
    final ok = await _stt.init();
    if (!mounted) return;
    if (ok) {
      setState(() => _statusMsg = 'Listening…');
      _startListening();
    } else {
      setState(() => _statusMsg = 'Mic unavailable — tap to retry');
    }
  }

  void _startListening() {
    if (_stt.isListening) return;
    _stt.startListening(
      localeId: 'en_US',
      onResult: (text, isFinal) {
        _latestTranscript = text;
        if (!mounted) return;
        setState(() => _transcript = text);
        if (isFinal && text.trim().isNotEmpty) {
          _doFinish();
        }
      },
    );
    if (mounted) setState(() => _listening = true);
  }

  void _finish() {
    _silenceTimer?.cancel();
    _stt.stopListening();
    Timer(const Duration(milliseconds: 300), _doFinish);
  }

  void _doFinish() {
    if (_finishing) return;
    _finishing = true;
    _ticker?.cancel();
    _silenceTimer?.cancel();
    if (!mounted) return;
    final transcript = _latestTranscript.trim().isEmpty
        ? 'No speech captured.'
        : _latestTranscript.trim();
    debugPrint('ListeningScreen navigating with: $transcript');
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.intent,
      arguments: transcript, // ← String langsung
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _silenceTimer?.cancel();
    _stt.stopListening();
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
            Text(
              _statusMsg,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
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
              child: _transcript.isEmpty
                  ? const _Waveform()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        _transcript,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              '$mm:$ss',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 22),
            NFMicButton(recording: _listening, onTap: _finish),
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Tap to finish',
                style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
              ),
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
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
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
        color: AppColors.blue.withValues(alpha: opacity.clamp(0, 1)),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
