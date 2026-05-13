import 'package:connectivity_plus/connectivity_plus.dart';
import 'groq_service.dart';

class GemmaService {
  final GroqService _groq = GroqService();

  static const String _focusCheckinSystem = '''
Kamu adalah Neuro Friend, asisten untuk pengguna neurodivergent (ADHD/autisme).
Balas dalam Bahasa Indonesia, informal, hangat, dan singkat (1-3 kalimat).
Jangan menghakimi. Selalu validasi perasaan user dulu sebelum memberi saran.
''';

  static const String _brainDumpSystem = '''
Kamu adalah Neuro Friend. User memberikan brain dump (curahan pikiran acak).
Ekstrak tugas-tugas yang disebutkan dan return sebagai JSON array.
Format: {"tasks": [{"title": str, "category": str, "priority": "high"|"medium"|"low", "estimated_minutes": int}]}
Return HANYA JSON, tanpa penjelasan apapun.
''';

  static const String _socialScriptSystem = '''
Kamu adalah Neuro Friend. Buatkan skrip pesan siap pakai untuk situasi sosial yang dideskripsikan user.
Bahasa Indonesia, informal tapi sopan. Maksimal 2-3 kalimat. Langsung isi skripnya saja tanpa intro.
''';

  static const String _sensorySystem = '''
Kamu adalah Neuro Friend. User sedang mengalami sensory overwhelm.
Berikan teknik grounding yang bisa dilakukan sekarang juga. 1-2 kalimat, tenang, tidak panik.
''';

  Future<bool> get _isOnline async {
    final result = await Connectivity().checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  Future<String> focusCheckin(String userInput) async {
    if (!await _isOnline) return _offlineResponse();
    return _groq.chat(
      systemPrompt: _focusCheckinSystem,
      userMessage: userInput,
    );
  }

  Future<Map<String, dynamic>> processBrainDump(String brainDump) async {
    if (!await _isOnline) return {'tasks': []};
    return _groq.chatJson(
      systemPrompt: _brainDumpSystem,
      userMessage: brainDump,
      maxTokens: 1024,
    );
  }

  Future<String> generateSocialScript(String situation) async {
    if (!await _isOnline) return _offlineResponse();
    return _groq.chat(
      systemPrompt: _socialScriptSystem,
      userMessage: situation,
    );
  }

  Future<String> sensorySupport(String situation) async {
    if (!await _isOnline) return _offlineResponse();
    return _groq.chat(
      systemPrompt: _sensorySystem,
      userMessage: situation,
      maxTokens: 128,
    );
  }

  String _offlineResponse() {
    return 'Kamu tidak terhubung ke internet sekarang. Coba lagi nanti ya.';
  }
}
