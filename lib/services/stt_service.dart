import 'package:speech_to_text/speech_to_text.dart';

class SttService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  Future<bool> init() async {
    _initialized = await _speech.initialize(
      onError: (error) {},
      onStatus: (status) {},
    );
    return _initialized;
  }

  bool get isListening => _speech.isListening;
  bool get isAvailable => _initialized;

  Future<void> startListening({
    required void Function(String text) onResult,
    String localeId = 'id_ID',
  }) async {
    if (!_initialized) await init();
    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      localeId: localeId,
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }
}
