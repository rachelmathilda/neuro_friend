import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int focusReminderId = 1;
  static const int deepFocusWarningId = 2;

  Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  Future<void> showFocusReminder() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'focus_reminder',
        'Focus Reminder',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await _plugin.show(
      focusReminderId,
      'Gimana fokusnya?',
      'Waktunya check-in dulu yuk 🧠',
      details,
    );
  }

  Future<void> showDeepFocusWarning(int hours) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'deep_focus_warning',
        'Deep Focus Warning',
        importance: Importance.defaultImportance,
      ),
    );
    await _plugin.show(
      deepFocusWarningId,
      'Udah $hours jam nih...',
      'Istirahat sebentar yuk, badan juga butuh break 💙',
      details,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
