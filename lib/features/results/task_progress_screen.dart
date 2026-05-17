import 'package:flutter/material.dart';
import 'task_steps_screen.dart';

class TaskProgressScreen extends StatelessWidget {
  const TaskProgressScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const TaskStepsScreen(completed: [1, 2, 3]);
}
