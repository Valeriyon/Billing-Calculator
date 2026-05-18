import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../data/customer_repository.dart';
import '../../domain/customer_model.dart';

class CustomerManageState {
  const CustomerManageState({
    this.isLoading = true,
    this.isSaving = false,
    this.errorMessage,
    this.searchQuery = '',
    this.customers = const <CustomerModel>[],
    this.filteredCustomers = const <CustomerModel>[],
  });

  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String searchQuery;
  final List<CustomerModel> customers;
  final List<CustomerModel> filteredCustomers;

  CustomerManageState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
    List<CustomerModel>? customers,
    List<CustomerModel>? filteredCustomers,
  }) {
    return CustomerManageState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      customers: customers ?? this.customers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
    );
  }
}

class CustomerManagerNotifier extends StateNotifier<CustomerManageState> {
  CustomerManagerNotifier(this._repository) : super(const CustomerManageState()) {
    _subscription = _repository.watchAllCustomers().listen(
      (customers) {
        final next = state.copyWith(
          isLoading: false,
          customers: customers,
          clearError: true,
        );
        state = _withFilteredCustomers(next);
      },
      onError: (Object error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load customers',
        );
      },
    );
  }

  final CustomerRepository _repository;
  StreamSubscription<List<CustomerModel>>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void setSearchQuery(String value) {
    state = _withFilteredCustomers(
      state.copyWith(searchQuery: value.trimLeft(), clearError: true),
    );
  }

  Future<String?> addCustomer(CustomerDraft draft) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _repository.insertCustomer(draft);
      state = state.copyWith(isSaving: false);
      return null;
    } on StateError catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.message);
      return e.message;
    } catch (error, stackTrace) {
      debugPrint('addCustomer failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      final message = _friendlyErrorMessage(
        error,
        fallback: 'Unable to save customer',
      );
      state = state.copyWith(isSaving: false, errorMessage: message);
      return message;
    }
  }

  Future<String?> updateCustomer(int id, CustomerDraft draft) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _repository.updateCustomer(id, draft);
      state = state.copyWith(isSaving: false);
      return null;
    } on StateError catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.message);
      return e.message;
    } catch (error, stackTrace) {
      debugPrint('updateCustomer failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      final message = _friendlyErrorMessage(
        error,
        fallback: 'Unable to update customer',
      );
      state = state.copyWith(isSaving: false, errorMessage: message);
      return message;
    }
  }

  Future<String?> deleteCustomer(int id) async {
    try {
      await _repository.deleteCustomer(id);
      return null;
    } catch (error, stackTrace) {
      debugPrint('deleteCustomer failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      final message = _friendlyErrorMessage(
        error,
        fallback: 'Unable to delete customer',
      );
      state = state.copyWith(errorMessage: message);
      return message;
    }
  }

  String _friendlyErrorMessage(Object error, {required String fallback}) {
    final raw = error.toString().trim();
    if (raw.isEmpty) {
      return fallback;
    }

    const prefixes = [
      'Exception: ',
      'Bad state: ',
      'Invalid argument(s): ',
    ];

    var cleaned = raw;
    for (final prefix in prefixes) {
      if (cleaned.startsWith(prefix)) {
        cleaned = cleaned.substring(prefix.length).trim();
        break;
      }
    }

    return cleaned.isEmpty ? fallback : cleaned;
  }

  CustomerManageState _withFilteredCustomers(CustomerManageState baseState) {
    var data = List<CustomerModel>.from(baseState.customers);

    final query = baseState.searchQuery.toLowerCase();
    if (query.isNotEmpty) {
      data = data
          .where(
            (customer) =>
                customer.name.toLowerCase().contains(query) ||
                (customer.phone?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    data.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return baseState.copyWith(filteredCustomers: data);
  }
}

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return DriftCustomerRepository(database);
});

final customerManagerProvider =
    StateNotifierProvider<CustomerManagerNotifier, CustomerManageState>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return CustomerManagerNotifier(repository);
});

final customerByIdProvider = FutureProvider.family<CustomerModel?, int>((
  ref,
  id,
) {
  return ref.watch(customerRepositoryProvider).getCustomerById(id);
});

final customerCreditsProvider =
    FutureProvider.family<List<CustomerCreditEntry>, int>((ref, customerId) {
      return ref
          .watch(customerRepositoryProvider)
          .getCreditsForCustomer(customerId);
    });

final customerCollectionsProvider =
    FutureProvider.family<List<CustomerCollectionEntry>, int>((ref, customerId) {
      return ref
          .watch(customerRepositoryProvider)
          .getCollectionsForCustomer(customerId);
    });
