import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/nf_mascot.dart';
import '../../core/widgets/nf_screen.dart';
import '../../core/widgets/nf_tab_bar.dart';

class HomeTab extends StatelessWidget {
  final ValueChanged<NFTab> onTab;
  const HomeTab({super.key, required this.onTab});

  @override
  Widget build(BuildContext context) {
    return NFScreen(
      tabActive: NFTab.home,
      onTab: onTab,
      background: AppColors.bgSoft,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 8),
        children: [
          _Greeting(),
          const SizedBox(height: 14),
          _HeroCard(onStart: () => onTab(NFTab.mic)),
          const SizedBox(height: 18),
          const _SectionLabel('Features'),
          const SizedBox(height: 10),
          _FeaturesGrid(onTab: onTab),
          const SizedBox(height: 18),
          const _SectionLabel('Recent activity'),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Good morning,',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              SizedBox(height: 2),
              Text(
                'Hi, friend',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: AppColors.cream,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_outlined,
            size: 18,
            color: AppColors.navy,
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onStart;
  const _HeroCard({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4C8CE4), Color(0xFF6BA0EA)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const NFMascot(size: 68),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'A lot on your mind?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tap the mic, say anything. I'll help sort it.",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    onTap: onStart,
                    borderRadius: BorderRadius.circular(999),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mic_rounded,
                            size: 14,
                            color: AppColors.navy,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Start talking',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.textSecondary,
    ),
  );
}

class _FeaturesGrid extends StatelessWidget {
  final ValueChanged<NFTab> onTab;
  const _FeaturesGrid({required this.onTab});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.7,
      children: [
        _FeatureTile(
          bg: AppColors.lavenderSoft,
          fg: AppColors.ideasAccent,
          icon: Icons.psychology_alt_outlined,
          title: 'Brain Dump',
          meta: 'Voice to categories',
          onTap: () => onTab(NFTab.brainDumps),
        ),
        _FeatureTile(
          bg: AppColors.orangeSoft,
          fg: AppColors.tasksAccent,
          icon: Icons.checklist_rounded,
          title: 'Task Coach',
          meta: 'Micro-step breakdown',
          onTap: () => onTab(NFTab.tasks),
        ),
        _FeatureTile(
          bg: AppColors.pinkSoft,
          fg: AppColors.worriesAccent,
          icon: Icons.favorite_outline_rounded,
          title: 'Check-in',
          meta: 'Emotional support',
          onTap: () => onTab(NFTab.mic),
        ),
        _FeatureTile(
          bg: AppColors.creamSoft,
          fg: AppColors.creamAccent,
          icon: Icons.auto_awesome_outlined,
          title: 'Smart Sort',
          meta: 'Auto-detect intent',
          onTap: () => onTab(NFTab.mic),
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final Color bg, fg;
  final IconData icon;
  final String title, meta;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.bg,
    required this.fg,
    required this.icon,
    required this.title,
    required this.meta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: fg),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
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
