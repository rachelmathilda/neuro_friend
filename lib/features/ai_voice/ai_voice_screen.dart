import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
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

class _AnimatedOrb extends StatelessWidget {
  final bool isListening;
  final bool isThinking;

  const _AnimatedOrb({required this.isListening, required this.isThinking});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: isThinking
            ? const CircularProgressIndicator()
            : Icon(
                isListening ? Icons.mic : Icons.mic_none,
                size: 64,
                color: AppColors.primary,
              ),
      ),
    );
  }
}
