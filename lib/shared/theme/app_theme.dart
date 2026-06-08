import 'package:flutter/material.dart';

class AppTheme {
  static const _primary = Color(0xFF6366F1);
  static const _secondary = Color(0xFFA78BFA);
  static const _surface = Color(0xFF0D1020);
  static const _surfaceHigh = Color(0xFF131828);
  static const _onSurface = Color(0xFFE2E8F8);
  static const _muted = Color(0xFF94A3B8);
  static const _outline = Color(0xFF1A2540);

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: _primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF1E1B4B),
      onPrimaryContainer: Color(0xFFE0E7FF),
      secondary: _secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF2E1065),
      onSecondaryContainer: Color(0xFFEDE9FE),
      tertiary: Color(0xFF60A5FA),
      onTertiary: Color(0xFF003065),
      surface: _surface,
      onSurface: _onSurface,
      surfaceContainerHighest: _surfaceHigh,
      outline: _outline,
      outlineVariant: Color(0xFF0F1A30),
      error: Color(0xFFFF6B6B),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: _onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: _onSurface),
      ),
      cardTheme: CardThemeData(
        color: _surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x14FFFFFF),
        space: 0,
        thickness: 0.5,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x0AFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x14FFFFFF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x14FFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: _muted),
        hintStyle: const TextStyle(color: _muted),
        prefixIconColor: _muted,
        suffixIconColor: _muted,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: Color(0x20FFFFFF)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surface.withValues(alpha: 0.9),
        indicatorColor: const Color(0xFF1E1B4B),
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontSize: 11, color: _primary, fontWeight: FontWeight.w600);
          }
          return const TextStyle(fontSize: 11, color: _muted);
        }),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: _onSurface,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _onSurface,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _onSurface,
          letterSpacing: -0.2,
        ),
        bodyLarge: TextStyle(fontSize: 15, color: _onSurface, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: _muted, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, color: _muted),
        labelSmall: TextStyle(fontSize: 11, color: _muted, letterSpacing: 0.3),
      ),
    );
  }

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF1F4FF),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF1F4FF),
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        space: 0,
        thickness: 0.5,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 15, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
        bodySmall: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
      ),
    );
  }
}
