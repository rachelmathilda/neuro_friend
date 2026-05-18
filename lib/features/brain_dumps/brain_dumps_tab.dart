import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/nf_screen.dart';
import '../../core/widgets/nf_tab_bar.dart';
import '../../data/models/brain_dump_entry.dart';
import '../../providers/brain_dump_provider.dart';

class BrainDumpsTab extends ConsumerWidget {
  final ValueChanged<NFTab> onTab;
  const BrainDumpsTab({super.key, required this.onTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(brainDumpListProvider);

    final totals = _Totals.from(entries);

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
            children: [
              Expanded(child: _CountChip(value: totals.tasks, label: 'Tasks', color: AppColors.tasksAccent, bg: AppColors.orangeSoft)),
              const SizedBox(width: 8),
              Expanded(child: _CountChip(value: totals.ideas, label: 'Ideas', color: AppColors.ideasAccent, bg: AppColors.lavenderSoft)),
              const SizedBox(width: 8),
              Expanded(child: _CountChip(value: totals.events, label: 'Events', color: AppColors.navy, bg: AppColors.blueSoft)),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: entries.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) => _DumpCard(
                      entry: entries[i],
                      onTap: () => Navigator.pushNamed(
                        ctx,
                        AppRoutes.brainResult,
                        arguments: entries[i].id,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Totals {
  final int tasks, ideas, events;
  const _Totals(this.tasks, this.ideas, this.events);

  factory _Totals.from(List<BrainDumpEntry> list) {
    var t = 0, i = 0, e = 0;
    for (final entry in list) {
      t += entry.tasks.length;
      i += entry.ideas.length;
      e += entry.events.length;
    }
    return _Totals(t, i, e);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.psychology_alt_outlined, size: 48, color: AppColors.textTertiary),
            SizedBox(height: 12),
            Text(
              'No brain dumps yet.\nTap the mic to start.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatWhen(DateTime ts) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tsDay = DateTime(ts.year, ts.month, ts.day);
  final diff = today.difference(tsDay).inDays;
  final hh = ts.hour.toString().padLeft(2, '0');
  final mm = ts.minute.toString().padLeft(2, '0');
  if (diff == 0) return 'Today · $hh:$mm';
  if (diff == 1) return 'Yesterday · $hh:$mm';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[ts.month - 1]} ${ts.day} · $hh:$mm';
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
  final BrainDumpEntry entry;
  final VoidCallback onTap;
  const _DumpCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final summary = entry.summary.isEmpty
        ? entry.rawTranscript
        : entry.summary;
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
                  Text(_formatWhen(entry.timestamp),
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
              Text('"$summary"',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                  if (entry.tasks.isNotEmpty)
                    _MiniChip(
                        '${entry.tasks.length} task',
                        Icons.checklist_rounded,
                        AppColors.tasksAccent,
                        AppColors.orangeSoft),
                  if (entry.ideas.isNotEmpty)
                    _MiniChip(
                        '${entry.ideas.length} idea',
                        Icons.psychology_alt_outlined,
                        AppColors.ideasAccent,
                        AppColors.lavenderSoft),
                  if (entry.events.isNotEmpty)
                    _MiniChip(
                        '${entry.events.length} event',
                        Icons.calendar_today_rounded,
                        AppColors.navy,
                        AppColors.blueSoft),
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
