import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/serial_number.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/tables/invoices.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../calculator/domain/calc_logic.dart';
import '../../calculator/domain/bill_item.dart';
import 'package:drift/drift.dart' hide Column;

/// Checkout screen for reviewing and saving invoice
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  PaymentMode _selectedPaymentMode = PaymentMode.cash;
  double _discountAmount = 0.0;
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calcState = ref.watch(calculatorProvider);
    final theme = Theme.of(context);

    if (calcState.billItems.isEmpty) {
      return Scaffold(
        appBar: const CommonAppBar(title: Text('Checkout')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: AppSizes.spacingLarge),
              Text('Your cart is empty', style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSizes.spacingLarge),
              AppButton(
                label: 'Go Back',
                onPressed: () => context.pop(),
                width: 200,
              ),
            ],
          ),
        ),
      );
    }

    final subtotal = calcState.subtotal;
    final discountValue = _discountAmount;
    final grandTotal = subtotal - discountValue;

    return Scaffold(
      appBar: CommonAppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bill Items Section
            _SectionCard(
              title: 'Bill Items',
              trailing: Text(
                '${calcState.itemCount} items',
                style: theme.textTheme.bodySmall,
              ),
              child: Column(
                children: [
                  for (int i = 0; i < calcState.billItems.length; i++)
                    _CheckoutItemTile(item: calcState.billItems[i], index: i),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacingLarge),

            // Discount Section
            _SectionCard(
              title: 'Discount',
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Enter discount',
                        prefixText: '₹ ',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _discountAmount = double.tryParse(value) ?? 0.0;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacingLarge),

            // // Payment Mode Section
            // _SectionCard(
            //   title: 'Payment Mode',
            //   child: Row(
            //     children: [
            //       _PaymentModeChip(
            //         label: 'Cash',
            //         icon: Icons.money,
            //         color: AppColors.cash,
            //         isSelected: _selectedPaymentMode == PaymentMode.cash,
            //         onTap: () =>
            //             setState(() => _selectedPaymentMode = PaymentMode.cash),
            //       ),
            //       const SizedBox(width: AppSizes.spacingSmall),
            //       _PaymentModeChip(
            //         label: 'UPI',
            //         icon: Icons.phone_android,
            //         color: AppColors.upi,
            //         isSelected: _selectedPaymentMode == PaymentMode.upi,
            //         onTap: () =>
            //             setState(() => _selectedPaymentMode = PaymentMode.upi),
            //       ),
            //       const SizedBox(width: AppSizes.spacingSmall),
            //       _PaymentModeChip(
            //         label: 'Credit',
            //         icon: Icons.credit_card,
            //         color: AppColors.credit,
            //         isSelected: _selectedPaymentMode == PaymentMode.credit,
            //         onTap: () => setState(
            //           () => _selectedPaymentMode = PaymentMode.credit,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: AppSizes.spacingLarge),

            // // Notes Section
            // _SectionCard(
            //   title: 'Notes (Optional)',
            //   child: TextField(
            //     controller: _notesController,
            //     maxLines: 2,
            //     decoration: const InputDecoration(hintText: 'Add any notes...'),
            //   ),
            // ),
            // const SizedBox(height: AppSizes.spacingXLarge),

            // Summary Section
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Subtotal',
                    value: CurrencyFormatter.format(subtotal),
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  _SummaryRow(
                    label: 'Discount',
                    value: '- ${CurrencyFormatter.format(discountValue)}',
                    valueColor: AppColors.error,
                  ),
                  const Divider(height: AppSizes.spacingLarge),
                  _SummaryRow(
                    label: 'Grand Total',
                    value: CurrencyFormatter.format(grandTotal),
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacingXLarge),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Cancel',
                    isOutlined: true,
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingMedium),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    label: 'Confirm & Save',
                    icon: Icons.check_circle,
                    isLoading: _isSaving,
                    height: AppSizes.buttonHeightLarge,
                    onPressed: () => _saveInvoice(
                      calcState.billItems,
                      subtotal,
                      discountValue,
                      grandTotal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingMedium),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Print Bill',
                icon: Icons.print,
                isOutlined: true,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Print feature coming soon!')),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.spacingXLarge),
          ],
        ),
      ),
    );
  }

  Future<void> _saveInvoice(
    List<BillItem> items,
    double subtotal,
    double discount,
    double grandTotal,
  ) async {
    setState(() => _isSaving = true);

    try {
      final db = ref.read(databaseProvider);
      final now = DateTime.now();

      // Get next invoice number
      final count = await db.getInvoiceCountForDate(now);
      final invoiceNo = SerialNumberGenerator.generateInvoiceNumber(
        now,
        count + 1,
      );

      // Insert invoice
      final invoiceId = await db.insertInvoice(
        InvoicesCompanion.insert(
          invoiceNo: invoiceNo,
          subtotalAmount: Value(subtotal),
          discountAmount: Value(discount),
          totalAmount: Value(grandTotal),
          paymentMode: _selectedPaymentMode,
          paymentStatus: _selectedPaymentMode == PaymentMode.credit
              ? PaymentStatus.pending
              : PaymentStatus.fulfilled,
          notes: Value(
            _notesController.text.isEmpty ? null : _notesController.text,
          ),
        ),
      );

      // Insert invoice items
      final invoiceItems = items.asMap().entries.map((entry) {
        return InvoiceItemsCompanion.insert(
          invoiceId: invoiceId,
          itemName: entry.value.name,
          quantity: entry.value.quantity,
          rate: entry.value.rate,
          total: entry.value.total,
          serialNo: Value(entry.key + 1),
        );
      }).toList();

      await db.insertInvoiceItems(invoiceItems);

      // Clear the calculator
      ref.read(calculatorProvider.notifier).clearBill();

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice $invoiceNo saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Go back to calculator
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving invoice: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: AppSizes.spacingMedium),
        child,
      ],
    );
  }
}

class _CheckoutItemTile extends StatelessWidget {
  const _CheckoutItemTile({required this.item, required this.index});

  final BillItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingSmall),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: theme.textTheme.titleSmall),
                Text(
                  '${CurrencyFormatter.formatQuantity(item.quantity)} × ${CurrencyFormatter.format(item.rate)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(item.total),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                )
              : theme.textTheme.bodyLarge,
        ),
        Text(
          value,
          style: isTotal
              ? theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                )
              : theme.textTheme.titleMedium?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }
}
