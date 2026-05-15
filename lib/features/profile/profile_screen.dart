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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Text(
              'Profile',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w100,
              ),
            ),

            const SizedBox(height: 28),

            Image.asset('assets/images/mascot.png', height: 170),

            const SizedBox(height: 28),

            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(28),
              ),
              child: authState.when(
                loading: () => const SizedBox(
                  height: 82,
                  child: Center(child: CircularProgressIndicator()),
                ),

                error: (_, __) => _ProfileContent(
                  name: 'Full Name',
                  username: 'username',
                  ndType: 'ADHD',
                ),

                data: (user) => _ProfileContent(
                  name: user?.name ?? 'Full Name',
                  username: user?.username ?? 'username',
                  ndType: user?.ndType.name.toUpperCase() ?? 'ADHD',
                ),
              ),
            ),

            const SizedBox(height: 32),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(28),
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 18,
                childAspectRatio: 1.45,
                children: [
                  _RecapButton(
                    label: 'Scheduler\nRecap',
                    color: AppColors.moodHappy,
                    route: AppRoutes.schedulerRecap,
                  ),
                  _RecapButton(
                    label: 'Focus\nCheck-in\nRecap',
                    color: AppColors.moodAnxious,
                    route: AppRoutes.focusRecap,
                  ),
                  _RecapButton(
                    label: 'Social\nScript\nRecap',
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
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w100,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final String name;
  final String username;
  final String ndType;

  const _ProfileContent({
    required this.name,
    required this.username,
    required this.ndType,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/avatar.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.person,
                  size: 36,
                  color: Colors.black54,
                );
              },
            ),
          ),
        ),

        const SizedBox(width: 18),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w200,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                '@$username',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),

        _ProfileTypeDropdown(initialValue: ndType),
      ],
    );
  }
}

class _ProfileTypeDropdown extends StatefulWidget {
  final String initialValue;

  const _ProfileTypeDropdown({required this.initialValue});

  @override
  State<_ProfileTypeDropdown> createState() => _ProfileTypeDropdownState();
}

class _ProfileTypeDropdownState extends State<_ProfileTypeDropdown> {
  late String selected;

  final List<String> items = ['ADHD', 'Autism', 'TBI', 'Alzheimer'];

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.butter,
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
          borderRadius: BorderRadius.circular(16),
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.black,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: Colors.white,
          items: items.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Text(
                e,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  color: Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              selected = value;
            });
          },
        ),
      ),
    );
  }
}
