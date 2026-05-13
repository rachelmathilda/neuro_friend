import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class SensoryRecapScreen extends StatelessWidget {
  const SensoryRecapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final levels = [2, 1, 3, 0, 0, 0, 0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensory Recap'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2 days overload',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text('Tuesday is the worst', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily load', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(days.length, (i) {
                      final color = _levelColor(levels[i]);
                      final hasLevel = levels[i] > 0;
                      return Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: hasLevel ? color : AppColors.streakInactive,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          days[i],
                          style: AppTextStyles.bodySmall.copyWith(
                            color: hasLevel
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  _Legend(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _TriggersCard(items: const ['Crowd', 'Bright light', 'Loud sound']),
          ],
        ),
      ),
    );
  }

  Color _levelColor(int level) {
    switch (level) {
      case 1:
        return AppColors.moodHappy;
      case 2:
        return AppColors.moodAnxious;
      case 3:
        return AppColors.tagSensory;
      default:
        return AppColors.streakInactive;
    }
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (AppColors.butter, 'Mild'),
      (AppColors.moodHappy, 'Mild'),
      (AppColors.moodAnxious, 'Moderate'),
      (AppColors.tagSensory, 'Heavy'),
    ];

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item.$1,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(item.$2, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _TriggersCard extends StatelessWidget {
  final List<String> items;
  const _TriggersCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sensor Triggers', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(item, style: AppTextStyles.bodyMedium),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
