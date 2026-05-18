import 'package:connectivity_plus/connectivity_plus.dart';
import 'groq_service.dart';
import '../features/mic/intent_screen.dart';
import 'package:flutter/foundation.dart';

class GemmaService {
  final GroqService _groq = GroqService();

  static const String _brainDumpSystem = '''
You are Neuro Friend, an AI assistant for neurodivergent users.

The user just did a voice brain dump. Extract everything they said into structured categories.

Return ONLY valid JSON, no markdown, no explanation.

Format:
{
  "summary": "one short sentence summarising what was said",
  "tasks": ["string", ...],
  "ideas": ["string", ...],
  "events": ["string", ...],
  "worries": ["string", ...]
}

Rules:
- Tasks: actionable things they need to do
- Ideas: creative thoughts, plans, things they want to explore
- Events: scheduled things, meetings, appointments
- Worries: anxieties, concerns, fears
- Each item is a short clear sentence
- Arrays can be empty if nothing fits that category
- English only
''';

  static const String _emotionalCheckinSystem = '''
You are Neuro Friend, a warm AI companion for neurodivergent users.

Analyze the user's message and return ONLY valid JSON. No markdown. No explanations.

Format:
{
  "detected_emotion": "string (e.g. overwhelm, anxiety, sadness, frustration, burnout, confusion)",
  "emotion_label": "string (short human-readable label, e.g. 'Overwhelm + task paralysis')",
  "validation_message": "string (1-2 warm sentences validating the feeling, first person from Neuro Friend)",
  "coping_tips": [
    {
      "emoji": "string",
      "title": "string (short, max 4 words)",
      "body": "string (1-2 clear actionable sentences)"
    }
  ]
}

Rules:
- Return only JSON.
- No markdown. No backticks.
- coping_tips must have exactly 3-4 items tailored to the detected emotion.
- validation_message must feel warm and human, not clinical.
- Use English only.
''';

  static const String _taskCoachSystem = '''
You are Neuro Friend, an AI assistant for neurodivergent users (ADHD/autism).

The user named one big task. Break it into micro-steps small enough to start immediately.

Return ONLY valid JSON, no markdown, no explanation.

Format:
{
  "task_title": "cleaned up task name",
  "why_hard": "one sentence on why this feels hard (ADHD lens)",
  "steps": [
    {
      "title": "step title",
      "detail": "one sentence instruction",
      "minutes": 5
    }
  ],
  "first_move": "the single smallest thing they can do RIGHT NOW"
}

Rules:
- 5 to 7 steps
- Each step max 10 minutes
- first_move must be under 2 minutes and trivially easy
- English only
''';

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

  // ── Brain Dump ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> processBrainDump(String transcript) async {
    if (!await _isOnline) return _offlineBrainDump();
    return _groq.chatJson(
      systemPrompt: _brainDumpSystem,
      userMessage: transcript,
      maxTokens: 1024,
    );
  }

  Map<String, dynamic> _offlineBrainDump() => {
    'summary': 'You are offline. Here is what we captured.',
    'tasks': [],
    'ideas': [],
    'events': [],
    'worries': [],
    'error': 'offline',
  };

  // ── Emotional Check-in ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> processEmotionalCheckin(
    String transcript,
  ) async {
    if (!await _isOnline) return _offlineEmotionalResponse();
    return _groq.chatJson(
      systemPrompt: _emotionalCheckinSystem,
      userMessage: transcript,
      maxTokens: 600,
    );
  }

  Map<String, dynamic> _offlineEmotionalResponse() => {
    'detected_emotion': 'unknown',
    'emotion_label': 'Feeling something heavy',
    'validation_message':
        "You're offline right now, but your feelings are still valid. Take a breath — you've got this.",
    'coping_tips': [
      {
        'emoji': '🌬️',
        'title': '4-4-6 breathing',
        'body': 'Inhale 4s, hold 4s, exhale slowly 6s. Repeat 3–5 times.',
      },
      {
        'emoji': '💧',
        'title': '5-minute break',
        'body': 'Drink water, walk a bit, look out a window.',
      },
      {
        'emoji': '🐾',
        'title': 'Pick the smallest one',
        'body': 'Take the lightest task and work just 2 minutes on it.',
      },
    ],
  };

  // ── Task Coach ──────────────────────────────────────────────────────────────

  /// Used by ProcessingScreen for the task intent flow.
  Future<Map<String, dynamic>> breakdownTask(String transcript) async {
    if (!await _isOnline) return _offlineTaskResponse(transcript);
    return _groq.chatJson(
      systemPrompt: _taskCoachSystem,
      userMessage: transcript,
      maxTokens: 768,
    );
  }

  /// Alias kept for any legacy callers.
  Future<Map<String, dynamic>> processTaskCoach(String transcript) =>
      breakdownTask(transcript);

  Map<String, dynamic> _offlineTaskResponse(String transcript) => {
    'task_title': transcript,
    'why_hard': 'Hard to start when offline.',
    'steps': [],
    'first_move': 'Write down the first thing you need to do.',
    'error': 'offline',
  };

  // ── Focus / Social / Sensory (plain text responses) ────────────────────────

  Future<String> focusCheckin(String userInput) async {
    if (!await _isOnline) return _offlineResponse();
    return _groq.chat(
      systemPrompt: _focusCheckinSystem,
      userMessage: userInput,
      maxTokens: 180,
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

  static const String _intentSystem = '''
You are Neuro Friend intent classifier.

Classify the user's voice transcript into exactly one intent.

Return ONLY valid JSON, no markdown, no explanation.

Format:
{"intent": "brain" | "emotional" | "task"}

Rules:
- "emotional": user expresses feelings, stress, overwhelm, anxiety, frustration, sadness, burnout, loneliness, or asks for support/comfort
- "task": user mentions exactly one specific task or asks how to do one thing
- "brain": everything else — multiple things, mixed topics, planning, lists, random thoughts
- When in doubt, return "brain"
''';

  Future<IntentKind> detectIntent(String transcript) async {
    if (!await _isOnline) return IntentKind.brain;
    try {
      final result = await _groq.chatJson(
        systemPrompt: _intentSystem,
        userMessage: transcript,
        maxTokens: 32,
      );
      debugPrint('detectIntent raw result: $result'); // ← tambah ini
      return switch (result['intent'] as String?) {
        'emotional' => IntentKind.emotional,
        'task' => IntentKind.task,
        _ => IntentKind.brain,
      };
    } catch (e) {
      debugPrint('detectIntent error: $e'); // ← dan ini
      return IntentKind.brain;
    }
  }

  String _offlineResponse() =>
      'You are offline right now. Please try again later.';
}
