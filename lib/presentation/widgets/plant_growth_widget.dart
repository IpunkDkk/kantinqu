import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/gamification_model.dart';

class PlantGrowthWidget extends StatefulWidget {
  final GamificationModel gamification;
  final int completedToday;
  final int totalToday;
  final VoidCallback onWater;

  const PlantGrowthWidget({
    super.key,
    required this.gamification,
    required this.completedToday,
    required this.totalToday,
    required this.onWater,
  });

  @override
  State<PlantGrowthWidget> createState() => _PlantGrowthWidgetState();
}

class _PlantGrowthWidgetState extends State<PlantGrowthWidget>
    with SingleTickerProviderStateMixin {
  bool _justWatered = false;
  late AnimationController _pulseController;
  Timer? _waterResetTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waterResetTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleWater() {
    widget.onWater();
    setState(() {
      _justWatered = true;
    });
    _waterResetTimer?.cancel();
    _waterResetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _justWatered = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.gamification;
    final int percentage = widget.totalToday == 0
        ? 0
        : ((widget.completedToday / widget.totalToday) * 100).round();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryFixed.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥 ', style: TextStyle(fontSize: 12)),
                              Text(
                                '${game.currentStreak} Hari Beruntun',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.onTertiaryFixedVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Taman Pikiran',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            game.plantName,
                            style: AppTypography.headlineSm.copyWith(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Lvl ${game.plantLevel}',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.completedToday} dari ${widget.totalToday} tugas selesai hari ini ($percentage%)',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Plant Visual Container
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: _PlantPainter(level: game.plantLevel),
                    ),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulseController.value * 0.12),
                          child: child,
                        );
                      },
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '🌱',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Growth Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 7,
              width: double.infinity,
              child: Stack(
                children: [
                  Container(color: AppColors.surfaceContainerHighest),
                  FractionallySizedBox(
                    widthFactor: widget.totalToday == 0
                        ? 0.0
                        : (widget.completedToday / widget.totalToday)
                            .clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Micro Action: Siram Tanaman
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.water_drop,
                      size: 16,
                      color: AppColors.highFocusAccent,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: RichText(
                        text: TextSpan(
                          text: 'Siram Tanaman ',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textMuted,
                          ),
                          children: [
                            TextSpan(
                              text: '+20 XP',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _justWatered ? null : _handleWater,
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _justWatered
                        ? AppColors.primaryContainer
                        : AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _justWatered ? Icons.check : Icons.opacity,
                        size: 15,
                        color: _justWatered
                            ? AppColors.onPrimaryContainer
                            : AppColors.highFocusAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _justWatered ? 'Disiram!' : 'Siram Sekarang',
                        style: AppTypography.labelSm.copyWith(
                          color: _justWatered
                              ? AppColors.onPrimaryContainer
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlantPainter extends CustomPainter {
  final int level;

  _PlantPainter({required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Pot
    final potPaint = Paint()
      ..color = const Color(0xFFA4C9FF).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final potPath = Path()
      ..moveTo(size.width * 0.33, size.height * 0.68)
      ..lineTo(size.width * 0.67, size.height * 0.68)
      ..lineTo(size.width * 0.63, size.height * 0.88)
      ..lineTo(size.width * 0.37, size.height * 0.88)
      ..close();
    canvas.drawPath(potPath, potPaint);

    // Stem
    final stemPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final stemPath = Path()
      ..moveTo(center.dx, size.height * 0.68)
      ..quadraticBezierTo(
        center.dx,
        size.height * 0.45,
        center.dx,
        size.height * 0.32,
      );
    canvas.drawPath(stemPath, stemPaint);

    // Leaves
    final leafPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    // Left Leaf (Monstera style curve)
    final leftLeaf = Path()
      ..moveTo(center.dx, size.height * 0.45)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.38,
        size.width * 0.18,
        size.height * 0.22,
        size.width * 0.32,
        size.height * 0.18,
      )
      ..cubicTo(
        size.width * 0.45,
        size.height * 0.18,
        center.dx,
        size.height * 0.30,
        center.dx,
        size.height * 0.45,
      );
    canvas.drawPath(leftLeaf, leafPaint);

    // Right Leaf
    final rightLeaf = Path()
      ..moveTo(center.dx, size.height * 0.42)
      ..cubicTo(
        size.width * 0.75,
        size.height * 0.35,
        size.width * 0.82,
        size.height * 0.20,
        size.width * 0.68,
        size.height * 0.16,
      )
      ..cubicTo(
        size.width * 0.55,
        size.height * 0.16,
        center.dx,
        size.height * 0.28,
        center.dx,
        size.height * 0.42,
      );
    canvas.drawPath(rightLeaf, leafPaint);

    // Top Leaf if level >= 3
    if (level >= 3) {
      final topLeaf = Path()
        ..moveTo(center.dx, size.height * 0.32)
        ..cubicTo(
          size.width * 0.40,
          size.height * 0.14,
          size.width * 0.60,
          size.height * 0.14,
          center.dx,
          size.height * 0.32,
        );
      canvas.drawPath(topLeaf, leafPaint);
    }

    // Leaf decoration dot
    final dotPaint = Paint()
      ..color = AppColors.highFocusContainer
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx, size.height * 0.20),
      3,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PlantPainter oldDelegate) =>
      oldDelegate.level != level;
}
