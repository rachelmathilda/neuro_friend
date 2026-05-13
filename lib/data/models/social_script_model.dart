import 'package:cloud_firestore/cloud_firestore.dart';

enum ScriptContext { work, personal, social }

class SocialScriptModel {
  final String id;
  final String situation;
  final String script;
  final ScriptContext context;
  final DateTime createdAt;
  final int usageCount;

  SocialScriptModel({
    required this.id,
    required this.situation,
    required this.script,
    required this.context,
    required this.createdAt,
    this.usageCount = 0,
  });

  factory SocialScriptModel.fromMap(Map<String, dynamic> map, String id) {
    return SocialScriptModel(
      id: id,
      situation: map['situation'] ?? '',
      script: map['script'] ?? '',
      context: ScriptContext.values.firstWhere(
        (e) => e.name == map['context'],
        orElse: () => ScriptContext.social,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      usageCount: map['usageCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'situation': situation,
      'script': script,
      'context': context.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'usageCount': usageCount,
    };
  }
}
