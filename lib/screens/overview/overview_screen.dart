import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/safe_harbor.dart';
import '../ground/ground_world_screen.dart';
import '../open/daily_inquiry_screen.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _breath;
  late final AnimationController _loop;
  int _groundSessions = 0;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _loop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _loadGroundProgress();
  }

  Future<void> _loadGroundProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('ground_sessions') ?? 0;
    if (!mounted) return;
    setState(() => _groundSessions = count);
  }

  @override
  void dispose() {
    _entrance.dispose();
    _breath.dispose();
    _loop.dispose();
    super.dispose();
  }

  void _diveInto(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => screen,
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInCubic,
          );
          return Stack(
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 1.18).animate(curved),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 1.0, end: 0.0).animate(curved),
                  child: const OverviewScreen(),
                ),
              ),
              FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
                  ),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.06),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: const Interval(
                        0.4,
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
                  child: child,
                ),
              ),
            ],
          );
        },
        transitionDuration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _entrance,
                curve: Curves.easeOut,
              ),
              child: Column(
                children: [
                  _ZoneShell(
  flex: 20,
  trackColor: AppColors.open,
  label: 'OPEN',
  sublabel: 'enter the field',
  locked: true,
  onTap: () {},
  motif: _InquiryBubbleMotif(
    color: AppColors.open,
    loop: _loop,
  ),
),
                  _ZoneShell(
                    flex: 14,
                    trackColor: AppColors.live,
                    label: 'LIVE',
                    sublabel: 'from fullness, not emptiness',
                    locked: true,
                    onTap: () {},
                    motif: _PulseDotMotif(
                      color: AppColors.live,
                      breath: _breath,
                    ),
                  ),
                  _ZoneShell(
                    flex: 20,
                    trackColor: AppColors.see,
                    label: 'SEE',
                    sublabel: 'understand your mind',
                    locked: true,
                    onTap: () {},
                    motif: _DriftOrbMotif(
                      color: AppColors.see,
                      breath: _breath,
                      loop: _loop,
                    ),
                  ),
                  _ZoneShell(
                    flex: 28,
                    trackColor: AppColors.ground,
                    label: 'GROUND',
                    sublabel: 'quiet the noise',
                    locked: false,
                    onTap: () => _diveInto(
                      context,
                      const GroundWorldScreen(),
                    ),
                    motif: _GroundEcosystemMotif(
                      color: AppColors.ground,
                      breath: _breath,
                      loop: _loop,
                      sessionCount: _groundSessions,
                    ),
                  ),
                  _ZoneShell(
                    flex: 18,
                    trackColor: AppColors.roots,
                    label: 'ROOTS',
                    sublabel: 'work with what runs you',
                    locked: true,
                    onTap: () {},
                    motif: _RootsMotif(
                      color: AppColors.roots,
                      loop: _loop,
                    ),
                  ),
                ],
              ),
            ),
          ),
                    
                    Positioned(
            left: 20,
            bottom: 24,
            child: GestureDetector(
              onTap: () => _diveInto(
                context,
                DailyInquiryScreen(),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.open.withValues(alpha: 0.30),
                  ),
                  color: AppColors.open.withValues(alpha: 0.06),
                ),
                child: const Text(
                  'DAILY INQUIRY',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SafeHarbor(),
        ],
      ),
    );
  }
}

// ── Zone Shell ───────────────────────────────────────────────────

class _ZoneShell extends StatefulWidget {
  final int flex;
  final Color trackColor;
  final String label;
  final String sublabel;
  final bool locked;
  final VoidCallback onTap;
  final Widget motif;

  const _ZoneShell({
    required this.flex,
    required this.trackColor,
    required this.label,
    required this.sublabel,
    required this.locked,
    required this.onTap,
    required this.motif,
  });

  @override
  State<_ZoneShell> createState() => _ZoneShellState();
}

class _ZoneShellState extends State<_ZoneShell> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.locked) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: GestureDetector(
        onTap: widget.locked ? null : widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                widget.trackColor.withValues(
                  alpha: widget.locked
                      ? (_pressed ? 0.05 : 0.035)
                      : (_pressed ? 0.09 : 0.06),
                ),
                Colors.transparent,
              ],
              radius: 0.85,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              widget.motif,
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: AppTextStyles.trackLabel(
                      size: widget.flex >= 24 ? 14 : 12,
                      color: widget.locked
                          ? widget.trackColor.withValues(alpha: 0.4)
                          : widget.trackColor.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.sublabel,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.ui(
                      size: 9,
                      color: Colors.white.withValues(
                        alpha: widget.locked ? 0.18 : 0.28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
              if (widget.locked)
                Positioned(
                  top: 4,
                  left: AppSpacing.md,
                  child: Icon(
                    Icons.lock_outline,
                    color: widget.trackColor.withValues(alpha: 0.22),
                    size: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Motifs ───────────────────────────────────────────────────────

class _RippleMotif extends StatelessWidget {
  final Color color;
  final Animation<double> loop;

  const _RippleMotif({required this.color, required this.loop});

  Widget _ring(double phaseOffset) {
    return AnimatedBuilder(
      animation: loop,
      builder: (_, __) {
        final phase = (loop.value + phaseOffset) % 1.0;
        final size = 20 + phase * 44;
        final opacity = (1 - phase).clamp(0.0, 1.0) * 0.6;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: opacity),
              width: 1,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Stack(
        alignment: Alignment.center,
        children: [_ring(0), _ring(0.5)],
      ),
    );
  }
}

class _PulseDotMotif extends StatelessWidget {
  final Color color;
  final Animation<double> breath;

  const _PulseDotMotif({required this.color, required this.breath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: AnimatedBuilder(
        animation: breath,
        builder: (_, __) {
          final t = breath.value;
          return Container(
            width: 6 + t * 3,
            height: 6 + t * 3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.5 + t * 0.4),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.25 + t * 0.25),
                  blurRadius: 8 + t * 10,
                  spreadRadius: 1 + t * 2,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DriftOrbMotif extends StatelessWidget {
  final Color color;
  final Animation<double> breath;
  final Animation<double> loop;

  const _DriftOrbMotif({
    required this.color,
    required this.breath,
    required this.loop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: SizedBox(
        width: 90,
        height: 70,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: breath,
              builder: (_, __) => Container(
                width: 46 + breath.value * 8,
                height: 46 + breath.value * 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: 0.28),
                      color.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: loop,
              builder: (_, __) {
                final angle = loop.value * 2 * pi;
                final dx = cos(angle) * 26;
                final dy = sin(angle) * 12;
                return Transform.translate(
                  offset: Offset(dx, dy),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RootsMotif extends StatelessWidget {
  final Color color;
  final Animation<double> loop;

  const _RootsMotif({required this.color, required this.loop});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: SizedBox(
        width: 120,
        height: 70,
        child: AnimatedBuilder(
          animation: loop,
          builder: (_, __) => CustomPaint(
            painter: _RootsPainter(
              color: color,
              animValue: loop.value,
            ),
          ),
        ),
      ),
    );
  }
}

class _RootsPainter extends CustomPainter {
  final Color color;
  final double animValue;

  const _RootsPainter({required this.color, required this.animValue});

  void _curve(Canvas canvas, Paint paint, Offset a, Offset c, Offset b) {
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(c.dx, c.dy, b.dx, b.dy);
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final wave = (sin(animValue * 2 * pi) + 1) / 2;
    final opacity = 0.22 + wave * 0.18;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final top = Offset(cx, 0);
    _curve(canvas, paint, top, Offset(cx, size.height * 0.35),
        Offset(cx, size.height * 0.6));
    _curve(canvas, paint, Offset(cx, size.height * 0.35),
        Offset(cx - 20, size.height * 0.5), Offset(cx - 44, size.height * 0.85));
    _curve(canvas, paint, Offset(cx, size.height * 0.35),
        Offset(cx + 20, size.height * 0.5), Offset(cx + 44, size.height * 0.85));
    _curve(canvas, paint, Offset(cx - 44, size.height * 0.85),
        Offset(cx - 50, size.height * 0.95), Offset(cx - 58, size.height));
    _curve(canvas, paint, Offset(cx + 44, size.height * 0.85),
        Offset(cx + 50, size.height * 0.95), Offset(cx + 58, size.height));
  }

  @override
  bool shouldRepaint(covariant _RootsPainter old) =>
      old.animValue != animValue;
}

// ── NEW: Inquiry Bubble (OPEN) ───────────────────────────────────

class _InquiryBubbleMotif extends StatelessWidget {
  final Color color;
  final Animation<double> loop;

  const _InquiryBubbleMotif({required this.color, required this.loop});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: AnimatedBuilder(
        animation: loop,
        builder: (_, __) {
          final breathe = 0.6 + (sin(loop.value * 2 * pi) + 1) / 2 * 0.4;
          return Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.22 * breathe),
                width: 1,
              ),
              color: color.withValues(alpha: 0.05 * breathe),
            ),
            child: Center(
              child: Text(
                '?',
                style: AppTextStyles.ui(
                  size: 14,
                  color: color.withValues(alpha: 0.45 * breathe),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── NEW: Ground Ecosystem Mini-Preview ───────────────────────────

class _GroundEcosystemMotif extends StatelessWidget {
  final Color color;
  final Animation<double> breath;
  final Animation<double> loop;
  final int sessionCount;

  const _GroundEcosystemMotif({
    required this.color,
    required this.breath,
    required this.loop,
    required this.sessionCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 34),
      child: SizedBox(
        width: 140,
        height: 90,
        child: AnimatedBuilder(
          animation: Listenable.merge([breath, loop]),
          builder: (_, __) {
            return CustomPaint(
              painter: _MiniEcosystemPainter(
                color: color,
                breath: breath.value,
                loop: loop.value,
                plantCount: sessionCount.clamp(0, 8),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MiniEcosystemPainter extends CustomPainter {
  final Color color;
  final double breath;
  final double loop;
  final int plantCount;

  _MiniEcosystemPainter({
    required this.color,
    required this.breath,
    required this.loop,
    required this.plantCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseY = size.height;
    final paint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final orbPaint = Paint()
      ..color = color.withValues(alpha: 0.06 + breath * 0.04)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, baseY - 20),
      28 + breath * 8,
      orbPaint,
    );

    for (int i = 0; i < plantCount; i++) {
      final x = size.width * (0.2 + (i / 8) * 0.6) + (i % 3 - 1) * 3.0;
      final h = 12 + (i % 4) * 4.0;
      final sway = sin((loop + i * 0.3) * 2 * pi) * 2;

      paint.color = color.withValues(
        alpha: 0.35 + sin((loop + i) * pi) * 0.15,
      );

      final path = Path()
        ..moveTo(x, baseY)
        ..lineTo(x + sway, baseY - h);
      canvas.drawPath(path, paint);

      if (i % 2 == 0) {
        canvas.drawLine(
          Offset(x + sway * 0.5, baseY - h * 0.6),
          Offset(x + sway * 0.5 - 4, baseY - h * 0.6 - 3),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MiniEcosystemPainter old) =>
      old.breath != breath ||
      old.loop != loop ||
      old.plantCount != plantCount;
}