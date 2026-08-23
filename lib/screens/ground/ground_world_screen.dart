import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import 'ground_session_screen.dart';
import 'ground_complete_screen.dart';
import 'widgets/world_painter.dart';
import 'widgets/growth_stage.dart';

/// Approximate progress (0.0–1.0) toward the *next* growth stage,
/// mirroring the thresholds in GrowthStageHelper.fromSessionCount.
/// Purely cosmetic — kept local to this screen so growth_stage.dart
/// stays untouched.
double _stageProgress(int count) {
  const starts = [0, 1, 4, 8, 15, 26, 41];
  for (int i = 0; i < starts.length; i++) {
    final start = starts[i];
    final isLast = i == starts.length - 1;
    final end = isLast ? start + 15 : starts[i + 1];
    if (count < end || isLast) {
      final span = (end - start).clamp(1, 999999);
      return ((count - start) / span).clamp(0.0, 1.0);
    }
  }
  return 1.0;
}

class GroundWorldScreen extends StatefulWidget {
  const GroundWorldScreen({super.key});

  @override
  State<GroundWorldScreen> createState() => _GroundWorldScreenState();
}

class _GroundWorldScreenState extends State<GroundWorldScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  int _sessionCount = 0;
  GrowthStage _currentStage = GrowthStage.dormant;
  late List<Offset> _fireflies;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _fireflies = List.generate(
      8,
      (_) => Offset(Random().nextDouble(), Random().nextDouble() * 0.9),
    );

    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('ground_sessions') ?? 0;
    if (!mounted) return;
    setState(() {
      _sessionCount = count;
      _currentStage = GrowthStageHelper.fromSessionCount(count);
    });
  }

  Future<void> _handleSessionComplete() async {
    final prefs = await SharedPreferences.getInstance();
    final newCount = _sessionCount + 1;
    await prefs.setInt('ground_sessions', newCount);

    final newStage = GrowthStageHelper.fromSessionCount(newCount);
    final didGrow = newStage.index > _currentStage.index;

    setState(() {
      _sessionCount = newCount;
      _currentStage = newStage;
    });

    if (!mounted) return;

    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => GroundCompleteScreen(
          didGrow: didGrow,
          newStage: newStage,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  void _beginSession() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => GroundSessionScreen(
          onComplete: _handleSessionComplete,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060D06),
      body: Stack(
        children: [
          // ── Living World ──────────────────────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _breathController,
              builder: (_, __) => CustomPaint(
                painter: WorldPainter(
                  stage: _currentStage,
                  animValue: _breathController.value,
                  fireflies: _fireflies,
                ),
              ),
            ),
          ),

          // ── Top bar ───────────────────────────────────────────────
          // Stack-based so the GROUND label is truly centered
          // regardless of the back icon's width (the old Row +
          // double-Spacer layout was slightly off-axis).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.ground.withValues(alpha: 0.35),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'GROUND',
                      style: AppTextStyles.trackLabel(
                        size: 11,
                        color: AppColors.ground.withValues(alpha: 0.35),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Begin button ──────────────────────────────────────────
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _beginSession,
                child: AnimatedBuilder(
                  animation: _breathController,
                  builder: (_, child) {
                    final breath = _breathController.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.ground.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(40),
                        color: AppColors.ground.withValues(alpha: 0.04),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ground
                                .withValues(alpha: 0.05 + breath * 0.07),
                            blurRadius: 14 + breath * 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Text(
                    _sessionCount == 0
                        ? 'begin the cosmic arrival'
                        : 'begin session',
                    style: AppTextStyles.ui(
                      size: 13,
                      color: AppColors.ground.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Stage description + progress ───────────────────────────
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    GrowthStageHelper.description(_currentStage),
                    style: AppTextStyles.ui(
                      size: 10,
                      color: AppColors.ground.withValues(alpha: 0.22),
                    ),
                  ),
                  if (_currentStage != GrowthStage.forest) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: 64,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.ground.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _stageProgress(_sessionCount),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.ground.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}