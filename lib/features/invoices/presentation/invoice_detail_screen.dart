import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/tables/invoices.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/common_app_bar.dart';

/// Invoice detail screen showing full invoice information
class InvoiceDetailScreen extends ConsumerStatefulWidget {
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  final int invoiceId;

  @override
  ConsumerState<InvoiceDetailScreen> createState() =>
      _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  Invoice? _invoice;
  List<InvoiceItem>? _items;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    final db = ref.read(databaseProvider);
    final invoice = await db.getInvoiceById(widget.invoiceId);
    List<InvoiceItem>? items;

    if (invoice != null) {
      items = await db.getItemsForInvoice(invoice.id);
    }

    setState(() {
      _invoice = invoice;
      _items = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: const CommonAppBar(title: Text('Invoice')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_invoice == null) {
      return Scaffold(
        appBar: const CommonAppBar(title: Text('Invoice')),
        body: const Center(child: Text('Invoice not found')),
      );
    }

    final invoice = _invoice!;
    final items = _items ?? [];
    return Scaffold(
      appBar: CommonAppBar(
        title: Text(invoice.invoiceNo),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Print feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Invoice Header
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
                      _StatusChip(
                        label: _getPaymentModeLabel(invoice.paymentMode),
                        color: _getPaymentModeColor(invoice.paymentMode),
                        icon: _getPaymentModeIcon(invoice.paymentMode),
                      ),
                      const SizedBox(width: AppSizes.spacingSmall),
                      _StatusChip(
                        label: _getPaymentStatusLabel(invoice.paymentStatus),
                        color: _getPaymentStatusColor(invoice.paymentStatus),
                        icon: _getPaymentStatusIcon(invoice.paymentStatus),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacingXLarge),

            // Items Section
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
                  // Header row
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
                          child: Text(
                            'Item',
                            style: theme.textTheme.labelMedium,
                          ),
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
                  // Item rows
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

            // Summary Section
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Subtotal',
                    value: CurrencyFormatter.format(invoice.subtotalAmount),
                  ),
                  if (invoice.discountAmount > 0) ...[
                    const SizedBox(height: AppSizes.spacingSmall),
                    _SummaryRow(
                      label: 'Discount',
                      value:
                          '- ${CurrencyFormatter.format(invoice.discountAmount)}',
                      valueColor: AppColors.error,
                    ),
                  ],
                  const Divider(height: AppSizes.spacingLarge),
                  _SummaryRow(
                    label: 'Grand Total',
                    value: CurrencyFormatter.format(invoice.totalAmount),
                    isTotal: true,
                  ),
                ],
              ),
            ),

            // Notes
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
      ),
    );
  }

  String _getPaymentModeLabel(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return 'Cash';
      case PaymentMode.upi:
        return 'UPI';
      case PaymentMode.credit:
        return 'Credit';
    }
  }

  Color _getPaymentModeColor(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return AppColors.cash;
      case PaymentMode.upi:
        return AppColors.upi;
      case PaymentMode.credit:
        return AppColors.credit;
    }
  }

  IconData _getPaymentModeIcon(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return Icons.money;
      case PaymentMode.upi:
        return Icons.phone_android;
      case PaymentMode.credit:
        return Icons.credit_card;
    }
  }

  String _getPaymentStatusLabel(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.fulfilled:
        return 'Paid';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.partial:
        return 'Partial';
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.fulfilled:
        return AppColors.success;
      case PaymentStatus.pending:
        return AppColors.warning;
      case PaymentStatus.partial:
        return AppColors.info;
    }
  }

  IconData _getPaymentStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.fulfilled:
        return Icons.check_circle;
      case PaymentStatus.pending:
        return Icons.pending;
      case PaymentStatus.partial:
        return Icons.pie_chart;
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.icon,
  });

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
