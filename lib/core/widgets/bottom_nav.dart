import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            index: 0,
            current: currentIndex,
            route: AppRoutes.home,
          ),
          _NavItem(
            icon: Icons.calendar_today_outlined,
            index: 1,
            current: currentIndex,
            route: AppRoutes.todos,
          ),
          _NavItem(
            icon: Icons.mic_outlined,
            index: 2,
            current: currentIndex,
            route: AppRoutes.aiVoice,
          ),
          _NavItem(
            icon: Icons.access_time_outlined,
            index: 3,
            current: currentIndex,
            route: AppRoutes.appUsage,
          ),
          _NavItem(
            icon: Icons.person_outline,
            index: 4,
            current: currentIndex,
            route: AppRoutes.profile,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final int current;
  final String route;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.current,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;

    return GestureDetector(
      onTap: () {
        if (!isActive) Navigator.pushNamed(context, route);
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? AppColors.butter : Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          size: 24,
        ),
      ),
    );
  }
}
