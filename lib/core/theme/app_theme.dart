import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palet Warna sesuai dokumen design.md
  static const Color primaryColor = Color(0xFF0F4C5C); // Deep Teal
  static const Color accentColor = Color(0xFFF5CB5C);  // Warm Amber
  static const Color backgroundColor = Color(0xFFF8F9FA); // Light Gray
  static const Color surfaceColor = Color(0xFFFFFFFF);     // Pure White
  
  // Warna Teks
  static const Color textHighEmphasis = Color(0xFF212529);   // Dark Charcoal
  static const Color textMediumEmphasis = Color(0xFF6C757D); // Slate Gray
  
  // Status Feedback
  static const Color successColor = Color(0xFF2A9D8F); // Emerald Green
  static const Color errorColor = Color(0xFFE5383B);   // Brick Red

  // Dark theme colors
  static const Color darkBg = Color(0xFF0D1421);
  static const Color darkCard = Color(0xFF151D2B);
  static const Color darkBorder = Color(0xFF253040);
  static const Color darkTextPrimary = Color(0xFFE2E8F0);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Shared accent colors
  static const Color blueAccent = Color(0xFF3B82F6);
  static const Color greenAccent = Color(0xFF22C55E);
  static const Color amberAccent = Color(0xFFF59E0B);
  static const Color redAccent = Color(0xFFEF4444);
  static const Color gradientStart = Color(0xFF1E3A5F);
  static const Color gradientEnd = Color(0xFF2563EB);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textHighEmphasis,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textHighEmphasis,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textHighEmphasis,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textHighEmphasis,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textMediumEmphasis,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: blueAccent,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: blueAccent,
        secondary: accentColor,
        surface: darkCard,
        error: redAccent,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkTextPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkTextPrimary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: darkTextSecondary,
        ),
      ),
    );
  }
}

/// Helper class to get theme-aware colors for worker screens
class WorkerColors {
  final BuildContext context;
  late final bool _isDark;

  WorkerColors(this.context) {
    _isDark = Theme.of(context).brightness == Brightness.dark;
  }

  // Background
  Color get bg => _isDark ? AppTheme.darkBg : const Color(0xFFF4F7FC);
  Color get cardBg => _isDark ? AppTheme.darkCard : Colors.white;
  Color get cardBorder => _isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB);
  
  // Text
  Color get textPrimary => _isDark ? AppTheme.darkTextPrimary : AppTheme.textHighEmphasis;
  Color get textSecondary => _isDark ? AppTheme.darkTextSecondary : AppTheme.textMediumEmphasis;
  
  // Accent (same in both modes)
  Color get blue => AppTheme.blueAccent;
  Color get green => AppTheme.greenAccent;
  Color get amber => AppTheme.amberAccent;
  Color get red => AppTheme.redAccent;
  Color get gradientStartColor => AppTheme.gradientStart;
  Color get gradientEndColor => AppTheme.gradientEnd;

  // Gradients
  LinearGradient get primaryGradient => const LinearGradient(
    colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Icon background
  Color iconBg(Color color) => color.withValues(alpha: _isDark ? 0.15 : 0.1);
  
  // Card shadow
  List<BoxShadow> cardShadow([Color? color]) => [
    BoxShadow(
      color: (color ?? Colors.black).withValues(alpha: _isDark ? 0.2 : 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}