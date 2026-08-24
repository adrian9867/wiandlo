import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Base
  static const Color background   = Color(0xFF080808);
  static const Color surface      = Color(0xFF0F0F0F);

  // Track colors
  static const Color ground       = Color(0xFFA5D6A7); // soft green
  static const Color roots        = Color(0xFFFFAB91); // warm terracotta
  static const Color see          = Color(0xFF81D4FA); // light sky blue
  static const Color open         = Color(0xFFCE93D8); // soft purple
  static const Color live         = Color(0xFFFFCC80); // warm amber

  // UI
  static const Color textPrimary  = Color(0xFFEEEEEE);
  static const Color textSub      = Color(0xFF888888);
  static const Color safeHarbor   = Color(0xFFEF9A9A);
  static const Color inquiry      = Color(0xFFFFD54F);
  static const Color divider      = Color(0xFF1A1A1A);
}

class AppTextStyles {
  // Wisdom text — serif, contemplative
  static TextStyle wisdom({double size = 16, Color color = AppColors.textPrimary}) =>
    GoogleFonts.cormorantGaramond(
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w400,
      height: 1.7,
    );

  // UI text — clean sans
  static TextStyle ui({
    double size = 14,
    Color color = AppColors.textPrimary,
    double? height,
  }) =>
    GoogleFonts.inter(
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.3,
      height: height,
    );

  // Track label — spaced, quiet
  static TextStyle trackLabel({double size = 13, Color color = AppColors.textSub}) =>
    GoogleFonts.inter(
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w300,
      letterSpacing: 2.5,
    );

  // Large heading — rare, impactful
  static TextStyle heading({double size = 28, Color color = AppColors.textPrimary}) =>
    GoogleFonts.cormorantGaramond(
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w300,
      letterSpacing: 1.2,
      height: 1.3,
    );
}

class AppSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 40;
  static const double xxl = 64;
}

ThemeData buildAppTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.ground,
    ),
    splashColor:      Colors.transparent,
    highlightColor:   Colors.transparent,
    dividerColor:     AppColors.divider,
  );
}
