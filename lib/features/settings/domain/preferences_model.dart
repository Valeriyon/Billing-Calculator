import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported languages in the app
enum AppLanguage {
  english('en', 'English'),
  malayalam('ml', 'മലയാളം'),
  hindi('hi', 'हिंदी'),
  tamil('ta', 'தமிழ்');

  const AppLanguage(this.code, this.displayName);
  final String code;
  final String displayName;

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}

/// Theme mode options
enum AppThemeMode {
  light,
  dark,
  contrast;

  static AppThemeMode fromString(String value) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AppThemeMode.light,
    );
  }
}

/// User preferences model
class UserPreferences {
  const UserPreferences({
    this.themeMode = AppThemeMode.light,
    this.language = AppLanguage.english,
    this.textScale = 1.0,
    this.contrastMode = false,
    this.hapticFeedback = true,
  });

  final AppThemeMode themeMode;
  final AppLanguage language;
  final double textScale;
  final bool contrastMode;
  final bool hapticFeedback;

  /// Create preferences from SharedPreferences
  factory UserPreferences.fromPrefs(SharedPreferences prefs) {
    return UserPreferences(
      themeMode: AppThemeMode.fromString(
        prefs.getString('themeMode') ?? 'light',
      ),
      language: AppLanguage.fromCode(prefs.getString('language') ?? 'en'),
      textScale: prefs.getDouble('textScale') ?? 1.0,
      contrastMode: prefs.getBool('contrastMode') ?? false,
      hapticFeedback: prefs.getBool('hapticFeedback') ?? true,
    );
  }

  /// Save preferences to SharedPreferences
  Future<void> saveToPrefs(SharedPreferences prefs) async {
    await prefs.setString('themeMode', themeMode.name);
    await prefs.setString('language', language.code);
    await prefs.setDouble('textScale', textScale);
    await prefs.setBool('contrastMode', contrastMode);
    await prefs.setBool('hapticFeedback', hapticFeedback);
  }

  /// Copy with modified values
  UserPreferences copyWith({
    AppThemeMode? themeMode,
    AppLanguage? language,
    double? textScale,
    bool? contrastMode,
    bool? hapticFeedback,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      textScale: textScale ?? this.textScale,
      contrastMode: contrastMode ?? this.contrastMode,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    );
  }

  /// Get the locale for the current language
  Locale get locale => Locale(language.code);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferences &&
        other.themeMode == themeMode &&
        other.language == language &&
        other.textScale == textScale &&
        other.contrastMode == contrastMode &&
        other.hapticFeedback == hapticFeedback;
  }

  @override
  int get hashCode {
    return Object.hash(
      themeMode,
      language,
      textScale,
      contrastMode,
      hapticFeedback,
    );
  }
}
