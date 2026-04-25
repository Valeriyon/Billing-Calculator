import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
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
    final state = ref.watch(customerManagerProvider);
    final notifier = ref.read(customerManagerProvider.notifier);
    final theme = Theme.of(context);

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
                              onEdit: () =>
                                  context.push('/customers/edit/${customer.id}'),
                              onDelete: () =>
                                  _confirmDelete(customer.id, customer.name),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(int id, String name) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete customer'),
          content: Text('Delete "$name"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final error = await ref
        .read(customerManagerProvider.notifier)
        .deleteCustomer(id);

    if (!mounted) {
      return;
    }

    messenger.showSnackBar(
      SnackBar(content: Text(error ?? 'Customer deleted successfully')),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({
    required this.customer,
    required this.onEdit,
    required this.onDelete,
  });

  final CustomerModel customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[];
    if ((customer.phone ?? '').isNotEmpty) {
      subtitleParts.add(customer.phone!);
    }
    if ((customer.address ?? '').isNotEmpty) {
      subtitleParts.add(customer.address!);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingMedium),
      child: ListTile(
        title: Text(customer.name),
        subtitle: subtitleParts.isEmpty ? null : Text(subtitleParts.join(' • ')),
        leading: CircleAvatar(
          child: Text(
            customer.name.isEmpty ? '?' : customer.name.substring(0, 1),
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else {
              onDelete();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
            PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: onEdit,
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
