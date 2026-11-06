import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/energy_level.dart';

class EnergyFilterBar extends StatelessWidget {
  final String activeFilter;
  final int totalCount;
  final int highCount;
  final int mediumCount;
  final int relaxedCount;
  final ValueChanged<String> onFilterChanged;

  const EnergyFilterBar({
    super.key,
    required this.activeFilter,
    required this.totalCount,
    required this.highCount,
    required this.mediumCount,
    required this.relaxedCount,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kategori Energi',
              style: AppTypography.labelLg,
            ),
            Text(
              'Pilih ritmemu',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildChip(
                id: 'all',
                label: 'Semua',
                count: totalCount,
                isSelected: activeFilter == 'all',
                badgeBg: AppColors.primary.withValues(alpha: 0.15),
              ),
              const SizedBox(width: 8),
              _buildChip(
                id: 'high',
                label: EnergyLevel.high.displayName,
                count: highCount,
                isSelected: activeFilter == 'high',
                indicatorColor: AppColors.highFocus,
              ),
              const SizedBox(width: 8),
              _buildChip(
                id: 'medium',
                label: EnergyLevel.medium.displayName,
                count: mediumCount,
                isSelected: activeFilter == 'medium',
                indicatorColor: AppColors.mediumFocus,
              ),
              const SizedBox(width: 8),
              _buildChip(
                id: 'relaxed',
                label: EnergyLevel.relaxed.displayName,
                count: relaxedCount,
                isSelected: activeFilter == 'relaxed',
                indicatorColor: AppColors.relaxedContainer,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    required String id,
    required String label,
    required int count,
    required bool isSelected,
    Color? indicatorColor,
    Color? badgeBg,
  }) {
    return InkWell(
      onTap: () => onFilterChanged(id),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (indicatorColor != null && !isSelected) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTypography.labelMd.copyWith(
                color: isSelected
                    ? AppColors.onPrimaryContainer
                    : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : (badgeBg ?? AppColors.surfaceContainerHigh),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: AppTypography.labelSm.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AppColors.onPrimaryContainer
                      : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
