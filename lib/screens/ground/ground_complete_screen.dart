import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/safe_harbor.dart';
import 'widgets/growth_stage.dart';

class GroundCompleteScreen extends StatefulWidget {
  final bool didGrow;
  final GrowthStage newStage;

  const GroundCompleteScreen({
    super.key,
    required this.didGrow,
    required this.newStage,
  });

  @override
  State<GroundCompleteScreen> createState() => _GroundCompleteScreenState();
}

class _GroundCompleteScreenState extends State<GroundCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fade;
  late AnimationController _plantFlash;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();

    _plantFlash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  void dispose() {
    _fade.dispose();
    _plantFlash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.88),
        body: Stack(
          children: [
        FadeTransition(
          opacity: CurvedAnimation(parent: _fade, curve: Curves.easeOut),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brief plant emergence
                  AnimatedBuilder(
                    animation: _plantFlash,
                    builder: (_, __) {
                      final t = _plantFlash.value;
                      final opacity = t < 0.3
                          ? t / 0.3
                          : t > 0.7
                              ? (1 - t) / 0.3
                              : 1.0;
                      return Opacity(
                        opacity: opacity,
                        child: Icon(
                          Icons.eco_outlined,
                          color: AppColors.ground.withValues(alpha: 0.45),
                          size: 32,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  if (widget.didGrow) ...[
                    Text(
                      'something shifted',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.ui(
                        size: 24,
                        color: AppColors.ground.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      GrowthStageHelper.description(widget.newStage),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.ui(
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.28),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'you showed up.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.ui(
                        size: 24,
                        color: AppColors.ground.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'that is enough.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.ui(
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                  const SizedBox(height: 56),
                  Text(
                    'tap anywhere to return',
                    style: AppTextStyles.ui(
                      size: 10,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SafeHarbor(),
      ],
      ),
      ),
    );
  }
}