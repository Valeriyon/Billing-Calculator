import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../domain/customer_model.dart';
import 'providers/customer_providers.dart';

class ManageCustomersScreen extends ConsumerStatefulWidget {
  const ManageCustomersScreen({super.key});

  @override
  ConsumerState<ManageCustomersScreen> createState() =>
      _ManageCustomersScreenState();
}

class _ManageCustomersScreenState extends ConsumerState<ManageCustomersScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(userPreferencesProvider);
    final state = ref.watch(customerManagerProvider);
    final notifier = ref.read(customerManagerProvider.notifier);
    final theme = Theme.of(context);

    if (!prefs.creditPaymentEnabled) {
      return Scaffold(
        appBar: CommonAppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back to calculator',
            onPressed: () => context.go('/'),
          ),
          title: const Text('Customers'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingXLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.credit_card_off,
                  size: 56,
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
                const SizedBox(height: AppSizes.spacingMedium),
                Text(
                  'Credit payment is turned off',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSizes.spacingSmall),
                Text(
                  'Enable credit payment in Settings to manage customers.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSizes.spacingLarge),
                FilledButton(
                  onPressed: () => context.push('/settings'),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CommonAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to calculator',
          onPressed: () => context.go('/'),
        ),
        title: const Text('Customers'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.paddingLarge),
            child: FilledButton.icon(
              onPressed: () => context.push('/customers/new'),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.paddingLarge,
                AppSizes.paddingLarge,
                AppSizes.paddingLarge,
                AppSizes.paddingSmall,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: notifier.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search customers...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: state.searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            notifier.setSearchQuery('');
                          },
                          icon: const Icon(Icons.close),
                        )
                      : null,
                ),
              ),
            ),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLarge,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    state.errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppSizes.spacingSmall),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.filteredCustomers.isEmpty
                  ? _EmptyCustomers(hasFilter: state.searchQuery.isNotEmpty)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.paddingLarge,
                        0,
                        AppSizes.paddingLarge,
                        AppSizes.paddingLarge,
                      ),
                      itemCount: state.filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = state.filteredCustomers[index];
                        return _CustomerTile(
                          customer: customer,
                          onTap: () =>
                              context.push('/customers/${customer.id}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({required this.customer, required this.onTap});

  final CustomerModel customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dueColor = customer.creditDue > 0
        ? AppColors.warning
        : theme.textTheme.bodySmall?.color;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingMedium),
      child: ListTile(
        title: Text(customer.name),
        subtitle: Text(
          (customer.phone ?? '').isEmpty
              ? 'No contact number'
              : customer.phone!,
        ),
        leading: CircleAvatar(
          child: Text(
            customer.name.isEmpty ? '?' : customer.name.substring(0, 1),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CurrencyFormatter.format(customer.creditDue),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: dueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text('Due', style: theme.textTheme.bodySmall),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _EmptyCustomers extends StatelessWidget {
  const _EmptyCustomers({required this.hasFilter});

  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_alt_outlined,
              size: 48,
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSizes.spacingMedium),
            Text(
              hasFilter ? 'No matching customers' : 'No customers yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              hasFilter
                  ? 'Try a different search keyword.'
                  : 'Tap Add to create your first customer.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
