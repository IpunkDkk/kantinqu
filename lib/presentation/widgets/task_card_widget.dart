import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/task_model.dart';

class TaskCardWidget extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleComplete;
  final VoidCallback onTap;

  const TaskCardWidget({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.isCompleted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.surfaceContainer.withValues(alpha: 0.65)
                : AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDone
                  ? Colors.transparent
                  : AppColors.borderSubtle.withValues(alpha: 0.7),
              width: 0.8,
            ),
            boxShadow: isDone
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox button
              GestureDetector(
                onTap: onToggleComplete,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2, right: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.primary
                          : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDone
                            ? AppColors.primary
                            : AppColors.outlineVariant.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                    child: isDone
                        ? const Icon(
                            Icons.check,
                            size: 18,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ),

              // Content Area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Energy Label & Schedule
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: task.energyLevel.badgeBgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              task.energyLevel.displayName,
                              style: AppTypography.labelSm.copyWith(
                                color: task.energyLevel.badgeTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isDone)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Selesai',
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.schedule,
                                  size: 14,
                                  color: AppColors.highFocus,
                                ),
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
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      task.title,
                      style: AppTypography.labelLg.copyWith(
                        fontSize: 15,
                        color: isDone
                            ? AppColors.textMuted
                            : AppColors.onSurface,
                        decoration:
                            isDone ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Subtasks progress bar (if any)
                    if (task.subtasks.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sub-tugas',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            task.subtaskProgressText,
                            style: AppTypography.labelSm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDone
                                  ? AppColors.primary
                                  : AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 5.5,
                          width: double.infinity,
                          child: Stack(
                            children: [
                              Container(
                                color: AppColors.surfaceContainer,
                              ),
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
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
