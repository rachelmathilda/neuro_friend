import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/nf_button.dart';
import '../../core/widgets/nf_screen.dart';

class _Cat {
  final String label;
  final Color color, bg, pill;
  final IconData icon;
  final List<String> items;
  const _Cat(this.label, this.color, this.bg, this.pill, this.icon, this.items);
}

const _cats = [
  _Cat('Tasks', AppColors.tasksAccent, AppColors.orangeSoft, AppColors.orange,
      Icons.checklist_rounded, ['Send Q2 report to boss', 'Buy milk & eggs']),
  _Cat('Ideas', AppColors.ideasAccent, AppColors.lavenderSoft, AppColors.lavender,
      Icons.psychology_alt_outlined, ['ADHD helper app idea']),
  _Cat('Events', AppColors.navy, AppColors.blueSoft, Color(0xFFA9C8F2),
      Icons.calendar_today_rounded, ['Team meeting at 3 PM']),
  _Cat('Worries', AppColors.worriesAccent, AppColors.pinkSoft, AppColors.pink,
      Icons.favorite_outline_rounded, ['Report deadline tomorrow']),
];

class BrainResultScreen extends StatelessWidget {
  const BrainResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          const Padding(
            padding: EdgeInsets.only(bottom: 14, left: 8, right: 8),
            child: Text(
              '"You have 2 tasks, 1 idea, 1 event, 1 worry."',
              textAlign: TextAlign.center,
              style: TextStyle(
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
              itemCount: _cats.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                if (i < _cats.length) return _CategoryCard(cat: _cats[i]);
                return _ActionPrompt();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _Cat cat;
  const _CategoryCard({required this.cat});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: cat.bg, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(14),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cat.pill,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon, size: 12, color: cat.color),
                    const SizedBox(width: 6),
                    Text(cat.label,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: cat.color)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              for (final t in cat.items)
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
          const Positioned(
            top: 0,
            right: 0,
            child: Icon(Icons.close_rounded,
                size: 16, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _ActionPrompt extends StatelessWidget {
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
              Text('Want me to help with one?',
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
                label: 'Work on report',
                small: true,
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.taskSteps),
              ),
              NFButton(
                label: 'Talk again',
                small: true,
                variant: NFButtonVariant.ghost,
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
