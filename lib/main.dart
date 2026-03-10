import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/router/app_router.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'core/theme/contrast_theme.dart';
import 'core/providers/app_providers.dart';
import 'features/settings/domain/preferences_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const BillingApp(),
    ),
  );
}

/// Main application widget
class BillingApp extends ConsumerWidget {
  const BillingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPrefs = ref.watch(userPreferencesProvider);
    final effectiveThemeMode = ref.watch(themeModeProvider);
    final textScale = userPrefs.textScale;

    // Select theme based on mode
    ThemeData theme;
    switch (effectiveThemeMode) {
      case AppThemeMode.light:
        theme = lightTheme(textScale: textScale);
        break;
      case AppThemeMode.dark:
        theme = darkTheme(textScale: textScale);
        break;
      case AppThemeMode.contrast:
        theme = contrastTheme(textScale: textScale);
        break;
    }

    return MaterialApp.router(
      title: 'Store Billing',
      debugShowCheckedModeBanner: false,
      theme: theme,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
      locale: userPrefs.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ml'),
        Locale('hi'),
        Locale('ta'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
