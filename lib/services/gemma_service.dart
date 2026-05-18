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
You are organizing a brain dump from someone with ADHD.
Take their raw speech and categorize EVERY item into exactly one of 3 categories.
Respond ONLY in JSON format, no markdown, no preamble.

Categories:
- tasks: actionable things they need to do
- ideas: creative thoughts, project ideas, things they want to explore
- events: scheduled things with a time/date

JSON format:
{
  "tasks": ["item 1", "item 2"],
  "ideas": ["item 1"],
  "events": ["item 1"],
  "summary": "short 1-sentence summary in English"
}

Rules:
- Reply in English (casual, friendly).
- Items must be short phrases, not full sentences.
- If a category has no items, return an empty array.
- Never include explanations outside the JSON.
- Do not include a worries category — emotional content is handled elsewhere.
''';

  static const String _taskCoachSystem = '''
You are a task coach for someone with ADHD. They have ONE specific task they want help working on.

Break the task into 3–5 micro-steps. Each step must be doable in 2–10 minutes and feel almost embarrassingly small — the goal is to lower the activation barrier.

Respond ONLY with JSON in this exact shape:
{
  "taskTitle": "short rephrased version of the task",
  "totalMinutes": 0,
  "firstMove": "one tiny physical action to start RIGHT NOW (under 30 seconds)",
  "steps": [
    {"title": "short step title", "detail": "one short sentence on how to do it", "minutes": 5},
    {"title": "...", "detail": "...", "minutes": 5}
  ]
}

Rules:
- Reply in English. Warm, casual, encouraging.
- totalMinutes must equal the sum of step minutes.
- Each step.title is a verb phrase ("Open the doc", "Draft 3 bullet points").
- Each step.detail is concrete and specific.
- firstMove is a body-level action (e.g. "Open your laptop", "Put your phone face-down").
- Never include explanations outside the JSON.
''';

  static const String _emotionalSystem = '''
You are Neuro Friend, supporting a neurodivergent user who is expressing emotion.

Given the user's voice transcript, respond ONLY with JSON in this exact shape:
{
  "emotion_label": "short label (3-5 words) naming what they seem to feel",
  "validation_message": "1-2 warm sentences validating their feelings — no advice yet",
  "coping_tips": [
    {"emoji": "🌬️", "title": "short tip title", "body": "one short sentence with a concrete action"},
    {"emoji": "📝", "title": "...", "body": "..."},
    {"emoji": "🐾", "title": "...", "body": "..."}
  ]
}

Rules:
- Reply in English. Casual, warm, non-clinical.
- Exactly 3 coping_tips. Each tip should be doable in under 5 minutes.
- Pick emojis that fit the tip (breathing, writing, grounding, movement, sensory, etc.).
- Never include explanations outside the JSON.
''';

  static const String _intentSystem = '''
You classify a user's voice message into ONE of three intents.

Intents:
- emotional: the user is expressing ANY feeling or emotional state (happy, sad, anxious, overwhelmed, excited, frustrated, lonely, grateful, etc.), or asking for emotional support. If the message is primarily about how they feel, choose emotional.
- task: ONE specific task they want help breaking down or working on.
- brain: a brain dump — multiple unrelated items (tasks, ideas, events) jumbled together with no strong emotional content.

Respond with ONLY the intent word, lowercase, nothing else. No explanation, no punctuation.

Examples:
- "I'm so overwhelmed right now" -> emotional
- "I feel so happy today" -> emotional
- "I'm anxious about tomorrow" -> emotional
- "I need to finish the Q2 report, buy milk, and meeting at 3" -> brain
- "Help me work on my presentation slides" -> task
- "Tomorrow I have a meeting, I need to buy groceries, and brainstorm a new feature" -> brain
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
      return {
        'tasks': <String>[],
        'ideas': <String>[],
        'events': <String>[],
        'summary': '',
      };
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

  Future<Map<String, dynamic>> processTaskCoach(String transcript) async {
    if (!await _isOnline) {
      return {
        'taskTitle': transcript,
        'totalMinutes': 10,
        'firstMove': 'Open your laptop and bring up the relevant doc.',
        'steps': const [
          {
            'title': 'Write down what "done" looks like',
            'detail': 'One sentence — what does finished look like?',
            'minutes': 2,
          },
          {
            'title': 'List the first 3 things needed',
            'detail': "Don't overthink — whatever comes to mind.",
            'minutes': 3,
          },
          {
            'title': 'Start the very first thing',
            'detail': 'Set a 5-minute timer and just begin.',
            'minutes': 5,
          },
        ],
      };
    }

    return _groq.chatJson(
      systemPrompt: _taskCoachSystem,
      userMessage: transcript,
      maxTokens: 1024,
    );
  }

  Future<Map<String, dynamic>> processEmotionalCheckin(String transcript) async {
    if (!await _isOnline) {
      return {
        'emotion_label': 'Feeling overwhelmed',
        'validation_message':
            "It's okay to feel this way. You don't have to handle everything at once.",
        'coping_tips': const [
          {
            'emoji': '🌬️',
            'title': '4-4-6 breathing',
            'body': 'Inhale 4s, hold 4s, exhale slowly 6s. Repeat 3–5 times.',
          },
          {
            'emoji': '📝',
            'title': 'Write it out',
            'body':
                "List 3 things on your mind. Don't sort — just let them out.",
          },
          {
            'emoji': '🐾',
            'title': 'Pick the smallest one',
            'body':
                'Take the lightest task, work 2 minutes. Momentum is what matters.',
          },
        ],
      };
    }

    return _groq.chatJson(
      systemPrompt: _emotionalSystem,
      userMessage: transcript,
      maxTokens: 768,
    );
  }

  Future<String> detectIntent(String transcript) async {
    if (!await _isOnline) return 'brain';
    try {
      final raw = await _groq.chat(
        systemPrompt: _intentSystem,
        userMessage: transcript,
        maxTokens: 512,
      );
      final word = raw.trim().toLowerCase();
      // ignore: avoid_print
      print('Intent classification raw: "$word"');
      if (word.contains('emotional')) return 'emotional';
      if (word.contains('task')) return 'task';
      return 'brain';
    } catch (e) {
      // ignore: avoid_print
      print('Intent classification failed: $e');
      return 'brain';
    }
  }
}
