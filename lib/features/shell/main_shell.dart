import 'package:flutter/material.dart';
import '../../core/widgets/nf_tab_bar.dart';
import '../home/home_tab.dart';
import '../tasks/tasks_tab.dart';
import '../mic/mic_tab.dart';
import '../brain_dumps/brain_dumps_tab.dart';
import '../profile/profile_tab.dart';

class MainShell extends StatefulWidget {
  final NFTab initialTab;
  const MainShell({super.key, this.initialTab = NFTab.home});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late NFTab _active = widget.initialTab;

  void _onTab(NFTab t) => setState(() => _active = t);

  int get _index => NFTab.values.indexOf(_active);

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _index,
      children: [
        HomeTab(onTab: _onTab),
        TasksTab(onTab: _onTab),
        MicTab(onTab: _onTab),
        BrainDumpsTab(onTab: _onTab),
        ProfileTab(onTab: _onTab),
      ],
    );
  }
}
