import 'package:connectivity_plus/connectivity_plus.dart';
import 'groq_service.dart';

class GemmaService {
  final GroqService _groq = GroqService();

  static const String _focusCheckinSystem = '''
You are Neuro Friend, an AI assistant for neurodivergent users (ADHD/autism).

Rules:
- Always reply in English.
- Keep responses warm, calming, supportive, and concise.
- Maximum 2 short sentences.
- Sound natural and conversational.
- Never sound robotic or overly formal.
- If the user sounds overwhelmed, validate feelings first before giving suggestions.
- If the user mentions planning, scheduling, deadlines, meetings, studying, or tasks, help organize them clearly.
''';

  static const String _brainDumpSystem = '''
You are Neuro Friend.

The user is doing a brain dump.

Extract ALL actionable tasks from the message and convert them into structured JSON.

Return ONLY valid JSON.

Format:
{
  "tasks": [
    {
      "title": "string",
      "category": "study|work|personal|health|meeting|other",
      "priority": "high|medium|low",
      "estimated_minutes": 30,
      "suggested_time": "morning|afternoon|evening"
    }
  ]
}

Rules:
- Return only JSON.
- No markdown.
- No explanations.
- Infer priority intelligently.
- Break large tasks into smaller actionable tasks when possible.
- Use English only.
''';

  static const String _socialScriptSystem = '''
You are Neuro Friend.

Create a ready-to-send social message.

Rules:
- English only.
- Casual but polite.
- Maximum 2 short sentences.
- Return only the message itself.
''';

  static const String _sensorySystem = '''
You are Neuro Friend.

The user is experiencing sensory overwhelm.

Rules:
- English only.
- Calm and grounding tone.
- Short response.
- Give one immediate actionable grounding technique.
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
      maxTokens: 180,
    );
  }

  Future<Map<String, dynamic>> processBrainDump(String brainDump) async {
    if (!await _isOnline) {
      return {'tasks': []};
    }

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
      maxTokens: 120,
    );
  }

  Future<String> sensorySupport(String situation) async {
    if (!await _isOnline) return _offlineResponse();

    return _groq.chat(
      systemPrompt: _sensorySystem,
      userMessage: situation,
      maxTokens: 120,
    );
  }

  String _offlineResponse() {
    return 'You are offline right now. Please try again later.';
  }
}
