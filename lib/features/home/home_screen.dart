import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../brain_dump/brain_dump_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _Mascot(),
                    const SizedBox(height: 32),
                    _MoodBar(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _BottomNav(currentIndex: 0),
          ],
        ),
      ),
      floatingActionButton: _PanicFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: const BoxDecoration(
        color: AppColors.butter,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good Morning', style: AppTextStyles.titleMedium),
              Text("User's name", style: AppTextStyles.headlineSmall),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _Mascot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Center(
        child: Image.asset(
          'assets/images/mascot.png',
          height: 160,
          errorBuilder: (_, __, ___) => const _MascotPlaceholder(),
        ),
      ),
    );
  }
}

class _MascotPlaceholder extends StatelessWidget {
  const _MascotPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.face, size: 64, color: Colors.white),
    );
  }
}

class _MoodBar extends StatefulWidget {
  @override
  State<_MoodBar> createState() => _MoodBarState();
}

class _MoodBarState extends State<_MoodBar> {
  int? _selected;

  final List<_MoodItem> _moods = const [
    _MoodItem('Happy', AppColors.moodHappy, 0.75),
    _MoodItem('Calm', AppColors.moodCalm, 0.85),
    _MoodItem('Angry', AppColors.moodAngry, 0.35),
    _MoodItem('Anxious', AppColors.moodAnxious, 0.60),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_moods.length, (i) {
          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: _MoodColumn(mood: _moods[i], isSelected: _selected == i),
          );
        }),
      ),
    );
  }
}

class _MoodItem {
  final String label;
  final Color color;
  final double fillRatio;
  const _MoodItem(this.label, this.color, this.fillRatio);
}

class _MoodColumn extends StatelessWidget {
  final _MoodItem mood;
  final bool isSelected;

  const _MoodColumn({required this.mood, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(mood.label, style: AppTextStyles.bodySmall),
        const SizedBox(height: 8),
        Container(
          width: 56,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(30),
            border: isSelected ? Border.all(color: mood.color, width: 2) : null,
          ),
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: mood.fillRatio,
            child: Container(
              decoration: BoxDecoration(
                color: mood.color,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PanicFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {},
      backgroundColor: AppColors.primary,
      label: const Text('SOS', style: TextStyle(color: Colors.white)),
      icon: const Icon(Icons.favorite_border, color: Colors.white),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

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
            color: Colors.black.withOpacity(0.06),
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
            isCentre: true,
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
  final bool isCentre;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.current,
    required this.route,
    this.isCentre = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;

    if (isCentre) {
      return GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.butter,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 26),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (!isActive) Navigator.pushNamed(context, route);
      },
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: isActive ? AppColors.primary : AppColors.textSecondary,
          size: 24,
        ),
      ),
    );
  }
}
