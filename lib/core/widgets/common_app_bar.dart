import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
  });

  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? (theme.appBarTheme.backgroundColor ?? colorScheme.surface)
        : colorScheme.surface;
    final foregroundColor = isDark
        ? (theme.appBarTheme.foregroundColor ?? colorScheme.onSurface)
        : colorScheme.onSurface;
    final iconColor = isDark ? colorScheme.onSurface : AppColors.primary;

    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      surfaceTintColor: theme.appBarTheme.surfaceTintColor ?? backgroundColor,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.32 : 0.08),
      scrolledUnderElevation: 2,
      centerTitle: centerTitle,
      leading: leading,
      title: DefaultTextStyle.merge(
        style:
            theme.textTheme.headlineSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.bold,
            ) ??
            TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
        child: title,
      ),
      actions: actions,
      iconTheme: IconThemeData(color: iconColor),
      actionsIconTheme: IconThemeData(color: iconColor),
    );
  }
}
