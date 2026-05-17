import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'nf_tab_bar.dart';

/// Phone-shell scaffold: content area with horizontal padding,
/// optional floating tab bar at the bottom.
class NFScreen extends StatelessWidget {
  final Widget child;
  final Color background;
  final NFTab? tabActive;
  final ValueChanged<NFTab>? onTab;
  final bool hideTabs;
  final EdgeInsets? padding;

  const NFScreen({
    super.key,
    required this.child,
    this.background = AppColors.bg,
    this.tabActive,
    this.onTab,
    this.hideTabs = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topInset = mq.padding.top;
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: topInset + 12,
                left: 22,
                right: 22,
                bottom: hideTabs ? mq.padding.bottom : 110,
              ),
              child: Padding(
                padding: padding ?? EdgeInsets.zero,
                child: child,
              ),
            ),
          ),
          if (!hideTabs && tabActive != null && onTab != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: mq.padding.bottom,
              child: NFTabBar(active: tabActive!, onTab: onTab!),
            ),
        ],
      ),
    );
  }
}

/// Standard back-arrow + centered title header.
class NFHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final bool italic;

  const NFHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.italic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onBack ?? () => Navigator.maybePop(context),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.arrow_back_rounded,
                  size: 22, color: AppColors.navy),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 28),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.1,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.45,
                          fontStyle:
                              italic ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
