import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/nf_screen.dart';

enum IntentKind { brain, emotional, task }

class _IntentSpec {
  final IntentKind kind;
  final String title, subtitle;
  final Color color, bg;
  final IconData icon;
  const _IntentSpec(this.kind, this.title, this.subtitle, this.color, this.bg, this.icon);
}

const _intents = [
  _IntentSpec(IntentKind.brain, 'Brain dump',
      'Multiple things detected — auto organise',
      AppColors.navy, AppColors.lavenderSoft, Icons.psychology_alt_outlined),
  _IntentSpec(IntentKind.emotional, 'Emotional check-in',
      'Emotion detected — validation & coping',
      AppColors.worriesAccent, AppColors.pinkSoft, Icons.favorite_outline_rounded),
  _IntentSpec(IntentKind.task, 'Task coach',
      '1 specific task — micro-step breakdown',
      AppColors.tasksAccent, AppColors.orangeSoft, Icons.checklist_rounded),
];

class IntentScreen extends StatefulWidget {
  const IntentScreen({super.key});

  @override
  State<IntentScreen> createState() => _IntentScreenState();
}

class _IntentScreenState extends State<IntentScreen> {
  IntentKind? _selected;
  Timer? _selectTimer;
  Timer? _nextTimer;
  static const _autoPick = IntentKind.brain;

  @override
  void initState() {
    super.initState();
    _selectTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _selected = _autoPick);
    });
    _nextTimer = Timer(const Duration(milliseconds: 3000), () => _go(_autoPick));
  }

  void _go(IntentKind k) {
    _selectTimer?.cancel();
    _nextTimer?.cancel();
    if (!mounted) return;
    final route = switch (k) {
      IntentKind.brain => AppRoutes.brainResult,
      IntentKind.emotional => AppRoutes.emotional,
      IntentKind.task => AppRoutes.taskSteps,
    };
    Navigator.pushReplacementNamed(context, AppRoutes.processing,
        arguments: route);
  }

  @override
  void dispose() {
    _selectTimer?.cancel();
    _nextTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NFScreen(
      hideTabs: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Detecting intent…',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 22),
              for (final it in _intents) ...[
                _IntentCard(
                  spec: it,
                  selected: _selected == it.kind,
                  onTap: () {
                    setState(() => _selected = it.kind);
                    Timer(const Duration(milliseconds: 350), () => _go(it.kind));
                  },
                ),
                if (it != _intents.last) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IntentCard extends StatelessWidget {
  final _IntentSpec spec;
  final bool selected;
  final VoidCallback onTap;

  const _IntentCard(
      {required this.spec, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.03 : 1,
      duration: const Duration(milliseconds: 250),
      child: Material(
        color: selected ? spec.bg : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? spec.color : AppColors.border,
            width: 1.5,
          ),
        ),
        elevation: selected ? 6 : 1,
        shadowColor: const Color(0xFF1C2440).withOpacity(0.08),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: spec.bg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(spec.icon, color: spec.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(spec.title,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(spec.subtitle,
                          style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                              height: 1.4)),
                    ],
                  ),
                ),
                if (selected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration:
                        BoxDecoration(color: spec.color, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
