class TaskStepModel {
  final int n;
  final String title;
  final String hint;
  final int mins;

  const TaskStepModel({
    required this.n,
    required this.title,
    required this.hint,
    required this.mins,
  });

  factory TaskStepModel.fromJson(Map<String, dynamic> json, {int index = 0}) {
    return TaskStepModel(
      n: index + 1,
      title: (json['title'] as String?) ?? '',
      hint: (json['detail'] as String?) ?? (json['hint'] as String?) ?? '',
      mins:
          (json['minutes'] as num?)?.toInt() ??
          (json['mins'] as num?)?.toInt() ??
          5,
    );
  }

  static List<TaskStepModel> fallback(String taskTitle) => [
    TaskStepModel(
      n: 1,
      title: 'Write down what "done" looks like',
      hint: 'Just one sentence — what does finished look like?',
      mins: 2,
    ),
    TaskStepModel(
      n: 2,
      title: 'List the first 3 things needed',
      hint: "Don't overthink — write whatever comes to mind.",
      mins: 3,
    ),
    TaskStepModel(
      n: 3,
      title: 'Start the very first thing on the list',
      hint: 'Set a 5-minute timer and just begin.',
      mins: 5,
    ),
  ];
}
