import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_format.dart';
import '../../domain/calc_logic.dart';

/// Calculator display showing current Qty × Rate = Total
class CalcDisplay extends ConsumerWidget {
  const CalcDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calcState = ref.watch(calculatorProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Qty × Rate row
        Row(
          children: [
            // Rate input
            Expanded(
              child: _InputBox(
                label: 'Rate',
                value: calcState.rateInput.isEmpty
                    ? '0'
                    : calcState.rateInput,
                isActive: calcState.currentMode == CalcInputMode.rate,
                prefix: '₹',
                onTap: () {
                  ref.read(calculatorProvider.notifier).setMode(CalcInputMode.rate);
                },
              ),
            ),

            // Multiplication symbol
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacingMedium,
              ),
              child: Text(
                '×',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Quantity input
            Expanded(
              child: _InputBox(
                label: 'Qty',
                value: calcState.quantityInput.isEmpty
                    ? '0'
                    : calcState.quantityInput,
                isActive: calcState.currentMode == CalcInputMode.quantity,
                onTap: () {
                  ref
                      .read(calculatorProvider.notifier)
                      .setMode(CalcInputMode.quantity);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.spacingSmall),

        // Total row
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: AppSizes.paddingSmall,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Item Total',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              Text(
                CurrencyFormatter.format(calcState.currentTotal),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Individual input box for qty or rate
class _InputBox extends StatelessWidget {
  const _InputBox({
    required this.label,
    required this.value,
    required this.isActive,
    required this.onTap,
    this.prefix,
  });

  final String label;
  final String value;
  final bool isActive;
  final VoidCallback onTap;
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.15)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
            width: 2,
          ),
          boxShadow: isActive
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isActive
                    ? AppColors.primary
                    : theme.textTheme.bodySmall?.color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: AppSizes.spacingXSmall),
            Row(
              children: [
                if (prefix != null)
                  Text(
                    prefix!,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Expanded(
                  child: Text(
                    value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
