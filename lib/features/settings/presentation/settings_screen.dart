import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../settings/domain/preferences_model.dart';

/// Settings screen for theme, language, and accessibility options
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final prefsNotifier = ref.read(userPreferencesProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CommonAppBar(title: Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        children: [
          // Theme Section
          _SettingsSection(
            title: 'Appearance',
            children: [
              _SettingsTile(
                icon: Icons.light_mode,
                title: 'Theme',
                subtitle: _getThemeName(prefs.themeMode),
                onTap: () =>
                    _showThemeDialog(context, prefs.themeMode, prefsNotifier),
              ),
              _SettingsTile(
                icon: Icons.contrast,
                title: 'High Contrast Mode',
                subtitle: 'Enhanced visibility for accessibility',
                trailing: Switch(
                  value: prefs.contrastMode,
                  onChanged: (value) => prefsNotifier.setContrastMode(value),
                  activeThumbColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingLarge),

          // Text Size Section
          _SettingsSection(
            title: 'Text Size',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLarge,
                  vertical: AppSizes.paddingMedium,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('A', style: TextStyle(fontSize: 14)),
                        Text(
                          '${(prefs.textScale * 100).round()}%',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const Text('A', style: TextStyle(fontSize: 24)),
                      ],
                    ),
                    Slider(
                      value: prefs.textScale,
                      min: AppSizes.textScaleMin,
                      max: AppSizes.textScaleMax,
                      divisions: 6,
                      activeColor: AppColors.primary,
                      onChanged: (value) => prefsNotifier.setTextScale(value),
                    ),
                    // Preview text
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMedium,
                        ),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Text(
                        'Preview: This is how text will appear in the app.',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingLarge),

          // Language Section
          _SettingsSection(
            title: 'Language',
            children: [
              for (final lang in AppLanguage.values)
                _SettingsTile(
                  icon: Icons.language,
                  title: lang.displayName,
                  trailing: prefs.language == lang
                      ? Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () => prefsNotifier.setLanguage(lang),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingLarge),

          // Haptic Feedback
          _SettingsSection(
            title: 'Feedback',
            children: [
              _SettingsTile(
                icon: Icons.vibration,
                title: 'Haptic Feedback',
                subtitle: 'Vibrate on button press',
                trailing: Switch(
                  value: prefs.hapticFeedback,
                  onChanged: (value) => prefsNotifier.setHapticFeedback(value),
                  activeThumbColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingXLarge),

          // App Info
          Center(
            child: Column(
              children: [
                Text('Store Billing v1.0.0', style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSizes.spacingXSmall),
                Text(
                  'Made with ❤️',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spacingXLarge),
        ],
      ),
    );
  }

  String _getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.contrast:
        return 'High Contrast';
    }
  }

  void _showThemeDialog(
    BuildContext context,
    AppThemeMode current,
    UserPreferencesNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(
              icon: Icons.light_mode,
              label: 'Light',
              isSelected: current == AppThemeMode.light,
              onTap: () {
                notifier.setThemeMode(AppThemeMode.light);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            _ThemeOption(
              icon: Icons.dark_mode,
              label: 'Dark',
              isSelected: current == AppThemeMode.dark,
              onTap: () {
                notifier.setThemeMode(AppThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSizes.paddingSmall,
            bottom: AppSizes.spacingSmall,
          ),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle!, style: theme.textTheme.bodySmall)
          : null,
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : null),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
    );
  }
}
