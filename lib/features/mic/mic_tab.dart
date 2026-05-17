import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/nf_mascot.dart';
import '../../core/widgets/nf_mic_button.dart';
import '../../core/widgets/nf_screen.dart';
import '../../core/widgets/nf_tab_bar.dart';

class MicTab extends StatelessWidget {
  final ValueChanged<NFTab> onTab;
  const MicTab({super.key, required this.onTab});

  @override
  Widget build(BuildContext context) {
    return NFScreen(
      tabActive: NFTab.mic,
      onTab: onTab,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TopBar(),
          const Spacer(),
          Center(
            child: Column(
              children: [
                const NFMascot(size: 132),
                const SizedBox(height: 14),
                const Text('Neuro Friend',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: AppColors.textPrimary,
                    )),
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: const Text(
                    "Speak about anything. I'll listen and help.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                NFMicButton(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.listening),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Text(
                    'Tap to start talking',
                    style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Pip(
                      icon: Icons.psychology_alt_outlined,
                      iconColor: AppColors.navy,
                      bg: AppColors.lavenderSoft,
                      label: 'Brain dump',
                    ),
                    SizedBox(width: 28),
                    _Pip(
                      icon: Icons.favorite_outline_rounded,
                      iconColor: AppColors.worriesAccent,
                      bg: AppColors.pinkSoft,
                      label: 'Check-in',
                    ),
                    SizedBox(width: 28),
                    _Pip(
                      icon: Icons.checklist_rounded,
                      iconColor: AppColors.tasksAccent,
                      bg: AppColors.orangeSoft,
                      label: 'Task coach',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Auto-detect — no need to pick',
                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Good morning,',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                SizedBox(height: 2),
                Text('Hi, friend',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                color: AppColors.cream, shape: BoxShape.circle),
            child: const Icon(Icons.notifications_outlined,
                size: 18, color: AppColors.navy),
          ),
        ],
      ),
    );
  }
}

class _Pip extends StatelessWidget {
  final IconData icon;
  final Color iconColor, bg;
  final String label;
  const _Pip({required this.icon, required this.iconColor, required this.bg, required this.label});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.85,
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
