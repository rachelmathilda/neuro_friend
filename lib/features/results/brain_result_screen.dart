import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/nf_button.dart';
import '../../core/widgets/nf_screen.dart';
import '../../data/models/brain_dump_entry.dart';
import '../../providers/brain_dump_provider.dart';
import '../../services/tts_service.dart';

class _CatSpec {
  final String label;
  final Color color, bg, pill;
  final IconData icon;
  const _CatSpec(this.label, this.color, this.bg, this.pill, this.icon);
}

const _tasksSpec = _CatSpec('Tasks', AppColors.tasksAccent, AppColors.orangeSoft,
    AppColors.orange, Icons.checklist_rounded);
const _ideasSpec = _CatSpec('Ideas', AppColors.ideasAccent,
    AppColors.lavenderSoft, AppColors.lavender, Icons.psychology_alt_outlined);
const _eventsSpec = _CatSpec('Events', AppColors.navy, AppColors.blueSoft,
    Color(0xFFA9C8F2), Icons.calendar_today_rounded);
class BrainResultScreen extends ConsumerStatefulWidget {
  final String? entryId;
  const BrainResultScreen({super.key, this.entryId});

  @override
  ConsumerState<BrainResultScreen> createState() => _BrainResultScreenState();
}

class _BrainResultScreenState extends ConsumerState<BrainResultScreen> {
  final TtsService _tts = TtsService();
  bool _ttsSpoken = false;

  @override
  void initState() {
    super.initState();
    _tts.init();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  BrainDumpEntry? _resolve() {
    if (widget.entryId != null) {
      return ref.watch(brainDumpByIdProvider(widget.entryId!));
    }
    final list = ref.watch(brainDumpListProvider);
    return list.isEmpty ? null : list.first;
  }

  @override
  Widget build(BuildContext context) {
    final entry = _resolve();

    if (entry != null && !_ttsSpoken && entry.summary.isNotEmpty) {
      _ttsSpoken = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tts.speak(entry.summary);
      });
    }

    return NFScreen(
      hideTabs: true,
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NFHeader(
            title: 'Brain Dump',
            onBack: () => Navigator.pop(context),
          ),
          if (entry == null)
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Brain dump not found.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            )
          else
            Expanded(child: _Body(entry: entry)),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final BrainDumpEntry entry;
  const _Body({required this.entry});

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      if (entry.tasks.isNotEmpty) _CategoryCard(spec: _tasksSpec, items: entry.tasks),
      if (entry.ideas.isNotEmpty) _CategoryCard(spec: _ideasSpec, items: entry.ideas),
      if (entry.events.isNotEmpty) _CategoryCard(spec: _eventsSpec, items: entry.events),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14, left: 8, right: 8),
          child: Text(
            '"${entry.summary.isEmpty ? 'Got everything down.' : entry.summary}"',
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
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: cards.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              if (i < cards.length) return cards[i];
              return const _ActionPrompt();
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _CatSpec spec;
  final List<String> items;
  const _CategoryCard({required this.spec, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: spec.bg, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: spec.pill,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(spec.icon, size: 12, color: spec.color),
                const SizedBox(width: 6),
                Text(spec.label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: spec.color)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (final t in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(t,
                  style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: AppColors.textPrimary)),
            ),
        ],
      ),
    );
  }
}

class _ActionPrompt extends StatelessWidget {
  const _ActionPrompt();

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
              Icon(Icons.auto_awesome_outlined, size: 14, color: AppColors.blue),
              SizedBox(width: 6),
              Text('Want me to help with one of these?',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy)),
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
                label: 'Talk again',
                small: true,
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.listening),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
