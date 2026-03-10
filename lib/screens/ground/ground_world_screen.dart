import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import 'ground_session_screen.dart';
import 'ground_complete_screen.dart';
import 'widgets/world_painter.dart';
import 'widgets/growth_stage.dart';

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
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.ground.withValues(alpha: 0.35),
                        size: 16,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'GROUND',
                      style: AppTextStyles.trackLabel(
                        size: 11,
                        color: AppColors.ground.withValues(alpha: 0.35),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 16),
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
                child: Container(
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
                  ),
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

          // ── Stage description ─────────────────────────────────────
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                GrowthStageHelper.description(_currentStage),
                style: AppTextStyles.ui(
                  size: 10,
                  color: AppColors.ground.withValues(alpha: 0.22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
