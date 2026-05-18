import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'groq_service.dart';

class GemmaService {
  final GroqService _groq = GroqService();

  // ────────────────────────────────────────────────────────────────────────────
  // SYSTEM PROMPTS
  // ────────────────────────────────────────────────────────────────────────────

  static const String _brainDumpSystem = '''
You are Neuro Friend, an AI assistant for neurodivergent users.

The user just did a voice brain dump. Extract everything they said into structured categories.

Return ONLY valid JSON.
No markdown.
No explanation.
No reasoning.
No bullet points outside JSON.

Format:
{
  "summary": "one short sentence summarising what was said",
  "tasks": ["string"],
  "ideas": ["string"],
  "events": ["string"],
  "worries": ["string"]
}

Rules:
- Tasks: actionable things they need to do
- Ideas: creative thoughts, plans, things they want to explore
- Events: scheduled things, meetings, appointments
- Worries: anxieties, concerns, fears
- Each item is short and clear
- Arrays can be empty
- English only
''';

  static const String _emotionalCheckinSystem = '''
You are Neuro Friend, a warm AI companion for neurodivergent users.

Return ONLY valid JSON.
No markdown.
No explanations.
No reasoning.

Format:
{
  "detected_emotion": "string",
  "emotion_label": "string",
  "validation_message": "string",
  "coping_tips": [
    {
      "emoji": "string",
      "title": "string",
      "body": "string"
    }
  ]
}

Rules:
- coping_tips must contain exactly 3 or 4 items
- warm and supportive tone
- concise
- English only
''';

  static const String _taskCoachSystem = '''
You are Neuro Friend, an AI assistant for neurodivergent users (ADHD/autism).

The user describes ONE focused goal.
That goal may contain multiple sequential actions or schedule-related steps.

Break the goal into tiny actionable steps.

Return ONLY valid JSON.
No markdown.
No explanations.
No reasoning.

Format:
{
  "task_title": "cleaned up task name",
  "why_hard": "one sentence",
  "steps": [
    {
      "title": "step title",
      "detail": "one sentence instruction",
      "minutes": 5
    }
  ],
  "first_move": "smallest possible action"
}

Rules:
- 5 to 7 steps
- each step under 10 minutes
- first_move under 2 minutes
- supportive ADHD-friendly tone
- English only
''';

  static const String _focusCheckinSystem = '''
You are Neuro Friend.

Rules:
- English only
- warm supportive tone
- concise
- max 2 short sentences
- natural conversational style
''';

  static const String _socialScriptSystem = '''
You are Neuro Friend.

Create a ready-to-send social message.

Rules:
- English only
- casual but polite
- max 2 short sentences
- return ONLY the message
''';

  static const String _sensorySystem = '''
You are Neuro Friend.

The user is experiencing sensory overwhelm.

Rules:
- English only
- calm grounding tone
- short response
- one immediate actionable grounding technique
''';

  static const String _intentSystem = '''
You are an intent classifier.

Return ONLY one word:
emotional
task
brain

Definitions:

emotional:
The user mainly talks about feelings or emotional distress.

task:
The user mainly talks about ONE specific goal/project.
Even if it has multiple steps, all steps belong to the SAME outcome.

brain:
The user jumps between MULTIPLE unrelated tasks, thoughts, reminders, chores, or ideas.

VERY IMPORTANT:

If the message contains MANY unrelated activities,
ALWAYS choose brain.

Examples:

"finish my math assignment and submit it"
task

"clean the kitchen then wash dishes then mop the floor"
task

"buy groceries text mom make music do homework take a bath"
brain

"I feel overwhelmed and exhausted"
emotional

Reply with ONLY one word.
No explanations.
''';

  // ────────────────────────────────────────────────────────────────────────────
  // CONNECTIVITY
  // ────────────────────────────────────────────────────────────────────────────

  Future<bool> get _isOnline async {
    final result = await Connectivity().checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // BRAIN DUMP
  // ────────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> processBrainDump(String transcript) async {
    if (!await _isOnline) {
      return _offlineBrainDump();
    }

    try {
      return await _groq.chatJson(
        systemPrompt: _brainDumpSystem,
        userMessage: transcript,
        maxTokens: 1024,
      );
    } catch (e) {
      debugPrint('processBrainDump error: $e');
      return _offlineBrainDump();
    }
  }

  Map<String, dynamic> _offlineBrainDump() => {
    'summary': 'Offline mode active.',
    'tasks': [],
    'ideas': [],
    'events': [],
    'worries': [],
    'error': 'offline',
  };

  // ────────────────────────────────────────────────────────────────────────────
  // EMOTIONAL CHECK-IN
  // ────────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> processEmotionalCheckin(
    String transcript,
  ) async {
    if (!await _isOnline) {
      return _offlineEmotionalResponse();
    }

    try {
      return await _groq.chatJson(
        systemPrompt: _emotionalCheckinSystem,
        userMessage: transcript,
        maxTokens: 700,
      );
    } catch (e) {
      debugPrint('processEmotionalCheckin error: $e');
      return _offlineEmotionalResponse();
    }
  }

  Map<String, dynamic> _offlineEmotionalResponse() => {
    'detected_emotion': 'unknown',
    'emotion_label': 'Heavy feelings',
    'validation_message':
        "You're offline right now, but your feelings still matter.",
    'coping_tips': [
      {
        'emoji': '🌬️',
        'title': 'Slow breathing',
        'body': 'Take 3 slow breaths and unclench your shoulders.',
      },
      {
        'emoji': '💧',
        'title': 'Hydrate',
        'body': 'Drink some water and step away for 2 minutes.',
      },
      {
        'emoji': '🪶',
        'title': 'Tiny step',
        'body': 'Pick the easiest possible thing and do only that.',
      },
    ],
    'error': 'offline',
  };

  // ────────────────────────────────────────────────────────────────────────────
  // TASK COACH
  // ────────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> breakdownTask(String transcript) async {
    if (!await _isOnline) {
      return _offlineTaskResponse(transcript);
    }

    try {
      return await _groq.chatJson(
        systemPrompt: _taskCoachSystem,
        userMessage: transcript,
        maxTokens: 768,
      );
    } catch (e) {
      debugPrint('breakdownTask error: $e');
      return _offlineTaskResponse(transcript);
    }
  }

  Future<Map<String, dynamic>> processTaskCoach(String transcript) =>
      breakdownTask(transcript);

  Map<String, dynamic> _offlineTaskResponse(String transcript) => {
    'task_title': transcript,
    'why_hard': 'Starting can feel overwhelming when offline.',
    'steps': [],
    'first_move': 'Write the task on paper.',
    'error': 'offline',
  };

  // ────────────────────────────────────────────────────────────────────────────
  // FOCUS / SOCIAL / SENSORY
  // ────────────────────────────────────────────────────────────────────────────

  Future<String> focusCheckin(String userInput) async {
    if (!await _isOnline) {
      return _offlineResponse();
    }

    try {
      return await _groq.chat(
        systemPrompt: _focusCheckinSystem,
        userMessage: userInput,
        maxTokens: 180,
      );
    } catch (e) {
      debugPrint('focusCheckin error: $e');
      return _offlineResponse();
    }
  }

  Future<String> generateSocialScript(String situation) async {
    if (!await _isOnline) {
      return _offlineResponse();
    }

    try {
      return await _groq.chat(
        systemPrompt: _socialScriptSystem,
        userMessage: situation,
        maxTokens: 120,
      );
    } catch (e) {
      debugPrint('generateSocialScript error: $e');
      return _offlineResponse();
    }
  }

  Future<String> sensorySupport(String situation) async {
    if (!await _isOnline) {
      return _offlineResponse();
    }

    try {
      return await _groq.chat(
        systemPrompt: _sensorySystem,
        userMessage: situation,
        maxTokens: 120,
      );
    } catch (e) {
      debugPrint('sensorySupport error: $e');
      return _offlineResponse();
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // INTENT DETECTION
  // ────────────────────────────────────────────────────────────────────────────

  Future<String> detectIntent(String transcript) async {
    try {
      final response = await _groq.chat(
        systemPrompt: _intentSystem,
        userMessage: transcript,
        maxTokens: 10,
      );

      final text = response.toLowerCase().trim();

      debugPrint('detectIntent raw text: $text');

      final lines = text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      for (final line in lines.reversed) {
        if (line == 'brain') return 'brain';
        if (line == 'task') return 'task';
        if (line == 'emotional') return 'emotional';

        if (line.contains('brain')) return 'brain';
        if (line.contains('task')) return 'task';
        if (line.contains('emotional')) return 'emotional';
      }

      return _fallbackIntentString(transcript);
    } catch (e) {
      debugPrint('detectIntent error: $e');

      return _fallbackIntentString(transcript);
    }
  }

  String _fallbackIntentString(String text) {
    final lower = text.toLowerCase();

    const emotionalWords = [
      'sad',
      'stress',
      'stressed',
      'overwhelmed',
      'anxious',
      'anxiety',
      'burnout',
      'lonely',
      'angry',
      'upset',
      'cry',
      'tired',
      'depressed',
    ];

    for (final word in emotionalWords) {
      if (lower.contains(word)) {
        return 'emotional';
      }
    }

    final separators =
        ','.allMatches(lower).length + ' and '.allMatches(lower).length;

    if (separators >= 2) {
      return 'brain';
    }

    return 'task';
  }

  // ────────────────────────────────────────────────────────────────────────────

  String _offlineResponse() {
    return 'You are offline right now. Please try again later.';
  }
}
