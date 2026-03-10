import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/settings/domain/preferences_model.dart';
import '../database/app_database.dart';

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main()');
});

/// Provider for the database instance
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Provider for user preferences with persistence
final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return UserPreferencesNotifier(prefs);
    });

/// StateNotifier for managing user preferences
class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  UserPreferencesNotifier(this._prefs)
    : super(UserPreferences.fromPrefs(_prefs));

  final SharedPreferences _prefs;

  /// Update theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await state.saveToPrefs(_prefs);
  }

  /// Update language
  Future<void> setLanguage(AppLanguage language) async {
    state = state.copyWith(language: language);
    await state.saveToPrefs(_prefs);
  }

  /// Update text scale
  Future<void> setTextScale(double scale) async {
    state = state.copyWith(textScale: scale);
    await state.saveToPrefs(_prefs);
  }

  /// Toggle contrast mode
  Future<void> setContrastMode(bool enabled) async {
    state = state.copyWith(contrastMode: enabled);
    await state.saveToPrefs(_prefs);
  }

  /// Toggle haptic feedback
  Future<void> setHapticFeedback(bool enabled) async {
    state = state.copyWith(hapticFeedback: enabled);
    await state.saveToPrefs(_prefs);
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    state = const UserPreferences();
    await state.saveToPrefs(_prefs);
  }
}

/// Provider for current theme mode (convenience)
final themeModeProvider = Provider<AppThemeMode>((ref) {
  final prefs = ref.watch(userPreferencesProvider);
  return prefs.contrastMode ? AppThemeMode.contrast : prefs.themeMode;
});

/// Provider for current text scale (convenience)
final textScaleProvider = Provider<double>((ref) {
  return ref.watch(userPreferencesProvider).textScale;
});

/// Provider for current language (convenience)
final languageProvider = Provider<AppLanguage>((ref) {
  return ref.watch(userPreferencesProvider).language;
});
