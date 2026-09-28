import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF041627),
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFF1A2B3C),
          onPrimaryContainer: Color(0xFF8192A7),
          secondary: Color(0xFF0058BC),
          onSecondary: Color(0xFFFFFFFF),
          secondaryContainer: Color(0xFF0070EB),
          onSecondaryContainer: Color(0xFFFEFCFF),
          surface: Color(0xFFF8F9FF),
          onSurface: Color(0xFF0B1C30),
          surfaceContainerHighest: Color(0xFFD3E4FE),
          error: Color(0xFFBA1A1A),
          onError: Color(0xFFFFFFFF),
          outline: Color(0xFF74777D),
          outlineVariant: Color(0xFFC4C6CD),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1.375,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.333,
          ),
          displaySmall: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            height: 1.556,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          labelLarge: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.429,
          ),
          bodySmall: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.333,
          ),
        ),
        extensions: const [
          AppThemeExtension(
            surfaceContainerLow: Color(0xFFEFF4FF),
            surfaceContainer: Color(0xFFE5EEFF),
            surfaceContainerHigh: Color(0xFFDCE9FF),
            onSurfaceVariant: Color(0xFF44474C),
            outlineVariant: Color(0xFFC4C6CD),
            secondaryContainer: Color(0xFF0070EB),
            onSecondaryContainer: Color(0xFFFEFCFF),
            radiusSm: 4,
            radiusMd: 12,
            radiusLg: 16,
            radiusXl: 24,
            radiusFull: 9999,
          ),
        ],
      );
}
