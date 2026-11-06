import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'add_task_sheet.dart';
import 'calendar_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'statistics_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onNavigateToProfile: () => _onTabTapped(3),
      ),
      const CalendarScreen(),
      const StatisticsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundCanvas,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Screen View
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),

          // Custom Floating Bottom Navigation Bar matching beranda_design.html
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const barHeight = 64.0;
    const protrusion = 18.0;
    final totalHeight = barHeight + protrusion + bottomPadding;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Bar background with blur and top border (clipped strictly to bar boundaries)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barHeight + bottomPadding,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        AppColors.surfaceContainerLowest.withValues(alpha: 0.92),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF333333).withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, -2),
                      ),
                    ],
                    border: const Border(
                      top: BorderSide(
                        color: AppColors.borderSubtle,
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Navigation items and center elevated button without clipping
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding,
            height: barHeight + protrusion,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 1. Beranda
                _buildNavItem(
                  index: 0,
                  icon: Icons.spa,
                  label: 'Beranda',
                  height: barHeight,
                ),

                // 2. Kalender
                _buildNavItem(
                  index: 1,
                  icon: Icons.calendar_today,
                  label: 'Kalender',
                  height: barHeight,
                ),

                // 3. Middle Add Task Elevated Button (elevated above bar)
                _buildCenterAddButton(
                  height: barHeight + protrusion,
                ),

                // 4. Statistik
                _buildNavItem(
                  index: 2,
                  icon: Icons.energy_savings_leaf,
                  label: 'Statistik',
                  height: barHeight,
                ),

                // 5. Profil
                _buildNavItem(
                  index: 3,
                  icon: Icons.person,
                  label: 'Profil',
                  height: barHeight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required double height,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: SizedBox(
        height: height,
        child: InkWell(
          onTap: () => _onTabTapped(index),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color:
                    isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: AppTypography.labelSm.copyWith(
                  fontSize: 11,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterAddButton({required double height}) {
    return Expanded(
      child: SizedBox(
        height: height,
        child: InkWell(
          onTap: () {
            AddTaskSheet.show(context);
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF333333).withValues(alpha: 0.16),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  size: 26,
                  color: AppColors.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Tambah',
                style: AppTypography.labelSm.copyWith(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
