import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../core/widgets/bottom_nav.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Center(
                child: Text('Profile', style: AppTextStyles.titleLarge),
              ),
            ),
            const SizedBox(height: 16),
            Image.asset(
              'assets/images/mascot.png',
              height: 100,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.face, size: 80, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            authState.when(
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox(),
              data: (user) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.surfaceVariant,
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Full Name',
                          style: AppTextStyles.titleMedium,
                        ),
                        Text(
                          '@${user?.username ?? 'username'}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.butter,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user?.ndType.name.toUpperCase() ?? 'ADHD',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2,
                children: [
                  _RecapButton(
                    label: 'Scheduler\nRecap',
                    color: AppColors.moodHappy,
                    route: AppRoutes.schedulerRecap,
                  ),
                  _RecapButton(
                    label: 'Focus\nCheck-in Recap',
                    color: AppColors.moodAnxious,
                    route: AppRoutes.focusRecap,
                  ),
                  _RecapButton(
                    label: 'Social\nScript Recap',
                    color: AppColors.tagSensory,
                    route: AppRoutes.socialScriptRecap,
                  ),
                  _RecapButton(
                    label: 'Sensory\nRecap',
                    color: AppColors.moodAngry,
                    route: AppRoutes.sensoryRecap,
                  ),
                ],
              ),
            ),
            const Spacer(),
            BottomNav(currentIndex: 4),
          ],
        ),
      ),
    );
  }
}

class _RecapButton extends StatelessWidget {
  final String label;
  final Color color;
  final String route;

  const _RecapButton({
    required this.label,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
