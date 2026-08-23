import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../ground/ground_world_screen.dart';

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
                      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
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
      body: SafeArea(
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _entrance, curve: Curves.easeOut),
          child: Column(
            children: [
              _ZoneShell(
                flex: 20,
                trackColor: AppColors.open,
                label: 'OPEN',
                sublabel: 'today\'s question is waiting',
                locked: true,
                onTap: () {},
                motif: _RippleMotif(color: AppColors.open, loop: _loop),
              ),
              _ZoneShell(
                flex: 14,
                trackColor: AppColors.live,
                label: 'LIVE',
                sublabel: 'from fullness, not emptiness',
                locked: true,
                onTap: () {},
                motif: _PulseDotMotif(color: AppColors.live, breath: _breath),
              ),
              _ZoneShell(
                flex: 20,
                trackColor: AppColors.see,
                label: 'SEE',
                sublabel: 'understand your mind',
                locked: true,
                onTap: () {},
                motif: _DriftOrbMotif(color: AppColors.see, breath: _breath, loop: _loop),
              ),
              _ZoneShell(
                flex: 28,
                trackColor: AppColors.ground,
                label: 'GROUND',
                sublabel: 'quiet the noise',
                locked: false,
                onTap: () => _diveInto(context, const GroundWorldScreen()),
                motif: _GroundMotif(color: AppColors.ground, breath: _breath, loop: _loop),
              ),
              _ZoneShell(
                flex: 18,
                trackColor: AppColors.roots,
                label: 'ROOTS',
                sublabel: 'work with what runs you',
                locked: true,
                onTap: () {},
                motif: _RootsMotif(color: AppColors.roots, loop: _loop),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Zone shell: layout, press feedback, lock affordance ────
// No background color, no border — just soft space for the
// motif and label to breathe in.
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
                widget.trackColor.withOpacity(
                  widget.locked ? (_pressed ? 0.05 : 0.035) : (_pressed ? 0.09 : 0.06),
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
                          ? widget.trackColor.withOpacity(0.4)
                          : widget.trackColor.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.sublabel,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.ui(
                      size: 9,
                      color: Colors.white.withOpacity(widget.locked ? 0.18 : 0.28),
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
                    color: widget.trackColor.withOpacity(0.22),
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

// ── OPEN: expanding, fading ripple rings ────────────────────
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
            border: Border.all(color: color.withOpacity(opacity), width: 1),
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

// ── LIVE: a single breathing point of light ─────────────────
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
              color: color.withOpacity(0.5 + t * 0.4),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.25 + t * 0.25),
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

// ── SEE: a breathing field with a drifting mote of thought ──
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
                      color.withOpacity(0.28),
                      color.withOpacity(0.0),
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
                      color: color.withOpacity(0.8),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.5),
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

// ── GROUND: a larger breathing glow with faint threads below ─
class _GroundMotif extends StatelessWidget {
  final Color color;
  final Animation<double> breath;
  final Animation<double> loop;

  const _GroundMotif({
    required this.color,
    required this.breath,
    required this.loop,
  });

  Widget _thread(double phaseOffset) {
    return AnimatedBuilder(
      animation: loop,
      builder: (_, __) {
        final phase = (loop.value + phaseOffset) % 1.0;
        final wave = (sin(phase * 2 * pi) + 1) / 2;
        return Container(
          width: 1,
          height: 16 + wave * 12,
          color: color.withOpacity(0.15 + wave * 0.2),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: breath,
            builder: (_, __) => Container(
              width: 70 + breath.value * 14,
              height: 70 + breath.value * 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withOpacity(0.3),
                    color.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _thread(0),
              const SizedBox(width: 10),
              _thread(0.33),
              const SizedBox(width: 10),
              _thread(0.66),
            ],
          ),
        ],
      ),
    );
  }
}

// ── ROOTS: a quiet branching network, gently pulsing ─────────
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
            painter: _RootsPainter(color: color, animValue: loop.value),
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
      ..color = color.withOpacity(opacity)
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
  bool shouldRepaint(covariant _RootsPainter old) => old.animValue != animValue;
}