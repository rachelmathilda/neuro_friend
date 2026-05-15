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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Brain Dump',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w100,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
                    Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: Text(
                        _previousDump,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => setState(() => _previousDump = ''),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_previousDump.isNotEmpty) const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 5,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Write something...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textHint,
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _process,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Process',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
