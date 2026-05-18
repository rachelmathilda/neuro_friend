import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/nf_mascot.dart';
import '../../core/widgets/nf_screen.dart';
import '../../core/widgets/nf_tab_bar.dart';
import '../../data/repositories/brain_dump_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/focus_repository.dart';
import '../../services/user_prefs_service.dart';

class ProfileTab extends StatefulWidget {
  final ValueChanged<NFTab> onTab;
  const ProfileTab({super.key, required this.onTab});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _name = 'friend';
  int _voiceSessions = 0;
  int _brainDumps = 0;
  int _tasksCompleted = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        UserPrefsService.getName(),
        FocusRepository().fetchRecent(days: 365),
        BrainDumpRepository().fetchRecent(limit: 100),
        TaskRepository().fetchWeeklyStats(),
      ]);
      if (mounted) {
        setState(() {
          _name = results[0] as String;
          _voiceSessions = (results[1] as List).length;
          _brainDumps = (results[2] as List).length;
          _tasksCompleted = (results[3] as Map<String, int>)['done'] ?? 0;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NFScreen(
      tabActive: NFTab.profile,
      onTab: widget.onTab,
      background: AppColors.bgSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 16),
            child: Text(
              'Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1C2440).withValues(alpha: 0.05),
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
                      _loading
                          ? const SizedBox(
                              height: 16,
                              width: 100,
                              child: LinearProgressIndicator(),
                            )
                          : Text(
                              _name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lavenderSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Neuro Friend user',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ideasAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showEditName(context),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Voice sessions',
                  value: _loading ? 0 : _voiceSessions,
                  color: AppColors.blue,
                  bg: AppColors.blueSoft,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(
                  label: 'Brain dumps',
                  value: _loading ? 0 : _brainDumps,
                  color: AppColors.ideasAccent,
                  bg: AppColors.lavenderSoft,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(
                  label: 'Tasks done',
                  value: _loading ? 0 : _tasksCompleted,
                  color: AppColors.greenAccent,
                  bg: AppColors.greenSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
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

  void _showEditName(BuildContext context) {
    final controller = TextEditingController(text: _name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                filled: true,
                fillColor: AppColors.bgSoft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  final newName = controller.text.trim();
                  if (newName.isEmpty) return;
                  await UserPrefsService.setName(newName);
                  if (mounted) setState(() => _name = newName);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final Color color, bg;
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: color,
            ),
          ),
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
  const _SettingRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.hint,
    this.last = false,
  });

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
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (hint != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      hint!,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
