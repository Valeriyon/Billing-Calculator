import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/database/tables/invoices.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../domain/invoice_model.dart';
import 'providers/invoice_providers.dart';

/// Invoice list screen showing history with filters
class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  bool _isConsolidated = false;
  InvoiceFilter _filter = const InvoiceFilter();

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoiceListProvider(_filter));

    return Scaffold(
      appBar: CommonAppBar(
        title: const Text('Invoice History'),
        actions: [
          IconButton(
            icon: Icon(_isConsolidated ? Icons.list : Icons.calendar_view_day),
            tooltip: _isConsolidated ? 'Detailed View' : 'Consolidated View',
            onPressed: () {
              setState(() => _isConsolidated = !_isConsolidated);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: () => _showFilterSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Excel',
            onPressed: invoicesAsync.maybeWhen(
              data: (invoices) =>
                  invoices.isEmpty ? null : () => _exportExcel(invoices),
              orElse: () => null,
            ),
          ),
        ],
      ),
      body: invoicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load invoices'),
              const SizedBox(height: AppSizes.spacingSmall),
              TextButton(
                onPressed: () => ref.invalidate(invoiceListProvider(_filter)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (invoices) {
          if (invoices.isEmpty) {
            return _EmptyState();
          }
          return _isConsolidated
              ? _ConsolidatedView(invoices: invoices)
              : _DetailedView(invoices: invoices);
        },
      ),
    );
  }

  Future<void> _exportExcel(List<InvoiceModel> invoices) async {
    try {
      await ref.read(invoiceExportServiceProvider).shareExcel(invoices);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterSheet(
        startDate: _filter.startDate,
        endDate: _filter.endDate,
        paymentMode: _filter.paymentMode,
        onApply: (start, end, mode) {
          setState(() {
            _filter = InvoiceFilter(
              startDate: start,
              endDate: end,
              paymentMode: mode,
            );
          });
          Navigator.pop(context);
        },
        onReset: () {
          setState(() => _filter = const InvoiceFilter());
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSizes.spacingLarge),
          Text('No invoices found', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            'Create your first invoice from the calculator',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailedView extends StatelessWidget {
  const _DetailedView({required this.invoices});

  final List<InvoiceModel> invoices;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return _InvoiceTile(invoice: invoice);
      },
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({required this.invoice});

  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSizes.paddingMedium),
        onTap: () => context.push('/invoices/${invoice.id}'),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getPaymentModeColor(
              invoice.paymentMode,
            ).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          child: Icon(
            _getPaymentModeIcon(invoice.paymentMode),
            color: _getPaymentModeColor(invoice.paymentMode),
          ),
        ),
        title: Text(
          invoice.invoiceNo,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.spacingXSmall),
            Text(DateHelpers.formatDateTime(invoice.createdAt)),
            const SizedBox(height: AppSizes.spacingXSmall),
            Row(
              children: [
                _PaymentChip(mode: invoice.paymentMode),
                if (invoice.paymentStatus == PaymentStatus.pending) ...[
                  const SizedBox(width: AppSizes.spacingSmall),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'PENDING',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Text(
          CurrencyFormatter.format(invoice.totalAmount),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
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
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({required this.mode});

  final PaymentMode mode;

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getLabel(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _getLabel() {
    switch (mode) {
      case PaymentMode.cash:
        return 'CASH';
      case PaymentMode.upi:
        return 'UPI';
      case PaymentMode.credit:
        return 'CREDIT';
    }
  }

  Color _getColor() {
    switch (mode) {
      case PaymentMode.cash:
        return AppColors.cash;
      case PaymentMode.upi:
        return AppColors.upi;
      case PaymentMode.credit:
        return AppColors.credit;
    }
  }
}

class _ConsolidatedView extends StatelessWidget {
  const _ConsolidatedView({required this.invoices});

  final List<InvoiceModel> invoices;

  @override
  Widget build(BuildContext context) {
    // Group invoices by date
    final groupedInvoices = <DateTime, List<InvoiceModel>>{};
    for (final invoice in invoices) {
      final date = DateHelpers.startOfDay(invoice.createdAt);
      groupedInvoices.putIfAbsent(date, () => []).add(invoice);
    }

    final sortedDates = groupedInvoices.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dayInvoices = groupedInvoices[date]!;
        final total = dayInvoices.fold(
          0.0,
          (sum, inv) => sum + inv.totalAmount,
        );

        return _DaySummaryTile(
          date: date,
          invoiceCount: dayInvoices.length,
          totalAmount: total,
          invoices: dayInvoices,
        );
      },
    );
  }
}

class _DaySummaryTile extends StatelessWidget {
  const _DaySummaryTile({
    required this.date,
    required this.invoiceCount,
    required this.totalAmount,
    required this.invoices,
  });

  final DateTime date;
  final int invoiceCount;
  final double totalAmount;
  final List<InvoiceModel> invoices;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          child: const Icon(Icons.calendar_today, color: AppColors.primary),
        ),
        title: Text(
          DateHelpers.getRelativeDate(date),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text('$invoiceCount invoices'),
        trailing: Text(
          CurrencyFormatter.format(totalAmount),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        children: [
          for (final invoice in invoices)
            ListTile(
              dense: true,
              leading: _PaymentChip(mode: invoice.paymentMode),
              title: Text(invoice.invoiceNo),
              trailing: Text(CurrencyFormatter.format(invoice.totalAmount)),
              onTap: () => context.push('/invoices/${invoice.id}'),
            ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    this.startDate,
    this.endDate,
    this.paymentMode,
    required this.onApply,
    required this.onReset,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final PaymentMode? paymentMode;
  final Function(DateTime?, DateTime?, PaymentMode?) onApply;
  final VoidCallback onReset;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late PaymentMode? _paymentMode;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _paymentMode = widget.paymentMode;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filter Invoices',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.spacingXLarge),

          // Date Range
          Text('Date Range', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSizes.spacingSmall),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    _startDate != null
                        ? DateHelpers.formatDateShort(_startDate!)
                        : 'Start Date',
                  ),
                  onPressed: () => _selectDate(true),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('to'),
              ),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    _endDate != null
                        ? DateHelpers.formatDateShort(_endDate!)
                        : 'End Date',
                  ),
                  onPressed: () => _selectDate(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingLarge),

          // Quick date options
          Wrap(
            spacing: AppSizes.spacingSmall,
            children: [
              ActionChip(
                label: const Text('Today'),
                onPressed: () {
                  final now = DateTime.now();
                  setState(() {
                    _startDate = DateHelpers.startOfDay(now);
                    _endDate = DateHelpers.endOfDay(now);
                  });
                },
              ),
              ActionChip(
                label: const Text('This Week'),
                onPressed: () {
                  final now = DateTime.now();
                  setState(() {
                    _startDate = DateHelpers.startOfWeek(now);
                    _endDate = DateHelpers.endOfWeek(now);
                  });
                },
              ),
              ActionChip(
                label: const Text('This Month'),
                onPressed: () {
                  final now = DateTime.now();
                  setState(() {
                    _startDate = DateHelpers.startOfMonth(now);
                    _endDate = DateHelpers.endOfMonth(now);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingLarge),

          // Payment Mode
          Text('Payment Mode', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSizes.spacingSmall),
          Wrap(
            spacing: AppSizes.spacingSmall,
            children: [
              FilterChip(
                label: const Text('Cash'),
                selected: _paymentMode == PaymentMode.cash,
                onSelected: (selected) {
                  setState(() {
                    _paymentMode = selected ? PaymentMode.cash : null;
                  });
                },
              ),
              FilterChip(
                label: const Text('UPI'),
                selected: _paymentMode == PaymentMode.upi,
                onSelected: (selected) {
                  setState(() {
                    _paymentMode = selected ? PaymentMode.upi : null;
                  });
                },
              ),
              FilterChip(
                label: const Text('Credit'),
                selected: _paymentMode == PaymentMode.credit,
                onSelected: (selected) {
                  setState(() {
                    _paymentMode = selected ? PaymentMode.credit : null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingXLarge),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onReset,
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: AppSizes.spacingMedium),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () =>
                      widget.onApply(_startDate, _endDate, _paymentMode),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingLarge),
        ],
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }
}
