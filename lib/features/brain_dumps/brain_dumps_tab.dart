import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/nf_screen.dart';
import '../../core/widgets/nf_tab_bar.dart';

class _Dump {
  final String id, when, summary;
  final int tasks, ideas, events, worries;
  const _Dump(this.id, this.when, this.summary, this.tasks, this.ideas,
      this.events, this.worries);
}

const _dumps = [
  _Dump('d1', 'Today · 09:42', '"Lots of deadlines this week…"', 2, 1, 1, 1),
  _Dump('d2', 'Yesterday · 22:18',
      '"Exhausted but still thinking about work"', 0, 2, 0, 3),
  _Dump('d3', 'Mon · 14:05',
      '"New app idea while I was in the shower"', 1, 4, 1, 0),
  _Dump('d4', 'May 24 · 11:30',
      '"Forgot what I needed to take care of"', 5, 0, 2, 2),
];

class BrainDumpsTab extends StatelessWidget {
  final ValueChanged<NFTab> onTab;
  const BrainDumpsTab({super.key, required this.onTab});

  @override
  Widget build(BuildContext context) {
    return NFScreen(
      tabActive: NFTab.brainDumps,
      onTab: onTab,
      background: AppColors.bgSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Brain Dumps',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimary)),
                SizedBox(height: 4),
                Text("Everything you've said so far.",
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Row(
            children: const [
              Expanded(child: _CountChip(value: 8, label: 'Tasks', color: AppColors.tasksAccent, bg: AppColors.orangeSoft)),
              SizedBox(width: 8),
              Expanded(child: _CountChip(value: 7, label: 'Ideas', color: AppColors.ideasAccent, bg: AppColors.lavenderSoft)),
              SizedBox(width: 8),
              Expanded(child: _CountChip(value: 4, label: 'Events', color: AppColors.navy, bg: AppColors.blueSoft)),
              SizedBox(width: 8),
              Expanded(child: _CountChip(value: 6, label: 'Worries', color: AppColors.worriesAccent, bg: AppColors.pinkSoft)),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: _dumps.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _DumpCard(
                dump: _dumps[i],
                onTap: () =>
                    Navigator.pushNamed(ctx, AppRoutes.brainResult),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final int value;
  final String label;
  final Color color, bg;
  const _CountChip(
      {required this.value, required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        children: [
          Text('$value',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

class _DumpCard extends StatelessWidget {
  final _Dump dump;
  final VoidCallback onTap;
  const _DumpCard({required this.dump, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dump.when,
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary)),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.lavenderSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.psychology_alt_outlined,
                        size: 14, color: AppColors.ideasAccent),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(dump.summary,
                  style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      height: 1.45,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (dump.tasks > 0)
                    _MiniChip(
                        '${dump.tasks} task',
                        Icons.checklist_rounded,
                        AppColors.tasksAccent,
                        AppColors.orangeSoft),
                  if (dump.ideas > 0)
                    _MiniChip(
                        '${dump.ideas} idea',
                        Icons.psychology_alt_outlined,
                        AppColors.ideasAccent,
                        AppColors.lavenderSoft),
                  if (dump.events > 0)
                    _MiniChip(
                        '${dump.events} event',
                        Icons.calendar_today_rounded,
                        AppColors.navy,
                        AppColors.blueSoft),
                  if (dump.worries > 0)
                    _MiniChip(
                        '${dump.worries} worry',
                        Icons.favorite_outline_rounded,
                        AppColors.worriesAccent,
                        AppColors.pinkSoft),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color, bg;
  const _MiniChip(this.label, this.icon, this.color, this.bg);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
