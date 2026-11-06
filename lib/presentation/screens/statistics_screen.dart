import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/energy_level.dart';
import '../../providers/task_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final user = provider.user;
    final game = provider.gamification;
    final weeklyData = provider.weeklyCompletionData;
    final distribution = provider.energyDistribution;

    return Scaffold(
      backgroundColor: AppColors.backgroundCanvas,
      appBar: AppBar(
        title: const Text('Statistik Produktivitas', style: AppTypography.headlineSm),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, size: 14, color: AppColors.onPrimaryContainer),
                const SizedBox(width: 4),
                Text(
                  'Minggu Ini',
                  style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mindful Overview Banner
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.energy_savings_leaf,
                      color: AppColors.onPrimaryFixedVariant,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Evaluasi Ritme & Fokus',
                          style: AppTypography.labelLg.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Keseimbangan energi kognitif & produktivitas sadar tanpa burnout.',
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
            const SizedBox(height: 20),

            // Metrics Summary Grid (4 Cards)
            const Text('Ringkasan Fokus', style: AppTypography.labelLg),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Jam Fokus',
                    value: '${user.focusHoursThisWeek} Jam',
                    icon: '⏳',
                    subtitle: 'Total minggu ini',
                    bgColor: AppColors.highFocusContainerLight,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Tugas Selesai',
                    value: '${game.completedTasksCount}',
                    icon: '✨',
                    subtitle: 'Pencapaian tugas',
                    bgColor: AppColors.surfaceContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Streak Harian',
                    value: '${game.currentStreak} Hari',
                    icon: '🔥',
                    subtitle: 'Konsistensi aktif',
                    bgColor: AppColors.relaxedContainerLight,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Kesehatan Ritme',
                    value: '94%',
                    icon: '🌿',
                    subtitle: 'Beban seimbang',
                    bgColor: AppColors.primaryFixed.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Weekly Productivity Chart
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Grafik Produktivitas Mingguan',
                    style: AppTypography.labelLg),
                Text(
                  '${weeklyData.reduce((a, b) => a + b).toInt()} Tugas Selesai',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 140,
                    child: _WeeklyBarChart(values: weeklyData),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.psychology,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pola kerjamu paling optimal di hari Selasa & Rabu.',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cognitive Load Balance Breakdown
            const Text('Keseimbangan Beban Kognitif',
                style: AppTypography.labelLg),
            const SizedBox(height: 4),
            Text(
              'Menjaga proporsi energi mental untuk mencegah kelelahan otak.',
              style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle, width: 0.8),
              ),
              child: Column(
                children: [
                  _buildEnergyBar(
                    label: EnergyLevel.high.displayName,
                    ratio: distribution[EnergyLevel.high] ?? 0.33,
                    color: AppColors.highFocus,
                  ),
                  const SizedBox(height: 10),
                  _buildEnergyBar(
                    label: EnergyLevel.medium.displayName,
                    ratio: distribution[EnergyLevel.medium] ?? 0.33,
                    color: AppColors.mediumFocus,
                  ),
                  const SizedBox(height: 10),
                  _buildEnergyBar(
                    label: EnergyLevel.relaxed.displayName,
                    ratio: distribution[EnergyLevel.relaxed] ?? 0.34,
                    color: AppColors.relaxedAccent,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡 ', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Text(
                            'Proporsi energimu seimbang. Mengalokasikan 30-40% tugas pada Fokus Tinggi menjaga ketajaman konsentrasi tanpa risiko burnout.',
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Golden Focus Hours
            const Text('Jendela Emas Fokus Harian', style: AppTypography.labelLg),
            const SizedBox(height: 4),
            Text(
              'Waktu terbaik otak dalam memproses tugas sesuai ritme biologis.',
              style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle, width: 0.8),
              ),
              child: Column(
                children: [
                  _buildTimeWindowTile(
                    time: '08:30 - 11:30',
                    title: 'Pagi (Puncak Kognitif)',
                    desc: 'Optimal untuk Deep Work & Analisis Kompleks',
                    badge: 'Fokus Tajam',
                    badgeColor: AppColors.highFocusContainer,
                    badgeTextColor: AppColors.onHighFocusContainer,
                  ),
                  const Divider(height: 20),
                  _buildTimeWindowTile(
                    time: '13:00 - 15:30',
                    title: 'Siang (Ritme Teratur)',
                    desc: 'Ideal untuk Kolaborasi, Diskusi & Eksekusi',
                    badge: 'Sedang',
                    badgeColor: AppColors.surfaceContainer,
                    badgeTextColor: AppColors.onSurfaceVariant,
                  ),
                  const Divider(height: 20),
                  _buildTimeWindowTile(
                    time: '16:00 - 17:30',
                    title: 'Sore (Refleksi & Santai)',
                    desc: 'Sempurna untuk Pengarsipan, Evaluasi & Rencana Esok',
                    badge: 'Santai',
                    badgeColor: AppColors.relaxedContainer,
                    badgeTextColor: AppColors.onRelaxedContainer,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String icon,
    required String subtitle,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(icon, style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.headlineSm.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.bodySm.copyWith(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyBar({
    required String label,
    required double ratio,
    required Color color,
  }) {
    final percentage = (ratio * 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600)),
            Text('$percentage%', style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            backgroundColor: AppColors.surfaceContainerLow,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeWindowTile({
    required String time,
    required String title,
    required String desc,
    required String badge,
    required Color badgeColor,
    required Color badgeTextColor,
  }) {
    return Row(
      children: [
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 4),
          alignment: Alignment.centerLeft,
          child: Text(
            time,
            style: AppTypography.labelSm.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                desc,
                style: AppTypography.bodySm.copyWith(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            badge,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: badgeTextColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final List<double> values;

  const _WeeklyBarChart({required this.values});

  @override
  Widget build(BuildContext context) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final maxValue = values.isEmpty
        ? 1.0
        : values.reduce((a, b) => a > b ? a : b).clamp(1.0, 100.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(days.length, (index) {
        final val = index < values.length ? values[index] : 0.0;
        final fraction = (val / maxValue).clamp(0.08, 1.0);
        final isHighest = val == maxValue && val > 0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              val.toInt().toString(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isHighest ? FontWeight.bold : FontWeight.w500,
                color: isHighest ? AppColors.primary : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 22,
              height: 80 * fraction,
              decoration: BoxDecoration(
                color: isHighest
                    ? AppColors.primary
                    : AppColors.primaryFixedDim.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              days[index],
              style: AppTypography.labelSm.copyWith(
                fontSize: 10,
                color: isHighest ? AppColors.primary : AppColors.onSurfaceVariant,
                fontWeight: isHighest ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        );
      }),
    );
  }
}
