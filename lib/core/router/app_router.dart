import 'package:flutter/material.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/login_screen.dart';
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
  static const String register = '/register';
  static const String login = '/login';

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
    switch (settings.name) {
      case AppRoutes.splash:
        return _build(const SplashScreen());
      case AppRoutes.register:
        return _build(const RegisterScreen());
      case AppRoutes.login:
        return _build(const LoginScreen());

      case AppRoutes.home:
        return _build(const MainShell(initialTab: NFTab.home));
      case AppRoutes.tasks:
        return _build(const MainShell(initialTab: NFTab.tasks));
      case AppRoutes.mic:
        return _build(const MainShell(initialTab: NFTab.mic));
      case AppRoutes.brainDumps:
        return _build(const MainShell(initialTab: NFTab.brainDumps));
      case AppRoutes.profile:
        return _build(const MainShell(initialTab: NFTab.profile));

      case AppRoutes.listening:
        return _build(const ListeningScreen());
      case AppRoutes.intent:
        final transcript = settings.arguments as String? ?? '';
        return _build(IntentScreen(transcript: transcript));
      case AppRoutes.processing:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _build(
          ProcessingScreen(
            nextRoute: args['nextRoute'] as String? ?? AppRoutes.brainResult,
            transcript: args['transcript'] as String? ?? '',
            intent: args['intent'] as String? ?? 'brain',
          ),
        );
      case AppRoutes.brainResult:
        return _build(const BrainResultScreen());
      case AppRoutes.emotional:
        return _build(const EmotionalScreen());
      case AppRoutes.taskSteps:
        return _build(const TaskStepsScreen());
      case AppRoutes.taskTimer:
        return _build(const TaskTimerScreen());
      case AppRoutes.taskProgress:
        return _build(const TaskProgressScreen());

      default:
        return _build(const SplashScreen());
    }
  }

  static MaterialPageRoute _build(Widget page) =>
      MaterialPageRoute(builder: (_) => page);
}
