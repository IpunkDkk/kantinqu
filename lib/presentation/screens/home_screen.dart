import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/task_provider.dart';
import '../widgets/energy_chip_widget.dart';
import '../widgets/mindful_quote_widget.dart';
import '../widgets/plant_growth_widget.dart';
import '../widgets/task_card_widget.dart';
import 'add_task_sheet.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToProfile;

  const HomeScreen({
    super.key,
    required this.onNavigateToProfile,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  void _showSortSheet(BuildContext context, TaskProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Urutkan Tugas',
                    style: AppTypography.headlineSm,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule, color: AppColors.primary),
                    title: const Text('Berdasarkan Waktu Target',
                        style: AppTypography.bodyMd),
                    trailing: provider.currentSort == SortOption.time
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      provider.setSort(SortOption.time);
                      Navigator.pop(ctx);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.bolt, color: AppColors.highFocus),
                    title: const Text('Berdasarkan Tingkat Energi',
                        style: AppTypography.bodyMd),
                    trailing: provider.currentSort == SortOption.energy
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      provider.setSort(SortOption.energy);
                      Navigator.pop(ctx);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.check_circle_outline,
                        color: AppColors.relaxed),
                    title: const Text('Berdasarkan Status Penyelesaian',
                        style: AppTypography.bodyMd),
                    trailing: provider.currentSort == SortOption.status
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      provider.setSort(SortOption.status);
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.notifications_active,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Notifikasi Lembut', style: AppTypography.headlineSm),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🌱 Monstera Sejuk haus nutrisi! Siram sekarang untuk menjaga keindahan daunnya.',
              style: AppTypography.bodyMd,
            ),
            SizedBox(height: 12),
            Text(
              '⚡ Sesi Fokus Tinggi dijadwalkan pukul 14:00 WIB.',
              style: AppTypography.bodyMd,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: AppTypography.labelLg),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final user = provider.user;
    final gamification = provider.gamification;
    final tasks = provider.filteredTodayTasks;

    return Scaffold(
      backgroundColor: AppColors.backgroundCanvas,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar matching beranda_design.html header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest.withValues(alpha: 0.85),
                  border: const Border(
                    bottom: BorderSide(
                      color: AppColors.borderSubtle,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand / Logo + Pill
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.spa,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'MyPlan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryFixed.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Hari ini',
                                    style: AppTypography.labelSm.copyWith(
                                      color: AppColors.onPrimaryFixedVariant,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Beranda',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Actions: Notifications & Avatar
                    Row(
                      children: [
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined, size: 24),
                              color: AppColors.onSurfaceVariant,
                              onPressed: () => _showNotificationDialog(context),
                              tooltip: 'Notifikasi',
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: onNavigateToProfile,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryFixedDim,
                              border: Border.all(
                                color: AppColors.primaryContainer,
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              user.name.isNotEmpty ? user.name[0] : 'A',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onPrimaryContainer,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Main Content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Warm Greeting & Mindful Date Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  DateFormatter.formatFullDate(DateTime.now()),
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.highFocusContainerLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.highFocus,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Ritme Tenang',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.highFocus,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Greeting Title & Mindful Tagline
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${_getGreeting()}, ${user.name}',
                          style: AppTypography.headlineMd.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('✨', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Fokus pada apa yang penting hari ini tanpa terburu-buru.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Gamification Widget: Taman Pikiran
                  PlantGrowthWidget(
                    gamification: gamification,
                    completedToday: provider.todayCompletedCount,
                    totalToday: provider.todayTasksCount,
                    onWater: () async {
                      final success = await provider.waterPlant();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? '💧 Tanaman Monstera Sejuk disegarkan! (+20 XP)'
                                  : '🌱 Tanaman sudah disiram hari ini. Berikan waktu untuk tumbuh!',
                              style: AppTypography.bodyMd.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Energy Level Filter Chips
                  EnergyFilterBar(
                    activeFilter: provider.currentFilter,
                    totalCount: provider.todayTasksCount,
                    highCount: provider.todayHighFocusCount,
                    mediumCount: provider.todayMediumFocusCount,
                    relaxedCount: provider.todayRelaxedCount,
                    onFilterChanged: (filter) => provider.setFilter(filter),
                  ),
                  const SizedBox(height: 22),

                  // Tugas Hari Ini Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Flexible(
                              child: Text(
                                'Tugas Hari Ini',
                                style: AppTypography.headlineSm,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${provider.todayTasksCount} Total',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _showSortSheet(context, provider),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          child: Row(
                            children: [
                              Text(
                                'Urutkan',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.tune,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tasks List
                  if (tasks.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.borderSubtle,
                          width: 0.8,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 42,
                            color: AppColors.primaryContainer,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Tidak ada tugas pada filter ini',
                            style: AppTypography.labelLg,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gunakan tombol + untuk menambahkan tugas atau ubah filter energimu.',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: () {
                              AddTaskSheet.show(context);
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Tambah Tugas Baru'),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tasks.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return TaskCardWidget(
                          task: task,
                          onToggleComplete: () async {
                            final wasDone = task.isCompleted;
                            await provider.toggleTaskCompletion(task.id);
                            if (context.mounted && !wasDone) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.celebration,
                                          color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Tugas selesai! Kebunmu mendapatkan +50 XP 🌱',
                                          style: AppTypography.bodyMd.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TaskDetailScreen(taskId: task.id),
                              ),
                            );
                          },
                        );
                      },
                    ),

                  const SizedBox(height: 20),

                  // Mindful Quote / Reflection Pill
                  const MindfulQuoteWidget(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
