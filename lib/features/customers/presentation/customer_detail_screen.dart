import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/database/tables/invoices.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../domain/customer_model.dart';
import 'providers/customer_providers.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final int customerId;

  @override
  ConsumerState<CustomerDetailScreen> createState() =>
      _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  CustomerModel? _customer;
  List<CustomerCreditEntry> _credits = const [];
  List<CustomerCollectionEntry> _collections = const [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isSavingCollection = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCustomerData(initialLoad: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomerData({bool initialLoad = false}) async {
    if (!mounted) {
      return;
    }

    setState(() {
      if (initialLoad || _customer == null) {
        _isLoading = true;
      } else {
        _isRefreshing = true;
      }
      _errorMessage = null;
    });

    try {
      final repository = ref.read(customerRepositoryProvider);
      final results = await Future.wait<Object?>([
        repository.getCustomerById(widget.customerId),
        repository.getCreditsForCustomer(widget.customerId),
        repository.getCollectionsForCustomer(widget.customerId),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _customer = results[0] as CustomerModel?;
        _credits = results[1] as List<CustomerCreditEntry>;
        _collections = results[2] as List<CustomerCollectionEntry>;
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (error, stackTrace) {
      debugPrint('loadCustomerData failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Unable to load customer details';
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _handleEdit() async {
    await context.push('/customers/edit/${widget.customerId}');
    if (!mounted) {
      return;
    }
    await _loadCustomerData();
  }

  Future<void> _handleDelete(CustomerModel customer) async {
    final shouldDelete = await showConfirmationDialog(
      context,
      title: 'Delete customer',
      message: 'Delete "${customer.name}"?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (!shouldDelete || !mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final error = await ref
        .read(customerManagerProvider.notifier)
        .deleteCustomer(customer.id);

    if (!mounted) {
      return;
    }

    messenger.showSnackBar(
      SnackBar(content: Text(error ?? 'Customer deleted successfully')),
    );

    if (error == null) {
      context.pop();
    }
  }

  Future<void> _showCollectionSheet({
    CustomerCollectionEntry? existingCollection,
  }) async {
    final customer = _customer;
    if (customer == null) {
      return;
    }

    final isEditing = existingCollection != null;
    final maximumAmount = isEditing
        ? customer.creditDue + existingCollection.amount
        : customer.creditDue;

    final amount = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ReceivePaymentSheet(
        customer: customer,
        title: isEditing ? 'Edit Received Amount' : 'Add Received Amount',
        submitLabel: isEditing ? 'Update Amount' : 'Save Amount',
        initialAmount: existingCollection?.amount,
        maximumAmount: maximumAmount,
      ),
    );

    if (amount == null || !mounted) {
      return;
    }

    // Let the bottom sheet route finish disposing before mutating page state.
    await Future<void>.delayed(Duration.zero);
    if (!mounted) {
      return;
    }

    if (existingCollection == null) {
      final shouldAdd = await showConfirmationDialog(
        context,
        title: 'Confirm received amount',
        message:
            'Add ${CurrencyFormatter.format(amount)} as received amount for ${customer.name}?',
        confirmLabel: 'Add',
      );

      if (!shouldAdd || !mounted) {
        return;
      }
    }

    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isSavingCollection = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(customerRepositoryProvider);
      if (existingCollection == null) {
        await repository.recordCollection(
          customerId: customer.id,
          amount: amount,
        );
      } else {
        await repository.updateCollection(
          customerId: customer.id,
          voucherId: existingCollection.voucherId,
          amount: amount,
        );
      }

      if (!mounted) {
        return;
      }

      await _loadCustomerData();
      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            existingCollection == null
                ? 'Received amount saved and oldest credits updated'
                : 'Received amount updated and credits recalculated',
          ),
        ),
      );
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
      });
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error, stackTrace) {
      debugPrint('recordCollection failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      const message = 'Unable to save received amount';
      setState(() {
        _errorMessage = message;
      });
      messenger.showSnackBar(const SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _isSavingCollection = false;
        });
      }
    }
  }

  Future<void> _openCreditInvoice(CustomerCreditEntry credit) async {
    await context.push('/invoices/${credit.invoiceId}');
    if (!mounted) {
      return;
    }
    await _loadCustomerData();
  }

  @override
  Widget build(BuildContext context) {
    final customer = _customer;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(customer?.name ?? 'Customer'),
        actions: customer == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete customer',
                  onPressed: () => _handleDelete(customer),
                ),
              ],
      ),
      body: SafeArea(
        child: _isLoading && customer == null
            ? const Center(child: CircularProgressIndicator())
            : customer == null
            ? _ErrorState(
                message: _errorMessage ?? 'Customer not found',
                onRetry: () => _loadCustomerData(initialLoad: true),
              )
            : Column(
                children: [
                  if (_isRefreshing || _isSavingCollection)
                    const LinearProgressIndicator(minHeight: 2),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.paddingLarge,
                        AppSizes.paddingSmall,
                        AppSizes.paddingLarge,
                        0,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _errorMessage!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.error),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.paddingLarge,
                      AppSizes.paddingLarge,
                      AppSizes.paddingLarge,
                      AppSizes.paddingMedium,
                    ),
                    child: _CustomerSummaryCard(
                      customer: customer,
                      onEdit: _handleEdit,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingLarge,
                    ),
                    child: _SectionTabs(controller: _tabController),
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _CreditsTab(
                          credits: _credits,
                          onRefresh: _loadCustomerData,
                          onCreditTap: _openCreditInvoice,
                        ),
                        _CollectionsTab(
                          customer: customer,
                          collections: _collections,
                          isSaving: _isSavingCollection,
                          onRefresh: _loadCustomerData,
                          onAddCollection: _showCollectionSheet,
                          onEditCollection: (collection) =>
                              _showCollectionSheet(
                                existingCollection: collection,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CustomerSummaryCard extends StatelessWidget {
  const _CustomerSummaryCard({required this.customer, required this.onEdit});

  final CustomerModel customer;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dueColor = customer.creditDue > 0
        ? AppColors.warning
        : AppColors.success;
    final phone = (customer.phone ?? '').trim();
    final address = (customer.address ?? '').trim();
    final subtitleParts = <String>[
      if (phone.isNotEmpty) phone,
      if (address.isNotEmpty) address,
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    customer.name.isEmpty
                        ? '?'
                        : customer.name.substring(0, 1).toUpperCase(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingXSmall),
                      Text(
                        subtitleParts.isEmpty
                            ? 'No contact details added'
                            : subtitleParts.join('  •  '),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingXSmall),
                      Text(
                        'Customer since ${DateHelpers.formatDateShort(customer.createdAt)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: onEdit,
                  tooltip: 'Edit customer',
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingLarge),
            Row(
              children: [
                Expanded(
                  child: _SummaryStatCard(
                    label: 'Balance Due',
                    value: CurrencyFormatter.format(customer.creditDue),
                    icon: Icons.account_balance_wallet_outlined,
                    valueColor: dueColor,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingMedium),
                Expanded(
                  child: _SummaryStatCard(
                    label: 'Credit Limit',
                    value: CurrencyFormatter.format(customer.creditLimit),
                    icon: Icons.credit_card_outlined,
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

class _SummaryStatCard extends StatelessWidget {
  const _SummaryStatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: AppSizes.iconSizeSmall,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
            ],
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTabs extends StatelessWidget {
  const _SectionTabs({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: TabBar(
        controller: controller,
        tabAlignment: TabAlignment.start,
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: theme.textTheme.bodyMedium?.color,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        dividerColor: Colors.transparent,
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        tabs: const [
          Tab(text: 'Credits'),
          Tab(text: 'Collections'),
        ],
      ),
    );
  }
}

class _CreditsTab extends StatelessWidget {
  const _CreditsTab({
    required this.credits,
    required this.onRefresh,
    required this.onCreditTap,
  });

  final List<CustomerCreditEntry> credits;
  final Future<void> Function() onRefresh;
  final ValueChanged<CustomerCreditEntry> onCreditTap;

  @override
  Widget build(BuildContext context) {
    if (credits.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          children: const [
            _EmptyTabState(
              icon: Icons.receipt_long_outlined,
              title: 'No credit invoices',
              subtitle: 'Credit invoices for this customer will appear here.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingLarge,
          AppSizes.paddingSmall,
          AppSizes.paddingLarge,
          AppSizes.paddingLarge,
        ),
        itemCount: credits.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSizes.spacingSmall),
        itemBuilder: (context, index) {
          final credit = credits[index];
          return _CreditCard(credit: credit, onTap: () => onCreditTap(credit));
        },
      ),
    );
  }
}

class _CreditCard extends StatelessWidget {
  const _CreditCard({required this.credit, required this.onTap});

  final CustomerCreditEntry credit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.credit.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: AppColors.credit,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          credit.invoiceNo,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingXSmall),
                        Text(
                          DateHelpers.formatDateTime(credit.invoiceDate),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _PaymentStatusChip(status: credit.paymentStatus),
                ],
              ),
              const SizedBox(height: AppSizes.spacingMedium),
              Row(
                children: [
                  Expanded(
                    child: _AmountInfo(
                      label: 'Total',
                      value: CurrencyFormatter.format(credit.totalAmount),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _AmountInfo(
                      label: 'Paid',
                      value: CurrencyFormatter.format(credit.paidAmount),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _AmountInfo(
                      label: 'Due',
                      value: CurrencyFormatter.format(credit.balanceDue),
                      valueColor: credit.balanceDue > 0
                          ? AppColors.warning
                          : AppColors.success,
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

class _AmountInfo extends StatelessWidget {
  const _AmountInfo({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: AppSizes.spacingXSmall),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionsTab extends StatelessWidget {
  const _CollectionsTab({
    required this.customer,
    required this.collections,
    required this.isSaving,
    required this.onRefresh,
    required this.onAddCollection,
    required this.onEditCollection,
  });

  final CustomerModel customer;
  final List<CustomerCollectionEntry> collections;
  final bool isSaving;
  final Future<void> Function() onRefresh;
  final VoidCallback onAddCollection;
  final ValueChanged<CustomerCollectionEntry> onEditCollection;

  @override
  Widget build(BuildContext context) {
    final latestEditableVoucherId = collections.isEmpty
        ? null
        : collections.first.voucherId;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingLarge,
          AppSizes.paddingSmall,
          AppSizes.paddingLarge,
          AppSizes.paddingLarge,
        ),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Receive Amount',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  Text(
                    'Received money automatically closes the oldest pending credit invoices first.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSizes.spacingMedium),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSizes.spacingSmall),
                        Expanded(
                          child: Text(
                            'Current due: ${CurrencyFormatter.format(customer.creditDue)}',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingMedium),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: customer.creditDue > 0 && !isSaving
                          ? onAddCollection
                          : null,
                      icon: const Icon(Icons.add_card_outlined),
                      label: Text(
                        isSaving ? 'Saving...' : 'Add Received Amount',
                      ),
                    ),
                  ),
                  if (collections.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.spacingSmall),
                    Text(
                      'Only the latest received amount can be edited.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingLarge),
          if (collections.isEmpty)
            const _EmptyTabState(
              icon: Icons.payments_outlined,
              title: 'No collections yet',
              subtitle: 'Received amounts for this customer will appear here.',
            )
          else
            ...collections.map(
              (collection) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
                child: _CollectionCard(
                  collection: collection,
                  canEdit: latestEditableVoucherId == collection.voucherId,
                  onTap: () => onEditCollection(collection),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.collection,
    required this.canEdit,
    required this.onTap,
  });

  final CustomerCollectionEntry collection;
  final bool canEdit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        onTap: canEdit ? onTap : null,
        child: ListTile(
          contentPadding: const EdgeInsets.all(AppSizes.paddingMedium),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: const Icon(Icons.south_west, color: AppColors.success),
          ),
          title: Text(
            CurrencyFormatter.format(collection.amount),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(DateHelpers.formatDateTime(collection.createdAt)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                canEdit ? 'Editable' : 'Locked',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: canEdit
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Icon(
                canEdit ? Icons.edit_outlined : Icons.lock_outline,
                size: AppSizes.iconSizeSmall,
                color: canEdit
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodySmall?.color ?? Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentStatusChip extends StatelessWidget {
  const _PaymentStatusChip({required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;

    switch (status) {
      case PaymentStatus.fulfilled:
        label = 'Paid';
        color = AppColors.success;
        break;
      case PaymentStatus.partial:
        label = 'Partial';
        color = AppColors.info;
        break;
      case PaymentStatus.pending:
        label = 'Pending';
        color = AppColors.warning;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: AppSizes.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyTabState extends StatelessWidget {
  const _EmptyTabState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingXLarge),
      child: Column(
        children: [
          const SizedBox(height: AppSizes.spacingXXLarge),
          Icon(
            icon,
            size: 48,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSizes.spacingMedium),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: AppSizes.spacingMedium),
            Text(message, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSizes.spacingLarge),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceivePaymentSheet extends StatefulWidget {
  const _ReceivePaymentSheet({
    required this.customer,
    required this.title,
    required this.submitLabel,
    required this.maximumAmount,
    this.initialAmount,
  });

  final CustomerModel customer;
  final String title;
  final String submitLabel;
  final double maximumAmount;
  final double? initialAmount;

  @override
  State<_ReceivePaymentSheet> createState() => _ReceivePaymentSheetState();
}

class _ReceivePaymentSheetState extends State<_ReceivePaymentSheet> {
  late final TextEditingController _amountController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount == null
          ? ''
          : widget.initialAmount!.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = double.tryParse(_amountController.text.trim());
    if (parsed == null || parsed <= 0) {
      setState(() {
        _errorText = 'Enter a valid amount';
      });
      return;
    }

    if (parsed - widget.maximumAmount > 0.0001) {
      setState(() {
        _errorText = 'Amount cannot be more than due';
      });
      return;
    }

    Navigator.of(context).pop(double.parse(parsed.toStringAsFixed(2)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Material(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXLarge),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spacingLarge),
                Text(
                  widget.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingSmall),
                Text(
                  'Maximum allowed: ${CurrencyFormatter.format(widget.maximumAmount)}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSizes.spacingLarge),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Received amount',
                    prefixText: 'Rs ',
                    errorText: _errorText,
                  ),
                  onChanged: (_) {
                    if (_errorText != null) {
                      setState(() {
                        _errorText = null;
                      });
                    }
                  },
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSizes.spacingSmall),
                Text(
                  'This amount automatically closes the oldest pending credits first.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSizes.spacingXLarge),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingMedium),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _submit,
                        child: Text(widget.submitLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
