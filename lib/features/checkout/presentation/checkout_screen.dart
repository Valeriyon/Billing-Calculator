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
import '../../../core/widgets/top_notification_banner.dart';
import '../../calculator/domain/calc_logic.dart';
import '../../calculator/domain/bill_item.dart';
import '../../settings/domain/preferences_model.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:qr_flutter/qr_flutter.dart';

/// Checkout screen for reviewing and saving invoice
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  PaymentMode _selectedPaymentMode = PaymentMode.cash;
  int? _selectedCustomerId;
  double _discountAmount = 0.0;
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Handle payment mode restrictions once during initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validatePaymentModeRestrictions();
    });
  }

  void _validatePaymentModeRestrictions() {
    if (!mounted) return;

    final prefs = ref.read(userPreferencesProvider);
    final creditPaymentEnabled = prefs.creditPaymentEnabled;
    final upiPaymentEnabled = prefs.upiPaymentEnabled;

    bool needsReset = false;

    if (!creditPaymentEnabled && _selectedPaymentMode == PaymentMode.credit) {
      _selectedPaymentMode = PaymentMode.cash;
      _selectedCustomerId = null;
      needsReset = true;
    }

    if (!upiPaymentEnabled && _selectedPaymentMode == PaymentMode.upi) {
      _selectedPaymentMode = PaymentMode.cash;
      _selectedCustomerId = null;
      needsReset = true;
    }

    if (needsReset && mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(CheckoutScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Revalidate when preferences change
    _validatePaymentModeRestrictions();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calcState = ref.watch(calculatorProvider);
    final prefs = ref.watch(userPreferencesProvider);
    final theme = Theme.of(context);
    final creditPaymentEnabled = prefs.creditPaymentEnabled;
    final upiPaymentEnabled = prefs.upiPaymentEnabled;

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

            // Payment Mode Section
            _SectionCard(
              title: 'Payment Mode',
              child: Wrap(
                spacing: AppSizes.spacingSmall,
                runSpacing: AppSizes.spacingSmall,
                children: [
                  _PaymentModeChip(
                    label: 'Cash',
                    icon: Icons.money,
                    color: AppColors.cash,
                    isSelected: _selectedPaymentMode == PaymentMode.cash,
                    onTap: () {
                      setState(() {
                        _selectedPaymentMode = PaymentMode.cash;
                        _selectedCustomerId = null;
                      });
                    },
                  ),
                  if (upiPaymentEnabled)
                    _PaymentModeChip(
                      label: 'UPI',
                      icon: Icons.phone_android,
                      color: AppColors.upi,
                      isSelected: _selectedPaymentMode == PaymentMode.upi,
                      onTap: () {
                        setState(() {
                          _selectedPaymentMode = PaymentMode.upi;
                          _selectedCustomerId = null;
                        });
                      },
                    ),
                  if (creditPaymentEnabled)
                    _PaymentModeChip(
                      label: 'Credit',
                      icon: Icons.credit_card,
                      color: AppColors.credit,
                      isSelected: _selectedPaymentMode == PaymentMode.credit,
                      onTap: () {
                        setState(() {
                          _selectedPaymentMode = PaymentMode.credit;
                        });
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacingLarge),

            if (creditPaymentEnabled &&
                _selectedPaymentMode == PaymentMode.credit) ...[
              _SectionCard(
                title: 'Customer',
                trailing: TextButton.icon(
                  onPressed: () => _showAddCustomerModal(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                child: StreamBuilder<List<Customer>>(
                  stream: ref.watch(databaseProvider).watchAllCustomers(),
                  builder: (context, snapshot) {
                    final customers = snapshot.data ?? const <Customer>[];

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSizes.paddingMedium,
                        ),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (customers.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No customers found. Add a customer from Manage Customers first.',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppSizes.spacingSmall),
                          TextButton.icon(
                            onPressed: () => _showAddCustomerModal(context),
                            icon: const Icon(Icons.person_add_alt_1),
                            label: const Text('Add Customer'),
                          ),
                        ],
                      );
                    }

                    final hasSelection = customers.any(
                      (c) => c.id == _selectedCustomerId,
                    );
                    final selectedValue = hasSelection
                        ? _selectedCustomerId
                        : null;
                    Customer? selectedCustomer;
                    for (final customer in customers) {
                      if (customer.id == selectedValue) {
                        selectedCustomer = customer;
                        break;
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<int>(
                          initialValue: selectedValue,
                          decoration: const InputDecoration(
                            labelText: 'Select customer *',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          items: customers
                              .map(
                                (customer) => DropdownMenuItem<int>(
                                  value: customer.id,
                                  child: Text(
                                    customer.phone == null ||
                                            customer.phone!.isEmpty
                                        ? customer.name
                                        : '${customer.name} (${customer.phone})',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCustomerId = value;
                            });
                          },
                        ),
                        if (selectedCustomer != null) ...[
                          const SizedBox(height: AppSizes.spacingMedium),
                          _CustomerCreditSummary(
                            customer: selectedCustomer,
                            projectedPurchaseAmount: grandTotal,
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSizes.spacingLarge),
            ],

            // Notes Section
            _SectionCard(
              title: 'Notes (Optional)',
              child: TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(hintText: 'Add any notes...'),
              ),
            ),
            const SizedBox(height: AppSizes.spacingXLarge),

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
                    onPressed: () => _handleConfirmAndSave(
                      calcState.billItems,
                      subtotal,
                      discountValue,
                      grandTotal,
                      prefs,
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

  Future<void> _showAddCustomerModal(BuildContext context) async {
    final customerId = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const _AddCustomerModal();
      },
    );

    if (customerId != null && context.mounted) {
      setState(() {
        _selectedCustomerId = customerId;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer added and selected')),
      );
    }
  }

  Future<void> _saveInvoice(
    List<BillItem> items,
    double subtotal,
    double discount,
    double grandTotal,
  ) async {
    if (_selectedPaymentMode == PaymentMode.credit &&
        _selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer for credit payment'),
        ),
      );
      return;
    }

    if (_selectedPaymentMode == PaymentMode.credit) {
      final db = ref.read(databaseProvider);
      final customer = await db.getCustomerById(_selectedCustomerId!);

      if (!mounted) {
        return;
      }

      if (customer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected customer was not found')),
        );
        return;
      }

      final projectedDue = customer.creditDue + grandTotal;
      if (projectedDue > customer.creditLimit) {
        final shouldContinue = await _confirmOverCreditLimit(
          customer: customer,
          projectedDue: projectedDue,
          invoiceAmount: grandTotal,
        );

        if (!shouldContinue) {
          return;
        }
      }
    }

    setState(() => _isSaving = true);

    try {
      final db = ref.read(databaseProvider);
      final paymentState = _resolvePaymentState(grandTotal);
      late final String invoiceNo;

      await db.transaction(() async {
        final now = DateTime.now();

        final count = await db.getInvoiceCountForDate(now);
        invoiceNo = SerialNumberGenerator.generateInvoiceNumber(now, count + 1);

        final invoiceId = await db.insertInvoice(
          InvoicesCompanion.insert(
            invoiceNo: invoiceNo,
            subtotalAmount: Value(subtotal),
            discountAmount: Value(discount),
            totalAmount: Value(grandTotal),
            paidAmount: Value(paymentState.paidAmount),
            paymentMode: _selectedPaymentMode,
            paymentStatus: paymentState.paymentStatus,
            customerId: Value(
              _selectedPaymentMode == PaymentMode.credit
                  ? _selectedCustomerId
                  : null,
            ),
            notes: Value(
              _notesController.text.isEmpty ? null : _notesController.text,
            ),
          ),
        );

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

        if (_selectedPaymentMode == PaymentMode.credit) {
          final customer = await db.getCustomerById(_selectedCustomerId!);
          if (customer == null) {
            throw StateError('Selected customer was not found');
          }

          final balanceDue = grandTotal - paymentState.paidAmount;
          final didUpdate = await db.updateCustomer(
            customer.copyWith(creditDue: customer.creditDue + balanceDue),
          );
          if (!didUpdate) {
            throw StateError('Unable to update customer credit balance');
          }
        }
      });

      // Clear the calculator
      ref.read(calculatorProvider.notifier).clearBill();

      if (mounted) {
        // Show success message near the top so it stays visible after navigation.
        showTopNotification(
          context,
          message: 'Invoice $invoiceNo saved successfully!',
          backgroundColor: AppColors.success,
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

  ({double paidAmount, PaymentStatus paymentStatus}) _resolvePaymentState(
    double grandTotal,
  ) {
    switch (_selectedPaymentMode) {
      case PaymentMode.cash:
      case PaymentMode.upi:
        return (paidAmount: grandTotal, paymentStatus: PaymentStatus.fulfilled);
      case PaymentMode.credit:
        return (paidAmount: 0.0, paymentStatus: PaymentStatus.pending);
    }
  }

  Future<bool> _confirmOverCreditLimit({
    required Customer customer,
    required double projectedDue,
    required double invoiceAmount,
  }) async {
    final overBy = projectedDue - customer.creditLimit;
    final shouldContinue = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Credit limit exceeded'),
          content: Text(
            '${customer.name} will exceed the credit limit by ${CurrencyFormatter.format(overBy)}.\n\n'
            'Current due: ${CurrencyFormatter.format(customer.creditDue)}\n'
            'This bill: ${CurrencyFormatter.format(invoiceAmount)}\n'
            'Projected due: ${CurrencyFormatter.format(projectedDue)}\n'
            'Limit: ${CurrencyFormatter.format(customer.creditLimit)}\n\n'
            'Continue anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    return shouldContinue == true;
  }

  Future<void> _handleConfirmAndSave(
    List<BillItem> items,
    double subtotal,
    double discount,
    double grandTotal,
    UserPreferences prefs,
  ) async {
    if (_selectedPaymentMode != PaymentMode.upi) {
      await _saveInvoice(items, subtotal, discount, grandTotal);
      return;
    }

    if (!prefs.upiPaymentEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('UPI payment is disabled in settings')),
      );
      return;
    }

    final upiId = prefs.upiId.trim();
    if (!_isValidUpiId(upiId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Set a valid UPI ID in Settings before using UPI'),
        ),
      );
      return;
    }

    final paymentDone = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _UpiQrPaymentScreen(amount: grandTotal, upiId: upiId),
      ),
    );

    if (paymentDone != true || !mounted) {
      return;
    }

    await _saveInvoice(items, subtotal, discount, grandTotal);
  }

  bool _isValidUpiId(String value) {
    return value.contains('@') && value.length >= 5;
  }
}

class _CustomerCreditSummary extends StatelessWidget {
  const _CustomerCreditSummary({
    required this.customer,
    required this.projectedPurchaseAmount,
  });

  final Customer customer;
  final double projectedPurchaseAmount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dueAfterBill = customer.creditDue + projectedPurchaseAmount;
    final remainingAfterBill = customer.creditLimit - dueAfterBill;
    final isOverLimit = dueAfterBill > customer.creditLimit;
    final isLow =
        !isOverLimit && remainingAfterBill <= (customer.creditLimit * 0.2);
    final warningColor = isOverLimit
        ? AppColors.error
        : isLow
        ? Colors.orange.shade700
        : AppColors.success;
    final warningText = isOverLimit
        ? 'Credit limit exceeded'
        : isLow
        ? 'Credit limit is running low'
        : null;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: warningColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: warningColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current due: ${CurrencyFormatter.format(customer.creditDue)}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            'Credit limit: ${CurrencyFormatter.format(customer.creditLimit)}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            'After this bill: ${CurrencyFormatter.format(dueAfterBill)}',
            style: theme.textTheme.bodyMedium,
          ),
          if (warningText != null) ...[
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              warningText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: warningColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (isOverLimit) ...[
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              'Over by ${CurrencyFormatter.format(dueAfterBill - customer.creditLimit)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: warningColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UpiQrPaymentScreen extends StatelessWidget {
  const _UpiQrPaymentScreen({required this.amount, required this.upiId});

  final double amount;
  final String upiId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final upiUri = Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': upiId,
        'pn': 'Store Billing',
        'am': amount.toStringAsFixed(2),
        'cu': 'INR',
        'tn': 'Invoice Payment',
      },
    ).toString();

    return Scaffold(
      appBar: AppBar(title: const Text('UPI Payment')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ask customer to scan and pay',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              Text(
                'Amount: ${CurrencyFormatter.format(amount)}',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.spacingLarge),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: QrImageView(
                    data: upiUri,
                    version: QrVersions.auto,
                    size: 240,
                    gapless: false,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacingMedium),
              Text(
                'UPI ID: $upiId',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Cancel',
                      isOutlined: true,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingMedium),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: 'Payment Received',
                      icon: Icons.check_circle,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentModeChip extends StatelessWidget {
  const _PaymentModeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: isSelected,
      onSelected: (_) => onTap(),
      avatar: Icon(icon, size: 18, color: isSelected ? Colors.white : color),
      label: Text(label),
      selectedColor: color,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: color.withValues(alpha: 0.5)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
    );
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

class _AddCustomerModal extends ConsumerStatefulWidget {
  const _AddCustomerModal();

  @override
  ConsumerState<_AddCustomerModal> createState() => _AddCustomerModalState();
}

class _AddCustomerModalState extends ConsumerState<_AddCustomerModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });

      final db = ref.read(databaseProvider);
      final customerId = await db.createCustomerWithLedger(
        customerName: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(customerId);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding customer: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Customer'),
      contentPadding: const EdgeInsets.all(AppSizes.paddingLarge),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Customer Name *',
                  hintText: 'Enter customer name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Customer name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spacingMedium),
              TextFormField(
                controller: _phoneController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  hintText: 'Enter phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  final raw = (value ?? '').trim();
                  if (raw.isEmpty) {
                    return null;
                  }

                  final onlyDigits = raw.replaceAll(RegExp(r'[^0-9]'), '');
                  if (onlyDigits.length < 7 || onlyDigits.length > 15) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spacingMedium),
              TextFormField(
                controller: _addressController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.streetAddress,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _handleSave,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: const Text('Save'),
        ),
      ],
    );
  }
}
