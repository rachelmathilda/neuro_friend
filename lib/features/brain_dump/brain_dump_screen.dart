import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../services/gemma_service.dart';

class BrainDumpScreen extends ConsumerStatefulWidget {
  const BrainDumpScreen({super.key});

  @override
  ConsumerState<BrainDumpScreen> createState() => _BrainDumpScreenState();
}

class _BrainDumpScreenState extends ConsumerState<BrainDumpScreen> {
  final _controller = TextEditingController();
  final _gemma = GemmaService();
  String _previousDump = '';
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _process() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isProcessing = true);

    try {
      final result = await _gemma.processBrainDump(_controller.text.trim());
      final tasks = (result['tasks'] as List<dynamic>? ?? []);

      for (final t in tasks) {
        final now = DateTime.now();
        await ref
            .read(taskProvider.notifier)
            .addTask(
              TaskModel(
                id: '${now.millisecondsSinceEpoch}_${t['title']}',
                title: t['title'] ?? '',
                category: TaskCategory.values.firstWhere(
                  (e) => e.name == (t['category'] ?? 'other'),
                  orElse: () => TaskCategory.other,
                ),
                status: TaskStatus.notYet,
                startTime: now,
                endTime: now.add(
                  Duration(minutes: (t['estimated_minutes'] ?? 30) as int),
                ),
                date: now,
              ),
            );
      }

      setState(() {
        _previousDump = _controller.text;
        _controller.clear();
      });

      if (mounted) Navigator.pop(context);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brain Dump'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_previousDump.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Text(_previousDump, style: AppTextStyles.bodyMedium),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => setState(() => _previousDump = ''),
                        child: const Icon(Icons.close, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            if (_previousDump.isNotEmpty) const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(hintText: 'Write something...'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isProcessing ? null : _process,
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Process'),
            ),
          ],
        ),
      ),
    );
  }
}
