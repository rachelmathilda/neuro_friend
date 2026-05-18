import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/nf_button.dart';
import '../../core/widgets/nf_screen.dart';
import '../../data/models/brain_dump_model.dart';
import '../../data/repositories/brain_dump_repository.dart';

class BrainResultScreen extends StatefulWidget {
  const BrainResultScreen({super.key});

  @override
  State<BrainResultScreen> createState() => _BrainResultScreenState();
}

class _BrainResultScreenState extends State<BrainResultScreen> {
  final _repo = BrainDumpRepository();
  bool _saved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_saved) {
      _saved = true;
      _saveIfValid();
    }
  }

  Future<void> _saveIfValid() async {
    final data =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (data == null || data.containsKey('error')) return;
    final dump = BrainDumpModel.fromAiResult(data);
    if (dump.taskCount + dump.ideaCount + dump.eventCount + dump.worryCount ==
        0)
      return;
    await _repo.save(dump);
  }

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    final summary = data['summary'] as String? ?? 'Here\'s what you said.';
    final tasks = _toList(data['tasks']);
    final ideas = _toList(data['ideas']);
    final events = _toList(data['events']);
    final worries = _toList(data['worries']);
    final hasError = data.containsKey('error');

    final categories = [
      if (tasks.isNotEmpty)
        _CatData(
          'Tasks',
          AppColors.tasksAccent,
          AppColors.orangeSoft,
          AppColors.orange,
          Icons.checklist_rounded,
          tasks,
        ),
      if (ideas.isNotEmpty)
        _CatData(
          'Ideas',
          AppColors.ideasAccent,
          AppColors.lavenderSoft,
          AppColors.lavender,
          Icons.psychology_alt_outlined,
          ideas,
        ),
      if (events.isNotEmpty)
        _CatData(
          'Events',
          AppColors.navy,
          AppColors.blueSoft,
          const Color(0xFFA9C8F2),
          Icons.calendar_today_rounded,
          events,
        ),
      if (worries.isNotEmpty)
        _CatData(
          'Worries',
          AppColors.worriesAccent,
          AppColors.pinkSoft,
          AppColors.pink,
          Icons.favorite_outline_rounded,
          worries,
        ),
    ];

    return NFScreen(
      hideTabs: true,
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NFHeader(title: 'Brain Dump', onBack: () => Navigator.pop(context)),
          if (hasError)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Text(
                'Something went wrong. Try again?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.worriesAccent),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 14, left: 8, right: 8),
              child: Text(
                '"$summary"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          Expanded(
            child: categories.isEmpty && !hasError
                ? const Center(
                    child: Text(
                      'Nothing to categorise yet.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: categories.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      if (i < categories.length) {
                        return _CategoryCard(cat: categories[i]);
                      }
                      return _ActionPrompt(hasError: hasError);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<String> _toList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }
}

class _CatData {
  final String label;
  final Color color, bg, pill;
  final IconData icon;
  final List<String> items;
  const _CatData(
    this.label,
    this.color,
    this.bg,
    this.pill,
    this.icon,
    this.items,
  );
}

class _CategoryCard extends StatelessWidget {
  final _CatData cat;
  const _CategoryCard({required this.cat});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cat.bg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cat.pill,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon, size: 12, color: cat.color),
                    const SizedBox(width: 6),
                    Text(
                      cat.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: cat.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              for (final t in cat.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    t,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPrompt extends StatelessWidget {
  final bool hasError;
  const _ActionPrompt({this.hasError = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blueSoft, width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.auto_awesome_outlined,
                size: 14,
                color: AppColors.blue,
              ),
              SizedBox(width: 6),
              Text(
                'Want me to help with one?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              NFButton(
                label: 'Just save it',
                small: true,
                variant: NFButtonVariant.ghost,
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              ),
              NFButton(
                label: hasError ? 'Try again' : 'Work on a task',
                small: true,
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.taskSteps,
                ),
              ),
              NFButton(
                label: 'Talk again',
                small: true,
                variant: NFButtonVariant.ghost,
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.listening,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
