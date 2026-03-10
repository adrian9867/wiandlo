import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../ground/ground_world_screen.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

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
              // Overview zooms away — falling through it
              ScaleTransition(
                scale: Tween<double>(
                  begin: 1.0,
                  end: 1.18,
                ).animate(curved),
                child: FadeTransition(
                  opacity: Tween<double>(
                    begin: 1.0,
                    end: 0.0,
                  ).animate(curved),
                  child: const OverviewScreen(),
                ),
              ),
              // New world rises from darkness
              FadeTransition(
                opacity: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: const Interval(
                    0.4, 1.0,
                    curve: Curves.easeOut,
                  ),
                )),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.06),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: const Interval(
                      0.4, 1.0,
                      curve: Curves.easeOutCubic,
                    ),
                  )),
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

          // ── 5 World Zones ──────────────────────────────
          Column(
            children: [
              _WorldZone(
                flex: 12,
                color: const Color(0xFF04040F),
                borderColor: AppColors.open.withOpacity(0.25),
                label: 'OPEN',
                sublabel: 'who is the one asking?',
                trackColor: AppColors.open,
                locked: true,
                onTap: () {},
              ),
              _WorldZone(
                flex: 10,
                color: const Color(0xFF0C0904),
                borderColor: AppColors.live.withOpacity(0.2),
                label: 'LIVE',
                sublabel: 'from fullness, not emptiness',
                trackColor: AppColors.live,
                locked: true,
                onTap: () {},
              ),
              _WorldZone(
                flex: 18,
                color: const Color(0xFF060D10),
                borderColor: AppColors.see.withOpacity(0.2),
                label: 'SEE',
                sublabel: 'understand your mind',
                trackColor: AppColors.see,
                locked: true,
                onTap: () {},
              ),
              _WorldZone(
                flex: 34,
                color: const Color(0xFF060D06),
                borderColor: AppColors.ground.withOpacity(0.35),
                label: 'GROUND',
                sublabel: 'quiet the noise',
                trackColor: AppColors.ground,
                locked: false,
                onTap: () => _diveInto(context, const GroundWorldScreen()),
              ),
              _WorldZone(
                flex: 26,
                color: const Color(0xFF060402),
                borderColor: AppColors.roots.withOpacity(0.2),
                label: 'ROOTS',
                sublabel: 'work with what runs you',
                trackColor: AppColors.roots,
                locked: true,
                onTap: () {},
              ),
            ],
          ),

          // ── Daily Inquiry pill (top) ───────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.inquiry.withOpacity(0.25),
                  ),
                  borderRadius: BorderRadius.circular(40),
                  color: AppColors.inquiry.withOpacity(0.04),
                ),
                child: Text(
                  '💬  today\'s question is waiting',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.ui(
                    size: 11,
                    color: AppColors.inquiry.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),

          // ── Safe Harbor button (always floating) ───────
          Positioned(
            right: AppSpacing.lg,
            bottom: AppSpacing.xl,
            child: GestureDetector(
              onTap: () {},
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.safeHarbor.withOpacity(0.5),
                        width: 1.5,
                      ),
                      color: AppColors.safeHarbor.withOpacity(0.08),
                    ),
                    child: Icon(
                      Icons.circle,
                      color: AppColors.safeHarbor.withOpacity(0.7),
                      size: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'safe',
                    style: AppTextStyles.ui(
                      size: 8,
                      color: AppColors.safeHarbor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// ── Reusable World Zone Widget ─────────────────────────────
class _WorldZone extends StatelessWidget {
  final int flex;
  final Color color;
  final Color borderColor;
  final String label;
  final String sublabel;
  final Color trackColor;
  final bool locked;
  final VoidCallback onTap;

  const _WorldZone({
    required this.flex,
    required this.color,
    required this.borderColor,
    required this.label,
    required this.sublabel,
    required this.trackColor,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: locked ? null : onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: color,
            border: Border(
              top: BorderSide(color: borderColor, width: 0.5),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [

              // Zone label + sublabel
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.trackLabel(
                      size: flex > 20 ? 14 : 11,
                      color: locked
                          ? trackColor.withOpacity(0.35)
                          : trackColor.withOpacity(0.9),
                    ),
                  ),
                  if (flex > 15) ...[
                    const SizedBox(height: 6),
                    Text(
                      sublabel,
                      style: AppTextStyles.ui(
                        size: 9,
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                  ],
                ],
              ),

              // Lock icon
              if (locked)
                Positioned(
                  left: AppSpacing.lg,
                  child: Icon(
                    Icons.lock_outline,
                    color: trackColor.withOpacity(0.2),
                    size: 12,
                  ),
                ),

              // Active glow dot for unlocked zones
              if (!locked)
                Positioned(
                  right: AppSpacing.lg,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: trackColor.withOpacity(0.8),
                      boxShadow: [
                        BoxShadow(
                          color: trackColor.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
