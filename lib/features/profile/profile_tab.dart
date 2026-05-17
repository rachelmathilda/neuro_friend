import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/nf_mascot.dart';
import '../../core/widgets/nf_screen.dart';
import '../../core/widgets/nf_tab_bar.dart';

class _Stat {
  final String label;
  final int value;
  final Color color, bg;
  const _Stat(this.label, this.value, this.color, this.bg);
}

const _stats = [
  _Stat('Voice sessions', 38, AppColors.blue, AppColors.blueSoft),
  _Stat('Brain dumps', 12, AppColors.ideasAccent, AppColors.lavenderSoft),
  _Stat('Tasks completed', 24, AppColors.greenAccent, AppColors.greenSoft),
];

class ProfileTab extends StatelessWidget {
  final ValueChanged<NFTab> onTab;
  const ProfileTab({super.key, required this.onTab});

  @override
  Widget build(BuildContext context) {
    return NFScreen(
      tabActive: NFTab.profile,
      onTab: onTab,
      background: AppColors.bgSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 16),
            child: Text('Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: AppColors.textPrimary)),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1C2440).withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: AppColors.cream,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: const Center(child: NFMascot(size: 68)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Riana Park',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      const Text('@rianapark',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.lavenderSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text('ADHD · diagnosed 2023',
                            style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ideasAccent)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < _stats.length; i++) ...[
                Expanded(child: _StatTile(stat: _stats[i])),
                if (i < _stats.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 18),
          const Text('Settings',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: const [
                    _SettingRow(
                      icon: Icons.notifications_outlined,
                      iconColor: AppColors.navy,
                      label: 'Notifications',
                      hint: 'Daily reminders',
                    ),
                    _SettingRow(
                      icon: Icons.auto_awesome_outlined,
                      iconColor: AppColors.blue,
                      label: 'AI language',
                      hint: 'English',
                    ),
                    _SettingRow(
                      icon: Icons.favorite_outline_rounded,
                      iconColor: AppColors.worriesAccent,
                      label: 'Wellbeing',
                      hint: 'Daily tips',
                    ),
                    _SettingRow(
                      icon: Icons.settings_outlined,
                      iconColor: AppColors.textSecondary,
                      label: 'About',
                      last: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final _Stat stat;
  const _StatTile({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration:
          BoxDecoration(color: stat.bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text('${stat.value}',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  color: stat.color)),
          const SizedBox(height: 5),
          Text(stat.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: stat.color)),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? hint;
  final bool last;
  const _SettingRow(
      {required this.icon,
      required this.iconColor,
      required this.label,
      this.hint,
      this.last = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: last ? Colors.transparent : AppColors.border,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.bgSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  if (hint != null) ...[
                    const SizedBox(height: 1),
                    Text(hint!,
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary, size: 22),
          ],
        ),
      ),
    );
  }
}
