import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                _RecentRow(
                  title: 'Brain dump sorted',
                  meta: '2 tasks · 1 idea · 1 event · 1 worry',
                  time: '09:42',
                  color: AppColors.ideasAccent,
                  bg: AppColors.lavenderSoft,
                  icon: Icons.psychology_alt_outlined,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.brainResult),
                ),
                const SizedBox(height: 8),
                _RecentRow(
                  title: 'Task Coach started',
                  meta: 'Make Q2 presentation · 2/6 done',
                  time: '08:50',
                  color: AppColors.tasksAccent,
                  bg: AppColors.orangeSoft,
                  icon: Icons.checklist_rounded,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.taskSteps),
                ),
                const SizedBox(height: 8),
                _RecentRow(
                  title: 'Emotional check-in',
                  meta: 'Overwhelm + task paralysis',
                  time: 'Yesterday',
                  color: AppColors.worriesAccent,
                  bg: AppColors.pinkSoft,
                  icon: Icons.favorite_outline_rounded,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.emotional),
                ),
              ],
            ),
          ),
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
              Text('Good morning,',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              SizedBox(height: 2),
              Text('Hi, friend',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
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
          child: const Icon(Icons.notifications_outlined,
              size: 18, color: AppColors.navy),
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
            color: AppColors.blue.withOpacity(0.28),
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
                      height: 1.3),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tap the mic, say anything. I'll help sort it.",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                      height: 1.4),
                ),
                const SizedBox(height: 10),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    onTap: onStart,
                    borderRadius: BorderRadius.circular(999),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mic_rounded,
                              size: 14, color: AppColors.navy),
                          SizedBox(width: 6),
                          Text('Start talking',
                              style: TextStyle(
                                  color: AppColors.navy,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5)),
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
            color: AppColors.textSecondary),
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
      childAspectRatio: 2.05,
      children: [
        _FeatureTile(
          bg: AppColors.lavenderSoft,
          fg: AppColors.ideasAccent,
          icon: Icons.psychology_alt_outlined,
          title: 'Brain Dump',
          meta: '12 entries',
          onTap: () => onTab(NFTab.brainDumps),
        ),
        _FeatureTile(
          bg: AppColors.orangeSoft,
          fg: AppColors.tasksAccent,
          icon: Icons.checklist_rounded,
          title: 'Task Coach',
          meta: '3 active',
          onTap: () => onTab(NFTab.tasks),
        ),
        _FeatureTile(
          bg: AppColors.pinkSoft,
          fg: AppColors.worriesAccent,
          icon: Icons.favorite_outline_rounded,
          title: 'Check-in',
          meta: 'Via voice',
          onTap: () => onTab(NFTab.mic),
        ),
        _FeatureTile(
          bg: AppColors.creamSoft,
          fg: AppColors.creamAccent,
          icon: Icons.auto_awesome_outlined,
          title: 'Smart sort',
          meta: 'Auto-detect',
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
                  color: Colors.white.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: fg),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(meta,
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: fg)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  final String title, meta, time;
  final Color color, bg;
  final IconData icon;
  final VoidCallback onTap;

  const _RecentRow({
    required this.title,
    required this.meta,
    required this.time,
    required this.color,
    required this.bg,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                            height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(time,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary)),
            ],
          ),
        ),
      ),
    );
  }
}
