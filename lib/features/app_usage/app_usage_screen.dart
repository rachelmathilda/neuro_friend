import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:permission_handler/permission_handler.dart';
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
  bool _permissionGranted = false;
  bool _permissionChecked = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final usageStatus = await _checkUsagePermission();

    if (usageStatus) {
      setState(() {
        _permissionGranted = true;
        _permissionChecked = true;
      });
      ref.read(appUsageProvider.notifier).fetchToday();
    } else {
      setState(() => _permissionChecked = true);
      _requestPermission();
    }
  }

  Future<bool> _checkUsagePermission() async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      await AppUsageNotifier.checkPermission(start, now);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _requestPermission() async {
    await openAppSettings();
    if (!mounted) return;
    await Future.delayed(const Duration(seconds: 1));
    final granted = await _checkUsagePermission();
    if (granted && mounted) {
      setState(() => _permissionGranted = true);
      ref.read(appUsageProvider.notifier).fetchToday();
    }
  }

  @override
  Widget build(BuildContext context) {
    final usageState = ref.watch(appUsageProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Text(
                'App Usage Monitoring',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w100,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (!_permissionChecked)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (!_permissionGranted)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Usage access permission needed',
                          style: AppTextStyles.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Allow usage access in Settings to see your app usage data.',
                          style: AppTextStyles.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _requestPermission,
                          child: const Text('Open Settings'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: usageState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                  data: (entries) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          height: 130,
                          child: _UsageChart(entries: entries),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: entries.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _UsageRow(
                            entry: entries[i],
                            index: i,
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
    if (entries.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.butter,
          borderRadius: BorderRadius.circular(16),
        ),
      );
    }

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
            barWidth: 0,
            belowBarData: BarAreaData(show: true, color: AppColors.butter),
            dotData: const FlDotData(show: false),
          ),
        ],
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minY: 0,
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  final AppUsageEntry entry;
  final Duration maxUsage;
  final int index;

  const _UsageRow({
    required this.entry,
    required this.maxUsage,
    required this.index,
  });

  static const _colors = [
    Color(0xFF2E5BA8),
    Color(0xFF4A7FD4),
    Color(0xFF6BC46A),
    Color(0xFFFF8A8A),
    Color(0xFFD4CFEE),
    Color(0xFFF5A623),
    Color(0xFF2E5BA8),
  ];

  @override
  Widget build(BuildContext context) {
    final ratio = maxUsage.inSeconds == 0
        ? 0.0
        : entry.usage.inSeconds / maxUsage.inSeconds;
    final color = _colors[index % _colors.length];

    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              FractionallySizedBox(
                widthFactor: ratio.clamp(0.05, 1.0),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
