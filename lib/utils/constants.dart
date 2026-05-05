import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const hotPink = Color(0xFFE5007E);
  static const magenta = Color(0xFFC500B5);
  static const coral = Color(0xFFFF4D75);
  static const orange = Color(0xFFFF8A00);

  static const primary = hotPink;
  static const primaryDark = magenta;
  static const accent = Color(0xFFFFC7E3);
  static const blush = Color(0xFFFFEEF7);
  static const mint = Color(0xFFE7FFF8);
  static const lavender = Color(0xFFF3E8FF);
  static const cream = Color(0xFFFFF7E9);
  static const success = Color(0xFF00B870);
  static const warning = Color(0xFFFFCE2E);
  static const error = Color(0xFFE53935);
  static const info = Color(0xFF32BDF2);

  static const bgLight = Color(0xFFFFF2F8);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const onSurfaceLight = Color(0xFF22131D);

  static const bgDark = Color(0xFF160B11);
  static const surfaceDark = Color(0xFF24151F);
  static const onSurfaceDark = Color(0xFFFFEEF7);

  static const beautyGradient = LinearGradient(
    colors: [hotPink, magenta, coral],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.surfaceLight,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: AppColors.onSurfaceLight,
        displayColor: AppColors.onSurfaceLight,
      ),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurfaceLight,
        ),
        iconTheme: const IconThemeData(color: AppColors.onSurfaceLight),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: AppColors.primaryDark.withValues(alpha: .12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: .88),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
              BorderSide(color: AppColors.primary.withValues(alpha: .10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: .95),
        indicatorColor: AppColors.blush,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        modalBackgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        surface: AppColors.surfaceDark,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: AppColors.onSurfaceDark,
        displayColor: AppColors.onSurfaceDark,
      ),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurfaceDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.onSurfaceDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark.withValues(alpha: .9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.primary.withValues(alpha: .18),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        modalBackgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}
