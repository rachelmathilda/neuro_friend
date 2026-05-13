import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/app_usage_provider.dart';
import '../../core/widgets/bottom_nav.dart';

class AppUsageScreen extends ConsumerStatefulWidget {
  const AppUsageScreen({super.key});

  @override
  ConsumerState<AppUsageScreen> createState() => _AppUsageScreenState();
}

class _AppUsageScreenState extends ConsumerState<AppUsageScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(appUsageProvider.notifier).fetchToday();
  }

  @override
  Widget build(BuildContext context) {
    final usageState = ref.watch(appUsageProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Center(
                child: Text(
                  'App Usage Monitoring',
                  style: AppTextStyles.titleLarge,
                ),
              ),
            ),
            const SizedBox(height: 16),
            usageState.when(
              loading: () => const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Expanded(child: Center(child: Text('$e'))),
              data: (entries) => Expanded(
                child: Column(
                  children: [
                    SizedBox(height: 120, child: _UsageChart(entries: entries)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _UsageRow(
                          entry: entries[i],
                          maxUsage: entries.isEmpty
                              ? Duration.zero
                              : entries.first.usage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BottomNav(currentIndex: 3),
          ],
        ),
      ),
    );
  }
}

class _UsageChart extends StatelessWidget {
  final List<AppUsageEntry> entries;
  const _UsageChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox();
    final spots = entries.take(7).toList().asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.usage.inMinutes.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.butter,
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.butter.withValues(alpha: 0.5),
            ),
            dotData: const FlDotData(show: false),
          ),
        ],
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  final AppUsageEntry entry;
  final Duration maxUsage;

  const _UsageRow({required this.entry, required this.maxUsage});

  static const _colors = [
    AppColors.primaryDark,
    AppColors.primary,
    AppColors.moodHappy,
    AppColors.tagSensory,
    AppColors.moodAngry,
    AppColors.moodAnxious,
    AppColors.primaryDark,
  ];

  @override
  Widget build(BuildContext context) {
    final ratio = maxUsage.inSeconds == 0
        ? 0.0
        : entry.usage.inSeconds / maxUsage.inSeconds;
    final colorIndex = _UsageRow._colors.length % (_colors.length);

    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              FractionallySizedBox(
                widthFactor: ratio.clamp(0.0, 1.0),
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: _colors[colorIndex],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
