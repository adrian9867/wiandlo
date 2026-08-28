import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/safe_harbor.dart';
import 'ground_session_screen.dart';
import 'ground_complete_screen.dart';
import 'widgets/growth_stage.dart';

// ── Ecosystem Painter (unchanged from previous) ──────────────────

class _Plant {
  final double x;
  final double height;
  final int leafCount;
  final double lean;
  final double seed;
  final Color color;

  const _Plant({
    required this.x,
    required this.height,
    required this.leafCount,
    required this.lean,
    required this.seed,
    required this.color,
  });
}

class _EcosystemPainter extends CustomPainter {
  final int plantCount;
  final double animValue;
  final List<_Plant> plants;

  const _EcosystemPainter({
    required this.plantCount,
    required this.animValue,
    required this.plants,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final groundY = size.height;
    for (int i = 0; i < plantCount && i < plants.length; i++) {
      final p = plants[i];
      final baseX = p.x * size.width;
      final stemHeight = p.height * size.height * 0.28;
      final sway = sin((animValue + p.seed) * 2 * pi) * 0.025;

      final paint = Paint()
        ..color = p.color.withValues(
          alpha: 0.5 + sin((animValue + p.seed) * pi) * 0.15,
        )
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final topX = baseX + (p.lean + sway) * stemHeight;
      final topY = groundY - stemHeight;

      final path = Path()
        ..moveTo(baseX, groundY)
        ..quadraticBezierTo(
          baseX + (p.lean + sway) * stemHeight * 0.5,
          groundY - stemHeight * 0.5,
          topX,
          topY,
        );
      canvas.drawPath(path, paint);

      for (int j = 0; j < p.leafCount; j++) {
        final leafT = (j + 1) / (p.leafCount + 1);
        final leafY = groundY - stemHeight * leafT;
        final leafX = baseX + (p.lean + sway) * stemHeight * leafT;
        final leafSway =
            sin((animValue * 1.3 + p.seed + j) * 2 * pi) * 0.015;
        final leafAngle = (p.lean > 0 ? -0.9 : 0.9) + leafSway + sway;
        final leafLen = stemHeight * 0.16;

        _drawLeaf(canvas, leafX, leafY, leafAngle, leafLen, paint);
      }
    }
  }

  void _drawLeaf(
    Canvas canvas,
    double x,
    double y,
    double angle,
    double len,
    Paint paint,
  ) {
    final dx = cos(angle) * len;
    final dy = sin(angle) * len;
    final path = Path()
      ..moveTo(x, y)
      ..quadraticBezierTo(
        x + dx * 0.5,
        y + dy * 0.5 - len * 0.25,
        x + dx,
        y + dy,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _EcosystemPainter old) =>
      old.plantCount != plantCount || old.animValue != animValue;
}

// ── Mode Selector ────────────────────────────────────────────────

class _ModeSelector extends StatefulWidget {
  final VoidCallback onGuided;
  final VoidCallback onFree;
  final int unlockedTracks;
  final int totalTracks;

  const _ModeSelector({
    required this.onGuided,
    required this.onFree,
    required this.unlockedTracks,
    required this.totalTracks,
  });

  @override
  State<_ModeSelector> createState() => _ModeSelectorState();
}

class _ModeSelectorState extends State<_ModeSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _appear;

  @override
  void initState() {
    super.initState();
    _appear = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _appear.dispose();
    super.dispose();
  }

  Widget _portal({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Widget motif,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.ground.withValues(alpha: 0.12),
          ),
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF080F08),
        ),
        child: Row(
          children: [
            SizedBox(width: 48, height: 48, child: motif),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.ui(
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.ui(
                      size: 10,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.ground.withValues(alpha: 0.25),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: AppTextStyles.ui(
                    size: 9,
                    color: AppColors.ground.withValues(alpha: 0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _appear, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _appear, curve: Curves.easeOutCubic),
        ),
        child: Container(
          color: Colors.black.withValues(alpha: 0.75),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _portal(
                    title: 'Guided Transmission',
                    subtitle: 'follow a voice into stillness',
                    badge: '${widget.unlockedTracks}/${widget.totalTracks}',
                    onTap: widget.onGuided,
                    motif: _SignalMotif(),
                  ),
                  const SizedBox(height: 12),
                  _portal(
                    title: 'Free Attunement',
                    subtitle: 'timer, breath, environment',
                    onTap: widget.onFree,
                    motif: _WaveMotif(),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      'close',
                      style: AppTextStyles.ui(
                        size: 11,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
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

class _SignalMotif extends StatefulWidget {
  @override
  State<_SignalMotif> createState() => _SignalMotifState();
}

class _SignalMotifState extends State<_SignalMotif>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return CustomPaint(
          painter: _SignalPainter(
            color: AppColors.ground,
            anim: _ctrl.value,
          ),
        );
      },
    );
  }
}

class _SignalPainter extends CustomPainter {
  final Color color;
  final double anim;

  _SignalPainter({required this.color, required this.anim});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (int i = 0; i < 3; i++) {
      final phase = (anim + i / 3) % 1.0;
      final r = 8 + phase * 16;
      final paint = Paint()
        ..color = color.withValues(alpha: (1 - phase) * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(c, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignalPainter old) => old.anim != anim;
}

class _WaveMotif extends StatefulWidget {
  @override
  State<_WaveMotif> createState() => _WaveMotifState();
}

class _WaveMotifState extends State<_WaveMotif>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return CustomPaint(
          painter: _WavePainter(
            color: AppColors.ground,
            anim: _ctrl.value,
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  final double anim;

  _WavePainter({required this.color, required this.anim});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height / 2 + sin((x / size.width + anim) * 2 * pi) * 6;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => old.anim != anim;
}

// ── Ground World Screen ──────────────────────────────────────────

class GroundWorldScreen extends StatefulWidget {
  const GroundWorldScreen({super.key});

  @override
  State<GroundWorldScreen> createState() => _GroundWorldScreenState();
}

class _GroundWorldScreenState extends State<GroundWorldScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  int _sessionCount = 0;
  int _maxUnlockedTrack = 1;
  GrowthStage _currentStage = GrowthStage.dormant;
  late List<_Plant> _plants;
  bool _showModeSelector = false;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _plants = List.generate(
      40,
      (i) => _Plant(
        x: 0.05 + (i / 40) * 0.9 + (Random().nextDouble() - 0.5) * 0.04,
        height: 0.4 + Random().nextDouble() * 0.6,
        leafCount: 2 + Random().nextInt(3),
        lean: (Random().nextDouble() - 0.5) * 0.6,
        seed: Random().nextDouble(),
        color: AppColors.ground,
      ),
    );

    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('ground_sessions') ?? 0;
    final maxTrack = prefs.getInt('ground_max_unlocked_track') ?? 1;
    if (!mounted) return;
    setState(() {
      _sessionCount = count;
      _maxUnlockedTrack = maxTrack;
      _currentStage = GrowthStageHelper.fromSessionCount(count);
    });
  }

  Future<void> _handleSessionComplete() async {
    final prefs = await SharedPreferences.getInstance();
    final newCount = _sessionCount + 1;
    await prefs.setInt('ground_sessions', newCount);

    final newStage = GrowthStageHelper.fromSessionCount(newCount);
    final didGrow = newStage.index > _currentStage.index;

    if (!mounted) return;

    setState(() {
      _sessionCount = newCount;
      _currentStage = newStage;
    });

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

  void _openGuided() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => GroundSessionScreen(
          mode: SessionMode.guided,
          onComplete: _handleSessionComplete,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _openFree() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => GroundSessionScreen(
          mode: SessionMode.free,
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

  double get _vitalityProgress {
    const maxPlants = 30;
    return (_sessionCount / maxPlants).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A05),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _breathController,
              builder: (_, __) => CustomPaint(
                painter: _EcosystemPainter(
                  plantCount: _sessionCount.clamp(0, 40),
                  animValue: _breathController.value,
                  plants: _plants,
                ),
              ),
            ),
          ),
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
          Positioned(
            bottom: 80 + MediaQuery.of(context).padding.bottom,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => setState(() => _showModeSelector = true),
                child: AnimatedBuilder(
                  animation: _breathController,
                  builder: (_, child) {
                    final breath = _breathController.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 16,
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
                            blurRadius: 16 + breath * 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Text(
                    _sessionCount == 0
                        ? 'begin the cosmic arrival'
                        : 'enter attunement',
                    style: AppTextStyles.ui(
                      size: 13,
                      color: AppColors.ground.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 28 + MediaQuery.of(context).padding.bottom,
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
                  const SizedBox(height: 10),
                  Container(
                    width: 80,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.ground.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _vitalityProgress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.ground.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showModeSelector)
            _ModeSelector(
              onGuided: _openGuided,
              onFree: _openFree,
              unlockedTracks: (_maxUnlockedTrack + 1).clamp(0, 10),
              totalTracks: 10,
            ),
          const SafeHarbor(),
        ],
      ),
    );
  }
}