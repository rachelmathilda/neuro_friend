import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/nf_mascot.dart';
import '../../core/widgets/nf_screen.dart';

class _Tip {
  final String emoji, title, body;
  const _Tip(this.emoji, this.title, this.body);
}

const _tips = [
  _Tip('🌬️', '4-4-6 breathing',
      'Inhale 4s, hold 4s, exhale slowly 6s. Repeat 3–5 times.'),
  _Tip('📝', 'Write it out',
      "List 3 things on your mind. Don't sort — just let them out."),
  _Tip('🐾', 'Pick the smallest one',
      'Take the lightest task, work 2 minutes. Momentum is what matters.'),
  _Tip('💧', '5-minute break',
      'Drink water, walk a bit, look out a window. Body needs a reset.'),
];

class EmotionalScreen extends StatelessWidget {
  const EmotionalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NFScreen(
      hideTabs: true,
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NFHeader(title: 'Emotional Check-in', onBack: () => Navigator.pop(context)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.pinkSoft,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('EMOTION DETECTED',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppColors.worriesAccent)),
                      SizedBox(height: 6),
                      Text('Overwhelm + task paralysis',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: NFMascot(size: 44, mood: MascotMood.calm),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "\"It's okay to feel this way. You don't have to handle everything at once.\"",
                          style: TextStyle(
                              fontSize: 13.5,
                              fontStyle: FontStyle.italic,
                              height: 1.55,
                              color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: const [
                    Icon(Icons.auto_awesome_outlined,
                        size: 14, color: AppColors.blue),
                    SizedBox(width: 6),
                    Text('Try one of these:',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy)),
                  ],
                ),
                const SizedBox(height: 8),
                for (final t in _tips) ...[
                  _TipCard(tip: t),
                  const SizedBox(height: 8),
                ],
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text(
                    "Pick whatever fits you right now. There's no \"right\" choice.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        color: AppColors.textTertiary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final _Tip tip;
  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.creamSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(tip.emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.title,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(tip.body,
                    style: const TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
