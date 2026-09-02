import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeController {
  AppThemeController._();

  static const _preferenceKey = 'nirapod_dark_mode';
  static const _textSizeKey = 'nirapod_text_size';
  static const _accentKey = 'nirapod_accent_color';
  static final mode = ValueNotifier<ThemeMode>(ThemeMode.light);
  static final appearanceRevision = ValueNotifier<int>(0);
  static String textSize = 'medium';
  static String accentColor = 'purple';

  static bool get isDark => mode.value == ThemeMode.dark;
  static double get textScale => switch (textSize) {
        'small' => .9,
        'large' => 1.15,
        _ => 1.0,
      };
  static Color get accent => switch (accentColor) {
        'blue' => const Color(0xFF1769E8),
        'green' => const Color(0xFF14944C),
        _ => const Color(0xFF6628F5),
      };

  static Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    mode.value = (preferences.getBool(_preferenceKey) ?? false)
        ? ThemeMode.dark
        : ThemeMode.light;
    textSize = preferences.getString(_textSizeKey) ?? 'medium';
    accentColor = preferences.getString(_accentKey) ?? 'purple';
  }

  static Future<void> setDarkMode(bool enabled) async {
    mode.value = enabled ? ThemeMode.dark : ThemeMode.light;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_preferenceKey, enabled);
  }

  static Future<void> setTextSize(String value) async {
    textSize = value;
    appearanceRevision.value++;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_textSizeKey, value);
  }

  static Future<void> setAccentColor(String value) async {
    accentColor = value;
    appearanceRevision.value++;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_accentKey, value);
  }
}
