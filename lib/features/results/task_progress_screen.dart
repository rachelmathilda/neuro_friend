import 'package:flutter/material.dart';
import '../../data/models/task_step_model.dart';
import 'task_steps_screen.dart';

/// Demo / preview screen that shows TaskStepsScreen with pre-completed steps.
/// Navigates using named route so arguments flow correctly.
class TaskProgressScreen extends StatelessWidget {
  const TaskProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const TaskStepsScreen(),
        settings: RouteSettings(
          arguments: {
            'steps': [
              TaskStepModel(
                n: 1,
                title: 'Open PowerPoint, pick a clean template',
                hint: "Don't start from scratch. Any template will do.",
                mins: 2,
              ),
              TaskStepModel(
                n: 2,
                title: 'Write 10 slide titles',
                hint: 'Titles only — no content yet.',
                mins: 5,
              ),
              TaskStepModel(
                n: 3,
                title: 'Fill slides 1–3: key data',
                hint: 'Copy-paste numbers from the spreadsheet.',
                mins: 10,
              ),
            ],
            'taskTitle': 'Make Q2 presentation',
            'totalMinutes': 17,
            'firstMove': 'Open a blank PowerPoint now.',
          },
        ),
      ),
    );
  }
}
