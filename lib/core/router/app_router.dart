import 'package:flutter/material.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/todos/todos_screen.dart';
import '../../features/brain_dump/brain_dump_screen.dart';
import '../../features/ai_voice/ai_voice_screen.dart';
import '../../features/deep_focus/deep_focus_screen.dart';
import '../../features/app_usage/app_usage_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/recap/scheduler_recap_screen.dart';
import '../../features/recap/focus_recap_screen.dart';
import '../../features/recap/social_script_recap_screen.dart';
import '../../features/recap/sensory_recap_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String register = '/register';
  static const String login = '/login';
  static const String home = '/home';
  static const String todos = '/todos';
  static const String brainDump = '/brain-dump';
  static const String aiVoice = '/ai-voice';
  static const String deepFocus = '/deep-focus';
  static const String appUsage = '/app-usage';
  static const String profile = '/profile';
  static const String schedulerRecap = '/recap/scheduler';
  static const String focusRecap = '/recap/focus';
  static const String socialScriptRecap = '/recap/social-script';
  static const String sensoryRecap = '/recap/sensory';
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
        return _build(const HomeScreen());
      case AppRoutes.todos:
        return _build(const TodosScreen());
      case AppRoutes.brainDump:
        return _build(const BrainDumpScreen());
      case AppRoutes.aiVoice:
        return _build(const AIVoiceScreen());
      case AppRoutes.deepFocus:
        return _build(const DeepFocusScreen());
      case AppRoutes.appUsage:
        return _build(const AppUsageScreen());
      case AppRoutes.profile:
        return _build(const ProfileScreen());
      case AppRoutes.schedulerRecap:
        return _build(const SchedulerRecapScreen());
      case AppRoutes.focusRecap:
        return _build(const FocusRecapScreen());
      case AppRoutes.socialScriptRecap:
        return _build(const SocialScriptRecapScreen());
      case AppRoutes.sensoryRecap:
        return _build(const SensoryRecapScreen());
      default:
        return _build(const SplashScreen());
    }
  }

  static MaterialPageRoute _build(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
