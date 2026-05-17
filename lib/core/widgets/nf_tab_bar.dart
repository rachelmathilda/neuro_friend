import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum NFTab { home, tasks, mic, brainDumps, profile }

class NFTabBar extends StatelessWidget {
  final NFTab active;
  final ValueChanged<NFTab> onTab;

  const NFTabBar({super.key, required this.active, required this.onTab});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (NFTab.home, Icons.home_rounded),
      (NFTab.tasks, Icons.calendar_today_rounded),
      (NFTab.mic, Icons.mic_rounded),
      (NFTab.brainDumps, Icons.access_time_rounded),
      (NFTab.profile, Icons.person_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1C2440).withOpacity(0.10),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: const Color(0xFF1C2440).withOpacity(0.04),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final (tab, icon) in tabs)
              _TabItem(
                icon: icon,
                isActive: tab == active,
                onTap: () => onTab(tab),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 46,
        height: 46,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isActive)
              Container(
                margin: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                ),
              ),
            Icon(
              icon,
              size: 22,
              color: isActive ? AppColors.navy : const Color(0xFF9BA3BF),
            ),
          ],
        ),
      ),
    );
  }
}
