import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/keypad_button.dart';
import '../../domain/calc_logic.dart';

/// Calculator keypad with numbers, operators, and actions
/// Buttons expand to fill available width
class CalcKeypad extends ConsumerWidget {
  const CalcKeypad({super.key, this.buttonHeight});

  final double? buttonHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calcNotifier = ref.read(calculatorProvider.notifier);
    final calcState = ref.watch(calculatorProvider);
    final height = buttonHeight ?? AppSizes.keypadButtonSize;

    Widget buildCol(List<_KeypadButtonData> buttons) {
      return Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < buttons.length; i++) ...[
              _buildButton(buttons[i], height),
              if (i < buttons.length - 1)
                const SizedBox(height: AppSizes.keypadSpacing),
            ],
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Col 1: 7, 4, 1, C
        buildCol([
          _KeypadButtonData(
            label: '7',
            onPressed: () => calcNotifier.appendDigit('7'),
          ),
          _KeypadButtonData(
            label: '4',
            onPressed: () => calcNotifier.appendDigit('4'),
          ),
          _KeypadButtonData(
            label: '1',
            onPressed: () => calcNotifier.appendDigit('1'),
          ),
          _KeypadButtonData(label: 'C', onPressed: calcNotifier.clearInput),
        ]),
        const SizedBox(width: AppSizes.keypadSpacing),

        // Col 2: 8, 5, 2, 0
        buildCol([
          _KeypadButtonData(
            label: '8',
            onPressed: () => calcNotifier.appendDigit('8'),
          ),
          _KeypadButtonData(
            label: '5',
            onPressed: () => calcNotifier.appendDigit('5'),
          ),
          _KeypadButtonData(
            label: '2',
            onPressed: () => calcNotifier.appendDigit('2'),
          ),
          _KeypadButtonData(
            label: '0',
            onPressed: () => calcNotifier.appendDigit('0'),
          ),
        ]),
        const SizedBox(width: AppSizes.keypadSpacing),

        // Col 3: 9, 6, 3, .
        buildCol([
          _KeypadButtonData(
            label: '9',
            onPressed: () => calcNotifier.appendDigit('9'),
          ),
          _KeypadButtonData(
            label: '6',
            onPressed: () => calcNotifier.appendDigit('6'),
          ),
          _KeypadButtonData(
            label: '3',
            onPressed: () => calcNotifier.appendDigit('3'),
          ),
          _KeypadButtonData(
            label: '.',
            onPressed: () => calcNotifier.appendDigit('.'),
          ),
        ]),
        const SizedBox(width: AppSizes.keypadSpacing),

        // Col 4: Backspace, Rate/Qty (span 2), +
        buildCol([
          _KeypadButtonData(
            label: '',
            icon: Icons.backspace_outlined,
            onPressed: calcNotifier.backspace,
          ),
          _KeypadButtonData(
            label: '',
            customHeight: height * 2 + AppSizes.keypadSpacing,
            isAccent: true,
            onPressed: calcNotifier.toggleMode,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  calcState.currentMode == CalcInputMode.quantity
                      ? 'Rate'
                      : 'Qty',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.close,
                  size: AppSizes.iconSizeMedium,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ],
            ),
          ),
          _KeypadButtonData(
            label: '+',
            isAccent: true,
            fontSize: AppSizes.fontSizeDisplay,
            onPressed: calcState.canAddItem ? calcNotifier.addItem : () {},
          ),
        ]),
      ],
    );
  }

  Widget _buildButton(_KeypadButtonData data, double baseHeight) {
    return KeypadButton(
      label: data.label,
      icon: data.icon,
      child: data.child,
      onPressed: data.onPressed,
      isAccent: data.isAccent,
      fontSize: data.fontSize,
      size: data.customHeight ?? baseHeight,
    );
  }
}

/// Data class for keypad button configuration
class _KeypadButtonData {
  const _KeypadButtonData({
    required this.label,
    required this.onPressed,
    this.icon,
    this.child,
    this.customHeight,
    this.isAccent = false,
    this.fontSize,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Widget? child;
  final double? customHeight;
  final bool isAccent;
  final double? fontSize;
}
