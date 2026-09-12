import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_sizes.dart';
import '../constants/app_colors.dart';

/// Calculator keypad button with large touch target for elder-friendly use
class KeypadButton extends StatelessWidget {
  const KeypadButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.fontSize,
    this.size = AppSizes.keypadButtonSize,
    this.isAccent = false,
    this.isWide = false,
    this.hapticFeedback = true,
    this.expand = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Widget? child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? fontSize;
  final double size;
  final bool isAccent;
  final bool isWide;
  final bool hapticFeedback;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine colors
    Color bgColor;
    Color fgColor;

    if (isAccent) {
      bgColor = backgroundColor ?? AppColors.primary;
      fgColor = foregroundColor ?? Colors.white;
    } else {
      bgColor =
          backgroundColor ??
          (isDark ? AppColors.keypadButtonDark : AppColors.keypadButton);
      fgColor =
          foregroundColor ??
          (isDark ? AppColors.keypadTextDark : AppColors.keypadText);
    }

    final button = SizedBox(
      height: size,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        elevation: 1,
        child: InkWell(
          onTap: () {
            if (hapticFeedback) {
              HapticFeedback.lightImpact();
            }
            onPressed();
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Center(
            child:
                child ??
                (icon != null
                    ? Icon(icon, size: AppSizes.iconSizeLarge, color: fgColor)
                    : Text(
                        label,
                        style: TextStyle(
                          fontSize: fontSize ?? AppSizes.fontSizeXXLarge,
                          fontWeight: FontWeight.w600,
                          color: fgColor,
                        ),
                      )),
          ),
        ),
      ),
    );

    // Return expanded or fixed size
    if (expand) {
      return Expanded(child: button);
    }
    return SizedBox(
      width: isWide ? size * 2 + AppSizes.keypadSpacing : size,
      child: button,
    );
  }
}

/// Keypad row wrapper - supports expanded buttons
class KeypadRow extends StatelessWidget {
  const KeypadRow({
    super.key,
    required this.children,
    this.spacing = AppSizes.keypadSpacing,
    this.expand = false,
  });

  final List<Widget> children;
  final double spacing;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    if (expand) {
      // Use Row with spacing between expanded children
      return Row(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            Expanded(child: children[i]),
            if (i < children.length - 1) SizedBox(width: spacing),
          ],
        ],
      );
    }

    // Original centered layout
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) SizedBox(width: spacing),
        ],
      ],
    );
  }
}
