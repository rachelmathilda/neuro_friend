import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SttService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  Future<bool> init() async {
    _initialized = await _speech.initialize(
      onError: (error) => debugPrint('STT ERROR: $error'),
      onStatus: (status) => debugPrint('STT STATUS: $status'),
    );
    debugPrint('STT INITIALIZED: $_initialized');
    return _initialized;
  }

  bool get isListening => _speech.isListening;
  bool get isAvailable => _initialized;

  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    String localeId = 'id_ID',
  }) async {
    if (!_initialized) await init();
    debugPrint('STT START LISTENING, initialized: $_initialized');
    await _speech.listen(
      onResult: (result) {
        debugPrint(
          'STT RESULT: ${result.recognizedWords} final=${result.finalResult}',
        );
        onResult(result.recognizedWords, result.finalResult);
      },
      localeId: localeId,
      listenOptions: SpeechListenOptions(
        cancelOnError: false,
        partialResults: true,
        listenMode: ListenMode.confirmation,
      ),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }
}
