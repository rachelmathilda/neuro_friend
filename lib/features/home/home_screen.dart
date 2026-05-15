import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/bottom_nav.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
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
                        const SizedBox(height: 48),
                        _MoodBar(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                BottomNav(currentIndex: 0),
              ],
            ),
          ),

          const _PanicFab(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.butter,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(70),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good Morning', style: AppTextStyles.titleMedium),
              Text(
                "User's name",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
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
    return Image.asset('assets/images/mascot.png', height: 210);
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
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 26),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F2F0),
        borderRadius: BorderRadius.circular(28),
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
        const SizedBox(height: 12),
        Container(
          width: 70,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
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

class _PanicFab extends StatefulWidget {
  const _PanicFab();

  @override
  State<_PanicFab> createState() => _PanicFabState();
}

class _PanicFabState extends State<_PanicFab> {
  double top = 650;
  double left = 250;

  static const double fabWidth = 110;
  static const double fabHeight = 56;
  static const double screenPadding = 24;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            left += details.delta.dx;
            top += details.delta.dy;

            final maxLeft = screenSize.width - fabWidth - screenPadding;

            final maxTop = screenSize.height - fabHeight - screenPadding;

            if (left < screenPadding) {
              left = screenPadding;
            }

            if (top < screenPadding) {
              top = screenPadding;
            }

            if (left > maxLeft) {
              left = maxLeft;
            }

            if (top > maxTop) {
              top = maxTop;
            }
          });
        },
        child: SizedBox(
          width: fabWidth,
          height: fabHeight,
          child: FloatingActionButton.extended(
            onPressed: () {},
            backgroundColor: AppColors.primary,
            label: const Text('SOS', style: TextStyle(color: Colors.white)),
            icon: const Icon(Icons.favorite_border, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
