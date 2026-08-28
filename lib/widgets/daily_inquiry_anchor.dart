import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/open/daily_inquiry_screen.dart';

class DailyInquiryAnchor extends StatefulWidget {
  const DailyInquiryAnchor({super.key});

  @override
  State<DailyInquiryAnchor> createState() => _DailyInquiryAnchorState();
}

class _DailyInquiryAnchorState extends State<DailyInquiryAnchor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _openInquiry() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const DailyInquiryScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.96,
                end: 1.0,
              ).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 22,
      left: 20,
      child: GestureDetector(
        onTap: _openInquiry,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) {
            final value = _pulse.value;

            return Opacity(
              opacity: 0.72 + (value * 0.28),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.open.withValues(
                      alpha: 0.28 + (value * 0.18),
                    ),
                  ),
                  color: AppColors.open.withValues(alpha: 0.05),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.open.withValues(
                        alpha: 0.08 + (value * 0.08),
                      ),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.open,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.open.withValues(alpha: 0.55),
                            blurRadius: 7,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'DAILY INQUIRY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'today awaits',
                          style: TextStyle(
                            fontSize: 8,
                            letterSpacing: 0.7,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
