import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/task_model.dart';
import '../../providers/task_provider.dart';
import '../widgets/task_card_widget.dart';
import 'add_task_sheet.dart';
import 'task_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _previousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final allTasks = provider.allTasks;
    final groupedTasks = provider.getGroupedTasksForDate(_selectedDate);
    final totalTasksOnDate = provider.getTasksForDate(_selectedDate).length;

    // Days in current week around selectedDate
    final monday =
        _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));

    final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Scaffold(
      backgroundColor: AppColors.backgroundCanvas,
      appBar: AppBar(
        title: const Text('Kalender & Linimasa',
            style: AppTypography.headlineSm),
        actions: [
          TextButton.icon(
            onPressed: _goToToday,
            icon: const Icon(Icons.today, size: 16),
            label: const Text('Hari Ini'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Weekly Calendar Strip
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                border: const Border(
                  bottom: BorderSide(
                    color: AppColors.borderSubtle,
                    width: 0.8,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Month navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _previousWeek,
                      ),
                      Text(
                        DateFormatter.formatFullDate(_selectedDate),
                        style: AppTypography.labelLg.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _nextWeek,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 7 Days row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (index) {
                      final day = weekDays[index];
                      final isSelected =
                          DateFormatter.isSameDay(day, _selectedDate);
                      final isToday =
                          DateFormatter.isSameDay(day, DateTime.now());

                      final hasTasks = allTasks.any((t) =>
                          DateFormatter.isSameDay(t.deadline, day));

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = day;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : (isToday
                                    ? AppColors.primaryContainer
                                        .withValues(alpha: 0.3)
                                    : Colors.transparent),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              Text(
                                dayNames[index],
                                style: AppTypography.labelSm.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${day.day}',
                                style: AppTypography.labelLg.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.onSurface,
                                  fontWeight: isSelected || isToday
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: hasTasks
                                      ? (isSelected
                                          ? AppColors.primaryContainer
                                          : AppColors.primary)
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          // Timeline Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Jadwal Tanggal Ini',
                      style: AppTypography.headlineSm.copyWith(fontSize: 18),
                    ),
                    Text(
                      '$totalTasksOnDate Tugas Terencana',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (totalTasksOnDate == 0)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.borderSubtle,
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.spa_outlined,
                          size: 40,
                          color: AppColors.primaryContainer,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Hari Tanpa Beban Jadwal',
                          style: AppTypography.labelLg,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Gunakan waktu luang ini untuk istirahat atau rencanakan tugas dengan tenang.',
                          style: AppTypography.bodySm,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            AddTaskSheet.show(context);
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Tambah Tugas di Tanggal Ini'),
                        ),
                      ],
                    ),
                  )
                else ...[
                  _buildTimeBlockSection(
                    context: context,
                    title: 'Pagi (06:00 - 12:00)',
                    icon: Icons.wb_sunny_outlined,
                    iconColor: AppColors.relaxedAccent,
                    tasks: groupedTasks['Pagi (06:00 - 12:00)'] ?? [],
                    provider: provider,
                  ),
                  const SizedBox(height: 20),
                  _buildTimeBlockSection(
                    context: context,
                    title: 'Siang & Sore (12:00 - 18:00)',
                    icon: Icons.wb_twilight,
                    iconColor: AppColors.highFocusAccent,
                    tasks: groupedTasks['Siang & Sore (12:00 - 18:00)'] ?? [],
                    provider: provider,
                  ),
                  const SizedBox(height: 20),
                  _buildTimeBlockSection(
                    context: context,
                    title: 'Malam (18:00 - 24:00)',
                    icon: Icons.nightlight_round_outlined,
                    iconColor: AppColors.primary,
                    tasks: groupedTasks['Malam (18:00 - 24:00)'] ?? [],
                    provider: provider,
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBlockSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Task> tasks,
    required TaskProvider provider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTypography.labelMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${tasks.length})',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (tasks.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.bedtime_outlined,
                    size: 16, color: AppColors.outline),
                const SizedBox(width: 8),
                Text(
                  'Waktu lapang atau fokus bebas',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCardWidget(
                task: task,
                onToggleComplete: () {
                  provider.toggleTaskCompletion(task.id);
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskDetailScreen(taskId: task.id),
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}
