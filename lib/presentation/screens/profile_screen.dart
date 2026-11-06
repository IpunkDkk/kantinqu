import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/task_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, TaskProvider provider) {
    final user = provider.user;
    final nameCtrl = TextEditingController(text: user.name);
    final titleCtrl = TextEditingController(text: user.title);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ubah Profil Pengguna', style: AppTypography.headlineSm),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nama Panggilan', style: AppTypography.labelMd),
            const SizedBox(height: 6),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                hintText: 'Nama kamu',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Gelar / Peran Produktivitas', style: AppTypography.labelMd),
            const SizedBox(height: 6),
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                hintText: 'cth: Penanam Sadar (Mindful Planter)',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameCtrl.text.trim();
              final newTitle = titleCtrl.text.trim();
              if (newName.isNotEmpty) {
                provider.updateUser(
                  user.copyWith(
                    name: newName,
                    title: newTitle.isNotEmpty ? newTitle : user.title,
                  ),
                );
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Muat Ulang Data Awal?', style: AppTypography.headlineSm),
        content: const Text(
          'Tindakan ini akan mengembalikan tugas dan status ke data demonstrasi standar MyPlan.',
          style: AppTypography.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.resetToMockData();
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data berhasil dimuat ulang ke demonstrasi awal.'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimaryContainer,
            ),
            child: const Text('Muat Ulang'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final user = provider.user;
    final game = provider.gamification;

    return Scaffold(
      backgroundColor: AppColors.backgroundCanvas,
      appBar: AppBar(
        title: const Text('Profil Pengguna', style: AppTypography.headlineSm),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang Data Awal',
            onPressed: () => _showResetDialog(context, provider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryFixedDim,
                      border: Border.all(
                        color: AppColors.primaryContainer,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0] : 'A',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: AppTypography.headlineSm.copyWith(fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.title,
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: AppColors.primary,
                    onPressed: () => _showEditProfileDialog(context, provider),
                    tooltip: 'Ubah Profil',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Plant Garden & Gamification Hub Card
            const Text('Kebun Tenang & Gamifikasi', style: AppTypography.labelLg),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_florist,
                          color: AppColors.primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              game.plantName,
                              style: AppTypography.labelLg.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Level ${game.plantLevel} • Pertumbuhan Kebun Mindful',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${game.currentXp}/${game.xpNeededForNextLevel} XP',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.onPrimaryFixedVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: game.growthProgress,
                      backgroundColor: AppColors.surfaceContainerLow,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${game.currentStreak} Hari Beruntun',
                                    style: AppTypography.labelMd.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Rekor: ${game.highestStreak} Hari',
                                    style: AppTypography.bodySm.copyWith(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: game.isWateredToday
                            ? null
                            : () => provider.waterPlant(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.surfaceContainerLow,
                          disabledForegroundColor: AppColors.textMuted,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          game.isWateredToday ? Icons.check_circle : Icons.water_drop,
                          size: 16,
                        ),
                        label: Text(
                          game.isWateredToday ? 'Sudah Disiram' : 'Siram (+20 XP)',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Achievement Badges
            const Text('Lencana Pencapaian', style: AppTypography.labelLg),
            const SizedBox(height: 4),
            Text(
              'Apresiasi konsistensi dan kesadaran dalam bekerja.',
              style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.1,
              children: [
                _buildBadgeCard(
                  title: 'Langkah Mikro',
                  desc: 'Pecah 10+ tugas kecil',
                  icon: '🌱',
                  isUnlocked: true,
                ),
                _buildBadgeCard(
                  title: 'Rawat Kebun',
                  desc: 'Siram 7 hari beruntun',
                  icon: '💧',
                  isUnlocked: game.currentStreak >= 7,
                ),
                _buildBadgeCard(
                  title: 'Fokus Mendalam',
                  desc: 'Selesaikan Deep Work',
                  icon: '⚡',
                  isUnlocked: true,
                ),
                _buildBadgeCard(
                  title: 'Ritme Harmonis',
                  desc: 'Keseimbangan bio-ritme',
                  icon: '🧘',
                  isUnlocked: true,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Preferences & Sound Settings
            const Text('Pengaturan & Preferensi', style: AppTypography.labelLg),
            const SizedBox(height: 10),
            Material(
              color: AppColors.surfaceRaised,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.borderSubtle, width: 0.8),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Pengingat Lembut',
                        style: AppTypography.labelMd),
                    subtitle: Text(
                      '${user.reminderSound} (Chime mindful)',
                      style: AppTypography.bodySm,
                    ),
                    secondary: const Icon(Icons.music_note,
                        color: AppColors.primary),
                    value: user.enableGentleReminders,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primaryContainer,
                    onChanged: (val) {
                      provider.updateUser(
                        user.copyWith(enableGentleReminders: val),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.timer_outlined,
                        color: AppColors.relaxed),
                    title: const Text('Durasi Timer Fokus Standar',
                        style: AppTypography.labelMd),
                    subtitle: const Text('25 Menit (Siklus Pomodoro Sadar)',
                        style: AppTypography.bodySm),
                    trailing: const Text(
                      '25 mnt',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline,
                        color: AppColors.primary),
                    title: const Text('Tentang MyPlan',
                        style: AppTypography.labelMd),
                    subtitle: const Text(
                      'Manajemen Tugas Berbasis Psikologi Produktivitas v1.0',
                      style: AppTypography.bodySm,
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'MyPlan',
                        applicationVersion: '1.0.0',
                        applicationLegalese:
                            'Aplikasi Manajemen Tugas dengan Pendekatan Psikologi Produktivitas.',
                        children: const [
                          SizedBox(height: 12),
                          Text(
                            'Membantu mengelola energi mental, memecah tugas kompleks menjadi langkah mikro, dan menjaga ritme kerja dengan gamifikasi tanaman virtual.',
                            style: AppTypography.bodySm,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeCard({
    required String title,
    required String desc,
    required String icon,
    required bool isUnlocked,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppColors.surfaceRaised
            : AppColors.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked
              ? AppColors.primary.withValues(alpha: 0.25)
              : AppColors.borderSubtle,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.primaryFixed.withValues(alpha: 0.5)
                  : AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              icon,
              style: TextStyle(
                fontSize: 16,
                color: isUnlocked ? null : Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isUnlocked
                        ? AppColors.onSurface
                        : AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  desc,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 9.5,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
