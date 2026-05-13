import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/repositories/focus_repository.dart';

class FocusRecapScreen extends ConsumerStatefulWidget {
  const FocusRecapScreen({super.key});

  @override
  ConsumerState<FocusRecapScreen> createState() => _FocusRecapScreenState();
}

class _FocusRecapScreenState extends ConsumerState<FocusRecapScreen> {
  final _repo = FocusRepository();
  double _avgHours = 0;
  int _bestHour = 7;
  List<String> _topDistractions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await _repo.fetchStats();
    setState(() {
      _avgHours = (stats['avgHours'] as num).toDouble();
      _bestHour = stats['bestHour'] as int;
      _topDistractions = List<String>.from(
        stats['topDistractions'] ?? ['Notification', 'Hunger', 'Games'],
      );
      _loading = false;
    });
  }

  String _formatHour(int hour) {
    final period = hour < 12 ? 'am' : 'pm';
    final h = hour == 0
        ? 12
        : hour > 12
        ? hour - 12
        : hour;
    return '$h.00 $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Check-in Recap'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                          '${_avgHours.toStringAsFixed(1)}h',
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: AppColors.tagSensory,
                          ),
                        ),
                        Text(
                          'Average daily deep focus hours',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DistractionCard(items: _topDistractions),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Best Hour to Focus',
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _formatHour(_bestHour),
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Text('until', style: AppTextStyles.bodySmall),
                        Text(
                          _formatHour(_bestHour + 5),
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _DistractionCard extends StatelessWidget {
  final List<String> items;
  const _DistractionCard({required this.items});

  static const _colors = [
    AppColors.chartYellow,
    AppColors.chartPurple,
    AppColors.chartRed,
  ];

  static const _ratios = [0.7, 0.45, 0.3];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Frequent Distractions', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          ...List.generate(
            items.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(items[i], style: AppTextStyles.bodySmall),
                  const SizedBox(height: 4),
                  Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: i < _ratios.length ? _ratios[i] : 0.2,
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: i < _colors.length
                                ? _colors[i]
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
