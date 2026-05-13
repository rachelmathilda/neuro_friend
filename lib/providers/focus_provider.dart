import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/focus_session_model.dart';
import '../services/notification_service.dart';

final focusProvider = StateNotifierProvider<FocusNotifier, FocusSessionModel?>(
  (ref) => FocusNotifier(),
);

class FocusNotifier extends StateNotifier<FocusSessionModel?> {
  FocusNotifier() : super(null);

  Timer? _reminderTimer;
  Timer? _warningTimer;

  void startSession({
    required Duration reminderInterval,
    required bool allowAppSwitch,
    String? currentTaskId,
  }) {
    state = FocusSessionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      reminderInterval: reminderInterval,
      allowAppSwitch: allowAppSwitch,
      currentTaskId: currentTaskId,
    );

    _reminderTimer = Timer.periodic(reminderInterval, (_) {
      NotificationService().showFocusReminder();
    });

    _warningTimer = Timer.periodic(const Duration(hours: 1), (_) {
      if (state == null) return;
      final hours = state!.elapsed.inHours;
      if (hours >= 2) {
        NotificationService().showDeepFocusWarning(hours);
      }
    });
  }

  void stopSession() {
    _reminderTimer?.cancel();
    _warningTimer?.cancel();
    state = null;
    NotificationService().cancelAll();
  }

  void addDistraction(String distraction) {
    if (state == null) return;
    state = FocusSessionModel(
      id: state!.id,
      startTime: state!.startTime,
      reminderInterval: state!.reminderInterval,
      allowAppSwitch: state!.allowAppSwitch,
      currentTaskId: state!.currentTaskId,
      distractions: [...state!.distractions, distraction],
    );
  }
}
