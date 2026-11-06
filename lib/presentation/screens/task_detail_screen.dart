import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/task_provider.dart';
import 'add_task_sheet.dart';
import 'focus_timer_dialog.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TextEditingController _newSubtaskController = TextEditingController();
  bool _isAddingSubtask = false;

  @override
  void dispose() {
    _newSubtaskController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Tugas?', style: AppTypography.headlineSm),
        content: const Text(
          'Apakah kamu yakin ingin menghapus tugas ini? Tindakan ini tidak dapat dibatalkan.',
          style: AppTypography.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteTask(widget.taskId);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close detail screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorContainer,
              foregroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showCelebrationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Luar Biasa, Semua Selesai!',
                style: AppTypography.headlineSm,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Seluruh langkah mikro telah tuntas. Pikiranmu semakin tenang dan tanaman Monstera Sejuk bertambah subur! (+50 XP)',
                style: AppTypography.bodyMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Lanjutkan Ritme Hari'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final task = provider.findTaskById(widget.taskId);

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Tugas')),
        body: const Center(
          child: Text('Tugas tidak ditemukan atau telah dihapus.'),
        ),
      );
    }

    final isDone = task.isCompleted;

    return Scaffold(
      backgroundColor: AppColors.backgroundCanvas,
      appBar: AppBar(
        title: const Text('Detail Tugas', style: AppTypography.headlineSm),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Ubah Tugas',
            onPressed: () {
              AddTaskSheet.show(context, taskToEdit: task);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Hapus Tugas',
            onPressed: () => _showDeleteDialog(context, provider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Energy badge header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: task.energyLevel.badgeBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(task.energyLevel.icon,
                          size: 16, color: task.energyLevel.badgeTextColor),
                      const SizedBox(width: 6),
                      Text(
                        task.energyLevel.displayName,
                        style: AppTypography.labelMd.copyWith(
                          color: task.energyLevel.badgeTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.primaryContainer
                        : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDone ? Icons.check_circle : Icons.pending_outlined,
                        size: 15,
                        color: isDone
                            ? AppColors.onPrimaryContainer
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isDone ? 'Selesai' : 'Belum Selesai',
                        style: AppTypography.labelSm.copyWith(
                          color: isDone
                              ? AppColors.onPrimaryContainer
                              : AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Task Title
            Text(
              task.title,
              style: AppTypography.headlineLg.copyWith(
                fontSize: 22,
                color: isDone ? AppColors.textMuted : AppColors.onSurface,
                decoration: isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 16),

            // Niat Hari Ini / Mindful Intention Card
            if (task.intention.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryContainer.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.self_improvement,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'NIAT HARI INI',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.intention,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Schedule & Focus Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderSubtle, width: 0.8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          DateFormatter.formatFullDate(task.deadline),
                          style: AppTypography.labelMd.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule,
                              size: 16, color: AppColors.highFocus),
                          const SizedBox(width: 4),
                          Text(
                            task.targetTime,
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.highFocus,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.timer,
                                size: 18, color: AppColors.relaxed),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${task.durationMinutes} Menit (${(task.durationMinutes / 25).round().clamp(1, 4)} Blok)',
                                style: AppTypography.bodySm,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          FocusTimerDialog.show(context, task);
                        },
                        icon: const Icon(Icons.play_circle_filled, size: 16),
                        label: const Text('Mulai Sesi'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: AppColors.onPrimaryContainer,
                          textStyle: AppTypography.labelSm
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sub-tasks Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text('Langkah Mikro (Sub-tugas)',
                      style: AppTypography.labelLg),
                ),
                const SizedBox(width: 8),
                Text(
                  task.subtaskProgressText,
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 6,
                width: double.infinity,
                child: Stack(
                  children: [
                    Container(color: AppColors.surfaceContainer),
                    FractionallySizedBox(
                      widthFactor: task.progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDone
                              ? AppColors.primary
                              : AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Subtasks checklist
            if (task.subtasks.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                ),
                child: const Center(
                  child: Text(
                    'Belum ada langkah mikro untuk tugas ini.',
                    style: AppTypography.bodySm,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: task.subtasks.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final sub = task.subtasks[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: AppColors.borderSubtle, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final wasDone = task.isCompleted;
                            await provider.toggleSubtaskCompletion(
                                task.id, sub.id);
                            final updatedTask =
                                provider.findTaskById(task.id);
                            if (context.mounted &&
                                !wasDone &&
                                updatedTask != null &&
                                updatedTask.isCompleted) {
                              _showCelebrationSheet(context);
                            }
                          },
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: sub.isCompleted
                                  ? AppColors.primary
                                  : AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: sub.isCompleted
                                    ? AppColors.primary
                                    : AppColors.outlineVariant,
                                width: 1.2,
                              ),
                            ),
                            child: sub.isCompleted
                                ? const Icon(Icons.check,
                                    size: 15, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            sub.title,
                            style: AppTypography.bodyMd.copyWith(
                              color: sub.isCompleted
                                  ? AppColors.textMuted
                                  : AppColors.onSurface,
                              decoration: sub.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          color: AppColors.outlineVariant,
                          onPressed: () {
                            provider.deleteSubtask(task.id, sub.id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 12),

            // Add subtask inline input
            if (_isAddingSubtask)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newSubtaskController,
                      autofocus: true,
                      style: AppTypography.bodySm,
                      decoration: InputDecoration(
                        hintText: 'Ketik langkah mikro baru...',
                        filled: true,
                        fillColor: AppColors.surfaceRaised,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.borderSubtle),
                        ),
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          provider.addSubtask(task.id, val.trim());
                          _newSubtaskController.clear();
                          setState(() => _isAddingSubtask = false);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.check, color: AppColors.primary),
                    onPressed: () {
                      final val = _newSubtaskController.text.trim();
                      if (val.isNotEmpty) {
                        provider.addSubtask(task.id, val);
                        _newSubtaskController.clear();
                        setState(() => _isAddingSubtask = false);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.outline),
                    onPressed: () {
                      setState(() {
                        _isAddingSubtask = false;
                        _newSubtaskController.clear();
                      });
                    },
                  ),
                ],
              )
            else
              TextButton.icon(
                onPressed: () => setState(() => _isAddingSubtask = true),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah langkah mikro'),
              ),

            const SizedBox(height: 32),

            // Big Toggle Complete / Uncomplete Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final wasDone = task.isCompleted;
                  await provider.toggleTaskCompletion(task.id);
                  if (context.mounted && !wasDone) {
                    _showCelebrationSheet(context);
                  }
                },
                icon: Icon(
                  isDone ? Icons.undo : Icons.check_circle,
                  color: isDone ? AppColors.onSurface : Colors.white,
                ),
                label: Text(
                  isDone ? 'Tandai Belum Selesai' : 'Tandai Selesai (+50 XP)',
                  style: TextStyle(
                    color: isDone ? AppColors.onSurface : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDone ? AppColors.surfaceContainer : AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
