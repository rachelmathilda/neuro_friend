import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SttService {
  final SpeechToText _speech = SpeechToText();

  bool _initialized = false;

  Future<bool> init() async {
    _initialized = await _speech.initialize(
      onError: (error) {
        debugPrint('STT ERROR: $error');
      },

      onStatus: (status) {
        debugPrint('STT STATUS: $status');
      },
    );

    debugPrint('STT INITIALIZED: $_initialized');

    return _initialized;
  }

  bool get isListening => _speech.isListening;

  bool get isAvailable => _initialized;

  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    void Function(String status)? onStatus,
    String localeId = 'en_US',
  }) async {
    if (!_initialized) {
      await init();
    }

    if (_speech.isListening) return;

    debugPrint('STT START LISTENING, initialized: $_initialized');

    await _speech.listen(
      onResult: (result) {
        final text = result.recognizedWords;

        debugPrint('STT RESULT: $text final=${result.finalResult}');

        onResult(text, result.finalResult);
      },

      onSoundLevelChange: (level) {
        debugPrint('STT SOUND LEVEL: $level');
      },

      localeId: localeId,

      // lebih lama
      listenFor: const Duration(minutes: 10),

      // jangan cepat berhenti pas user diem bentar
      pauseFor: const Duration(seconds: 45),

      listenOptions: SpeechListenOptions(
        cancelOnError: false,

        // penting buat live transcript
        partialResults: true,

        // biar natural
        autoPunctuation: true,

        // lebih cocok buat ngomong panjang
        listenMode: ListenMode.dictation,
      ),
    );

    // forward status manually
    _speech.statusListener = (status) {
      debugPrint('STT STATUS: $status');
      onStatus?.call(status);
    };
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
  }
}
