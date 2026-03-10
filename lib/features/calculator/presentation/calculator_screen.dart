import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_format.dart';
import '../domain/calc_logic.dart';
import '../domain/bill_item.dart';
import 'widgets/calc_display.dart';
import 'widgets/calc_keypad.dart';
import 'widgets/app_drawer.dart';
import 'widgets/all_items_modal.dart';

/// Main calculator/billing screen
class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calcState = ref.watch(calculatorProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: null,
        actions: [
          // Checkout button with total in app bar
          _AppBarCheckoutButton(
            itemCount: calcState.itemCount,
            totalAmount: calcState.subtotal,
            onPressed: calcState.billItems.isEmpty
                ? null
                : () => context.push('/checkout'),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Items section (at top) - original card design
            _ItemsSection(
              items: calcState.billItems,
              onViewAll: () => _showAllItemsModal(context),
              onDeleteItem: (index) {
                ref.read(calculatorProvider.notifier).removeItem(index);
              },
            ),

            // Spacer pushes calculator to bottom
            const Spacer(),

            // Display (Rate & Qty) - above keypad
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
              ),
              child: const CalcDisplay(),
            ),
            const SizedBox(height: AppSizes.spacingSmall),

            // Keypad - at bottom with original sizing
            Padding(
              padding: const EdgeInsets.only(
                left: AppSizes.paddingMedium,
                right: AppSizes.paddingMedium,
                bottom: AppSizes.paddingSmall,
              ),
              child: const CalcKeypad(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllItemsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AllItemsModal(),
    );
  }
}

/// Compact checkout button for app bar
class _AppBarCheckoutButton extends StatelessWidget {
  const _AppBarCheckoutButton({
    required this.itemCount,
    required this.totalAmount,
    this.onPressed,
  });

  final int itemCount;
  final double totalAmount;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.paddingMedium),
      child: Material(
        color: onPressed != null
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
              vertical: AppSizes.spacingSmall,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cart icon with badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                      size: 20,
                    ),
                    if (itemCount > 0)
                      Positioned(
                        top: -6,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            itemCount > 99 ? '99+' : itemCount.toString(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppSizes.spacingSmall),

                // Total amount
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(totalAmount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSizes.spacingSmall),

                // Arrow
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Items section with original card design
class _ItemsSection extends StatelessWidget {
  const _ItemsSection({
    required this.items,
    required this.onViewAll,
    required this.onDeleteItem,
  });

  final List<BillItem> items;
  final VoidCallback onViewAll;
  final Function(int index) onDeleteItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Empty state
    if (items.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(AppSizes.paddingMedium),
        padding: const EdgeInsets.all(AppSizes.paddingXLarge),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSizes.spacingMedium),
            Text(
              'No items in bill',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              'Enter Rate × Qty and press + to add',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    // Get last 2 items to display
    final displayItems = items.length <= 2
        ? items.asMap().entries.toList()
        : items.asMap().entries.toList().sublist(items.length - 2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Item cards (original design)
        for (final entry in displayItems)
          _ItemCard(
            item: entry.value,
            index: entry.key,
            onDelete: () => onDeleteItem(entry.key),
          ),

        // View All button
        if (items.length > 2)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
            ),
            child: TextButton.icon(
              onPressed: onViewAll,
              icon: const Icon(Icons.list, size: 18),
              label: Text('View All ${items.length} Items'),
            ),
          ),
      ],
    );
  }
}

/// Original item card design with swipe to delete
class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.index,
    required this.onDelete,
  });

  final BillItem item;
  final int index;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.paddingLarge),
        color: AppColors.error,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: AppSizes.iconSizeLarge,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.spacingXSmall,
        ),
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // Item number
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.spacingMedium),

            // Item name
            Expanded(
              child: Text(
                item.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Qty × Rate
            Text(
              '${CurrencyFormatter.formatQuantity(item.quantity)} × ${CurrencyFormatter.formatWithoutSymbol(item.rate)}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(width: AppSizes.spacingMedium),

            // Total
            Text(
              CurrencyFormatter.format(item.total),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
