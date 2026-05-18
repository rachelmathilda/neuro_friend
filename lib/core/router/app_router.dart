import 'package:flutter/material.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/mic/listening_screen.dart';
import '../../features/mic/intent_screen.dart';
import '../../features/mic/processing_screen.dart';
import '../../features/results/brain_result_screen.dart';
import '../../features/results/emotional_screen.dart';
import '../../features/results/task_steps_screen.dart';
import '../../features/results/task_timer_screen.dart';
import '../../features/results/task_progress_screen.dart';
import '../widgets/nf_tab_bar.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';

  // Main shell tabs
  static const String home = '/home';
  static const String tasks = '/tasks';
  static const String mic = '/mic';
  static const String brainDumps = '/brain-dumps';
  static const String profile = '/profile';

  // Voice flow
  static const String listening = '/listening';
  static const String intent = '/intent';
  static const String processing = '/processing';

  // Result screens
  static const String brainResult = '/brain-result';
  static const String emotional = '/emotional';
  static const String taskSteps = '/task-steps';
  static const String taskTimer = '/task-timer';
  static const String taskProgress = '/task-progress';
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Route<dynamic> build(Widget page) =>
        MaterialPageRoute(builder: (_) => page, settings: settings);
    switch (settings.name) {
      case AppRoutes.splash:
        return build(const SplashScreen());

      case AppRoutes.home:
        return build(const MainShell(initialTab: NFTab.home));
      case AppRoutes.tasks:
        return build(const MainShell(initialTab: NFTab.tasks));
      case AppRoutes.mic:
        return build(const MainShell(initialTab: NFTab.mic));
      case AppRoutes.brainDumps:
        return build(const MainShell(initialTab: NFTab.brainDumps));
      case AppRoutes.profile:
        return build(const MainShell(initialTab: NFTab.profile));

      case AppRoutes.listening:
        return build(const ListeningScreen());
      case AppRoutes.intent:
        return build(IntentScreen(transcript: (settings.arguments as String?) ?? ''));
      case AppRoutes.processing:
        return build(ProcessingScreen(arguments: settings.arguments));

      case AppRoutes.brainResult:
        return build(BrainResultScreen(entryId: settings.arguments as String?));
      case AppRoutes.emotional:
        return build(const EmotionalScreen());
      case AppRoutes.taskSteps:
        return build(const TaskStepsScreen());
      case AppRoutes.taskTimer:
        return build(const TaskTimerScreen());
      case AppRoutes.taskProgress:
        return build(const TaskProgressScreen());

      default:
        return build(const SplashScreen());
    }
  }

}
