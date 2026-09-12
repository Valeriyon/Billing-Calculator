import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/database/tables/invoices.dart';
import '../../domain/invoice_model.dart';

class InvoiceDetailBody extends StatelessWidget {
  const InvoiceDetailBody({super.key, required this.detail});

  final InvoiceDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final invoice = detail.invoice;
    final items = detail.items;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.receipt_long,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSizes.spacingMedium),
                Text(
                  invoice.invoiceNo,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingSmall),
                Text(
                  DateHelpers.formatDateTime(invoice.createdAt),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InvoiceStatusChip.paymentMode(invoice.paymentMode),
                    const SizedBox(width: AppSizes.spacingSmall),
                    InvoiceStatusChip.paymentStatus(invoice.paymentStatus),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spacingXLarge),
          Text(
            'Items (${items.length})',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.spacingMedium),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppSizes.radiusLarge),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text('#', style: theme.textTheme.labelMedium),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('Item', style: theme.textTheme.labelMedium),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Qty × Rate',
                          style: theme.textTheme.labelMedium,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Total',
                          style: theme.textTheme.labelMedium,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                for (int i = 0; i < items.length; i++)
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    decoration: BoxDecoration(
                      border: i < items.length - 1
                          ? Border(
                              bottom: BorderSide(color: theme.dividerColor),
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Text(
                            '${i + 1}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            items[i].itemName,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${CurrencyFormatter.formatQuantity(items[i].quantity)} × ${CurrencyFormatter.formatWithoutSymbol(items[i].rate)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            CurrencyFormatter.format(items[i].total),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spacingXLarge),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                InvoiceSummaryRow(
                  label: 'Subtotal',
                  value: CurrencyFormatter.format(invoice.subtotalAmount),
                ),
                if (invoice.discountAmount > 0) ...[
                  const SizedBox(height: AppSizes.spacingSmall),
                  InvoiceSummaryRow(
                    label: 'Discount',
                    value:
                        '- ${CurrencyFormatter.format(invoice.discountAmount)}',
                    valueColor: AppColors.error,
                  ),
                ],
                const Divider(height: AppSizes.spacingLarge),
                InvoiceSummaryRow(
                  label: 'Grand Total',
                  value: CurrencyFormatter.format(invoice.totalAmount),
                  isTotal: true,
                ),
              ],
            ),
          ),
          if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spacingXLarge),
            Text(
              'Notes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Text(invoice.notes!, style: theme.textTheme.bodyMedium),
            ),
          ],
          const SizedBox(height: AppSizes.spacingXXLarge),
        ],
      ),
    );
  }
}

class InvoiceStatusChip extends StatelessWidget {
  const InvoiceStatusChip._({
    required this.label,
    required this.color,
    required this.icon,
  });

  factory InvoiceStatusChip.paymentMode(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return InvoiceStatusChip._(
          label: 'Cash',
          color: AppColors.cash,
          icon: Icons.money,
        );
      case PaymentMode.upi:
        return InvoiceStatusChip._(
          label: 'UPI',
          color: AppColors.upi,
          icon: Icons.phone_android,
        );
      case PaymentMode.credit:
        return InvoiceStatusChip._(
          label: 'Credit',
          color: AppColors.credit,
          icon: Icons.credit_card,
        );
    }
  }

  factory InvoiceStatusChip.paymentStatus(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.fulfilled:
        return InvoiceStatusChip._(
          label: 'Paid',
          color: AppColors.success,
          icon: Icons.check_circle,
        );
      case PaymentStatus.pending:
        return InvoiceStatusChip._(
          label: 'Pending',
          color: AppColors.warning,
          icon: Icons.pending,
        );
      case PaymentStatus.partial:
        return InvoiceStatusChip._(
          label: 'Partial',
          color: AppColors.info,
          icon: Icons.pie_chart,
        );
    }
  }

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class InvoiceSummaryRow extends StatelessWidget {
  const InvoiceSummaryRow({
    super.key,
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
