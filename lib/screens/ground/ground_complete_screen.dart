import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.82),
        body: FadeTransition(
          opacity: CurvedAnimation(parent: _fade, curve: Curves.easeOut),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.didGrow) ...[
                    Icon(
                      Icons.eco_outlined,
                      color: AppColors.ground.withValues(alpha: 0.55),
                      size: 28,
                    ),
                    const SizedBox(height: AppSpacing.lg),
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
      ),
    );
  }
}
