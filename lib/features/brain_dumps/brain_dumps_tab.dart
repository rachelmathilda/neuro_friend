import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/nf_screen.dart';
import '../../core/widgets/nf_tab_bar.dart';
import '../../data/models/brain_dump_model.dart';
import '../../data/repositories/brain_dump_repository.dart';

class BrainDumpsTab extends StatefulWidget {
  final ValueChanged<NFTab> onTab;
  const BrainDumpsTab({super.key, required this.onTab});

  @override
  State<BrainDumpsTab> createState() => _BrainDumpsTabState();
}

class _BrainDumpsTabState extends State<BrainDumpsTab> {
  final _repo = BrainDumpRepository();
  List<BrainDumpModel> _dumps = [];
  Map<String, int> _totals = {
    'tasks': 0,
    'ideas': 0,
    'events': 0,
    'worries': 0,
  };
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _repo.fetchRecent(),
        _repo.fetchTotals(),
      ]);
      if (mounted) {
        setState(() {
          _dumps = results[0] as List<BrainDumpModel>;
          _totals = results[1] as Map<String, int>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NFScreen(
      tabActive: NFTab.brainDumps,
      onTab: widget.onTab,
      background: AppColors.bgSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Brain Dumps',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Everything you've said so far.",
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _CountChip(
                  value: _totals['tasks']!,
                  label: 'Tasks',
                  color: AppColors.tasksAccent,
                  bg: AppColors.orangeSoft,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CountChip(
                  value: _totals['ideas']!,
                  label: 'Ideas',
                  color: AppColors.ideasAccent,
                  bg: AppColors.lavenderSoft,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CountChip(
                  value: _totals['events']!,
                  label: 'Events',
                  color: AppColors.navy,
                  bg: AppColors.blueSoft,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CountChip(
                  value: _totals['worries']!,
                  label: 'Worries',
                  color: AppColors.worriesAccent,
                  bg: AppColors.pinkSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.textTertiary,
              size: 32,
            ),
            const SizedBox(height: 10),
            const Text(
              'Could not load dumps',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_dumps.isEmpty) {
      return const Center(
        child: Text(
          "No brain dumps yet.\nTap the mic to start!",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, height: 1.6),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 8),
        itemCount: _dumps.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) => _DumpCard(
          dump: _dumps[i],
          onTap: () => Navigator.pushNamed(
            ctx,
            AppRoutes.brainResult,
            arguments: {
              'summary': _dumps[i].summary,
              'tasks': _dumps[i].tasks,
              'ideas': _dumps[i].ideas,
              'events': _dumps[i].events,
              'worries': _dumps[i].worries,
            },
          ),
          onDelete: () async {
            await _repo.delete(_dumps[i].id);
            _load();
          },
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final int value;
  final String label;
  final Color color, bg;
  const _CountChip({
    required this.value,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DumpCard extends StatelessWidget {
  final BrainDumpModel dump;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _DumpCard({
    required this.dump,
    required this.onTap,
    required this.onDelete,
  });

  String _formatWhen(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dumpDay = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(dumpDay).inDays;
    final hm =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (diff == 0) return 'Today · $hm';
    if (diff == 1) return 'Yesterday · $hm';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (diff < 7) return '${days[dt.weekday - 1]} · $hm';
    return '${dt.day} ${_month(dt.month)} · $hm';
  }

  String _month(int m) => const [
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
  ][m];

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
                  Text(
                    _formatWhen(dump.createdAt),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.lavenderSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.psychology_alt_outlined,
                        size: 14,
                        color: AppColors.ideasAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '"${dump.summary}"',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  height: 1.45,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (dump.taskCount > 0)
                    _MiniChip(
                      '${dump.taskCount} task',
                      Icons.checklist_rounded,
                      AppColors.tasksAccent,
                      AppColors.orangeSoft,
                    ),
                  if (dump.ideaCount > 0)
                    _MiniChip(
                      '${dump.ideaCount} idea',
                      Icons.psychology_alt_outlined,
                      AppColors.ideasAccent,
                      AppColors.lavenderSoft,
                    ),
                  if (dump.eventCount > 0)
                    _MiniChip(
                      '${dump.eventCount} event',
                      Icons.calendar_today_rounded,
                      AppColors.navy,
                      AppColors.blueSoft,
                    ),
                  if (dump.worryCount > 0)
                    _MiniChip(
                      '${dump.worryCount} worry',
                      Icons.favorite_outline_rounded,
                      AppColors.worriesAccent,
                      AppColors.pinkSoft,
                    ),
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
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
