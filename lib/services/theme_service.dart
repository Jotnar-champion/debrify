import 'package:flutter/material.dart';
import 'storage_service.dart';

/// Manages app theme state with three modes: dark (default), amoled, light.
class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._();
  static ThemeService get instance => _instance;
  ThemeService._();

  String _currentTheme = 'dark';
  String get currentTheme => _currentTheme;

  Future<void> init() async {
    _currentTheme = await StorageService.getThemePreference();
    notifyListeners();
  }

  Future<void> setTheme(String theme) async {
    _currentTheme = theme;
    await StorageService.setThemePreference(theme);
    notifyListeners();
  }

  ThemeData get themeData {
    switch (_currentTheme) {
      case 'amoled':
        return _amoledTheme;
      case 'light':
        return _lightTheme;
      default:
        return _darkTheme;
    }
  }

  // ─── Dark Theme (default — current app theme) ───
  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6366F1),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF3730A3),
      onPrimaryContainer: Colors.white,
      secondary: Color(0xFF10B981),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF065F46),
      onSecondaryContainer: Colors.white,
      tertiary: Color(0xFFF59E0B),
      onTertiary: Colors.white,
      surface: Color(0xFF0F172A),
      onSurface: Colors.white,
      surfaceContainerHighest: Color(0xFF1E293B),
      surfaceContainerHigh: Color(0xFF334155),
      surfaceContainer: Color(0xFF475569),
      surfaceContainerLow: Color(0xFF64748B),
      surfaceContainerLowest: Color(0xFF94A3B8),
      background: Color(0xFF020617),
      onBackground: Colors.white,
      error: Color(0xFFEF4444),
      onError: Colors.white,
      outline: Color(0xFF475569),
      outlineVariant: Color(0xFF334155),
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    cardColor: const Color(0xFF1E293B),
  );

  // ─── AMOLED Theme (true black) ───
  static final ThemeData _amoledTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF818CF8),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF3730A3),
      onPrimaryContainer: Colors.white,
      secondary: Color(0xFF34D399),
      onSecondary: Colors.white,
      tertiary: Color(0xFFFBBF24),
      onTertiary: Colors.white,
      surface: Color(0xFF000000),
      onSurface: Colors.white,
      surfaceContainerHighest: Color(0xFF111111),
      surfaceContainerHigh: Color(0xFF1A1A1A),
      surfaceContainer: Color(0xFF222222),
      surfaceContainerLow: Color(0xFF333333),
      surfaceContainerLowest: Color(0xFF555555),
      background: Color(0xFF000000),
      onBackground: Colors.white,
      error: Color(0xFFEF4444),
      onError: Colors.white,
      outline: Color(0xFF333333),
      outlineVariant: Color(0xFF222222),
    ),
    scaffoldBackgroundColor: Colors.black,
    cardColor: const Color(0xFF111111),
  );

  // ─── Light Theme ───
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF4F46E5),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE0E7FF),
      onPrimaryContainer: Color(0xFF312E81),
      secondary: Color(0xFF059669),
      onSecondary: Colors.white,
      tertiary: Color(0xFFD97706),
      onTertiary: Colors.white,
      surface: Color(0xFFF8FAFC),
      onSurface: Color(0xFF0F172A),
      surfaceContainerHighest: Color(0xFFE2E8F0),
      surfaceContainerHigh: Color(0xFFCBD5E1),
      surfaceContainer: Color(0xFF94A3B8),
      surfaceContainerLow: Color(0xFF64748B),
      surfaceContainerLowest: Color(0xFF475569),
      background: Color(0xFFFFFFFF),
      onBackground: Color(0xFF0F172A),
      error: Color(0xFFDC2626),
      onError: Colors.white,
      outline: Color(0xFFCBD5E1),
      outlineVariant: Color(0xFFE2E8F0),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    cardColor: Colors.white,
  );
}
