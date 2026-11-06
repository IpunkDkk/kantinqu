import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum EnergyLevel {
  high,
  medium,
  relaxed;

  String get displayName {
    switch (this) {
      case EnergyLevel.high:
        return '⚡ Fokus Tinggi';
      case EnergyLevel.medium:
        return '⚖️ Sedang';
      case EnergyLevel.relaxed:
        return '🌿 Santai';
    }
  }

  String get shortName {
    switch (this) {
      case EnergyLevel.high:
        return 'Fokus Tinggi';
      case EnergyLevel.medium:
        return 'Sedang';
      case EnergyLevel.relaxed:
        return 'Santai';
    }
  }

  String get description {
    switch (this) {
      case EnergyLevel.high:
        return 'Deep Work, butuh konsentrasi pekat & tanpa distraksi.';
      case EnergyLevel.medium:
        return 'Aktivitas teratur dengan ritme kerja santai & dinamis.';
      case EnergyLevel.relaxed:
        return 'Tugas ringan, administratif, & minim beban kognitif.';
    }
  }

  IconData get icon {
    switch (this) {
      case EnergyLevel.high:
        return Icons.bolt;
      case EnergyLevel.medium:
        return Icons.balance;
      case EnergyLevel.relaxed:
        return Icons.spa;
    }
  }

  Color get color {
    switch (this) {
      case EnergyLevel.high:
        return AppColors.highFocus;
      case EnergyLevel.medium:
        return AppColors.onSurfaceVariant;
      case EnergyLevel.relaxed:
        return AppColors.relaxed;
    }
  }

  Color get containerColor {
    switch (this) {
      case EnergyLevel.high:
        return AppColors.highFocusContainerLight;
      case EnergyLevel.medium:
        return AppColors.surfaceContainer;
      case EnergyLevel.relaxed:
        return AppColors.relaxedContainerLight;
    }
  }

  Color get badgeBgColor {
    switch (this) {
      case EnergyLevel.high:
        return AppColors.highFocusContainer.withValues(alpha: 0.4);
      case EnergyLevel.medium:
        return AppColors.surfaceContainer;
      case EnergyLevel.relaxed:
        return AppColors.relaxedContainer.withValues(alpha: 0.3);
    }
  }

  Color get badgeTextColor {
    switch (this) {
      case EnergyLevel.high:
        return AppColors.highFocus;
      case EnergyLevel.medium:
        return AppColors.onSurfaceVariant;
      case EnergyLevel.relaxed:
        return AppColors.relaxed;
    }
  }

  String toJson() => name;

  static EnergyLevel fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'high':
      case 'fokus tinggi':
        return EnergyLevel.high;
      case 'medium':
      case 'sedang':
        return EnergyLevel.medium;
      case 'relaxed':
      case 'santai':
      case 'low':
        return EnergyLevel.relaxed;
      default:
        return EnergyLevel.medium;
    }
  }
}
