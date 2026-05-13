import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/focus_provider.dart';
import '../../providers/task_provider.dart';

class DeepFocusScreen extends ConsumerStatefulWidget {
  const DeepFocusScreen({super.key});

  @override
  ConsumerState<DeepFocusScreen> createState() => _DeepFocusScreenState();
}

class _DeepFocusScreenState extends ConsumerState<DeepFocusScreen> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  int _reminderMinutes = 60;
  bool _allowSwitch = false;

  @override
  void initState() {
    super.initState();
    final session = ref.read(focusProvider);
    if (session != null) {
      _elapsed = session.elapsed;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  void _start() {
    ref
        .read(focusProvider.notifier)
        .startSession(
          reminderInterval: Duration(minutes: _reminderMinutes),
          allowAppSwitch: _allowSwitch,
        );
    _startTimer();
  }

  void _stop() {
    _timer?.cancel();
    ref.read(focusProvider.notifier).stopSession();
    setState(() => _elapsed = Duration.zero);
    Navigator.pop(context);
  }

  String _formatElapsed(Duration d) {
    final h = d.inHours.toString().padLeft(1, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h: $m: $s';
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(focusProvider);
    final tasks = ref.watch(taskProvider);
    final isActive = session != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deep Focus'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Text(
                _formatElapsed(_elapsed),
                style: AppTextStyles.displayLarge,
              ),
            ),
            const SizedBox(height: 40),
            Text('Set reminder', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            _DropdownCard(value: 'Every $_reminderMinutes hour', onTap: () {}),
            const SizedBox(height: 16),
            Text('Can i switch to other app?', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            _DropdownCard(
              value: _allowSwitch ? 'Yes' : 'No',
              onTap: () => setState(() => _allowSwitch = !_allowSwitch),
            ),
            const SizedBox(height: 24),
            tasks.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (taskList) {
                if (taskList.isEmpty) return const SizedBox();
                final current = taskList.first;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Current task', style: AppTextStyles.bodyMedium),
                        Text(
                          'Next task',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.butter,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                current.title,
                                style: AppTextStyles.titleMedium,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Now',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${current.startTime.hour}.${current.startTime.minute.toString().padLeft(2, '0')} - ${current.endTime.hour}.${current.endTime.minute.toString().padLeft(2, '0')}',
                                style: AppTextStyles.bodySmall,
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.calendar_today, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${current.date.day} ${_month(current.date.month)} ${current.date.year}',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: isActive ? _stop : _start,
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive
                    ? Colors.redAccent
                    : AppColors.primary,
              ),
              child: Text(
                isActive ? 'Stop Deep Focus Mode' : 'Start Deep Focus Mode',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _month(int m) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m];
  }
}

class _DropdownCard extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _DropdownCard({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(value, style: AppTextStyles.bodyMedium),
      ),
    );
  }
}
