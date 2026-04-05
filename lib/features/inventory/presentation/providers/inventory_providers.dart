import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../data/inventory_repository.dart';
import '../../domain/inventory_item_model.dart';

enum InventorySortOrder { nameAZ, nameZA, priceLowHigh, priceHighLow }

class InventoryManageState {
  const InventoryManageState({
    this.isLoading = true,
    this.isSaving = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedCategories = const <String>{},
    this.selectedBrands = const <String>{},
    this.sortOrder = InventorySortOrder.nameAZ,
    this.items = const <InventoryItemModel>[],
    this.filteredItems = const <InventoryItemModel>[],
  });

  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String searchQuery;
  final Set<String> selectedCategories;
  final Set<String> selectedBrands;
  final InventorySortOrder sortOrder;
  final List<InventoryItemModel> items;
  final List<InventoryItemModel> filteredItems;

  List<String> get allCategories {
    final values = items.map((e) => e.category).toSet().toList()..sort();
    return values;
  }

  List<String> get allBrands {
    final values = items.map((e) => e.brand).toSet().toList()..sort();
    return values;
  }

  InventoryManageState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
    Set<String>? selectedCategories,
    Set<String>? selectedBrands,
    InventorySortOrder? sortOrder,
    List<InventoryItemModel>? items,
    List<InventoryItemModel>? filteredItems,
  }) {
    return InventoryManageState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedBrands: selectedBrands ?? this.selectedBrands,
      sortOrder: sortOrder ?? this.sortOrder,
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
    );
  }
}

class InventoryManagerNotifier extends StateNotifier<InventoryManageState> {
  InventoryManagerNotifier(this._repository)
      : super(const InventoryManageState()) {
    _subscription = _repository.watchAllItems().listen(
      (items) {
        final next = state.copyWith(
          isLoading: false,
          items: items,
          clearError: true,
        );
        state = _withFilteredItems(next);
      },
      onError: (Object error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load inventory items',
        );
      },
    );
  }

  final InventoryRepository _repository;
  StreamSubscription<List<InventoryItemModel>>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void setSearchQuery(String value) {
    state = _withFilteredItems(
      state.copyWith(searchQuery: value.trimLeft(), clearError: true),
    );
  }

  void toggleCategory(String category) {
    final next = Set<String>.from(state.selectedCategories);
    if (next.contains(category)) {
      next.remove(category);
    } else {
      next.add(category);
    }

    state = _withFilteredItems(state.copyWith(selectedCategories: next));
  }

  void toggleBrand(String brand) {
    final next = Set<String>.from(state.selectedBrands);
    if (next.contains(brand)) {
      next.remove(brand);
    } else {
      next.add(brand);
    }

    state = _withFilteredItems(state.copyWith(selectedBrands: next));
  }

  void setSortOrder(InventorySortOrder value) {
    state = _withFilteredItems(state.copyWith(sortOrder: value));
  }

  void clearFilters() {
    state = _withFilteredItems(
      state.copyWith(
        selectedCategories: <String>{},
        selectedBrands: <String>{},
        sortOrder: InventorySortOrder.nameAZ,
      ),
    );
  }

  Future<String?> addItem(InventoryItemDraft draft) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _repository.insertItem(draft);
      state = state.copyWith(isSaving: false);
      return null;
    } on StateError catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.message);
      return e.message;
    } catch (error, stackTrace) {
      debugPrint('addItem failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      final message = _friendlyErrorMessage(error, fallback: 'Unable to save item');
      state = state.copyWith(isSaving: false, errorMessage: message);
      return message;
    }
  }

  Future<String?> updateItem(int id, InventoryItemDraft draft) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _repository.updateItem(id, draft);
      state = state.copyWith(isSaving: false);
      return null;
    } on StateError catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.message);
      return e.message;
    } catch (error, stackTrace) {
      debugPrint('updateItem failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      final message = _friendlyErrorMessage(
        error,
        fallback: 'Unable to update item',
      );
      state = state.copyWith(isSaving: false, errorMessage: message);
      return message;
    }
  }

  Future<String?> deleteItem(int id) async {
    try {
      await _repository.deleteItem(id);
      return null;
    } catch (error, stackTrace) {
      debugPrint('deleteItem failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      final message = _friendlyErrorMessage(
        error,
        fallback: 'Unable to delete item',
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

  InventoryManageState _withFilteredItems(InventoryManageState baseState) {
    var data = List<InventoryItemModel>.from(baseState.items);

    final query = baseState.searchQuery.toLowerCase();
    if (query.isNotEmpty) {
      data = data
          .where(
            (item) =>
                item.name.toLowerCase().contains(query) ||
                item.code.toLowerCase().contains(query) ||
                (item.barcode?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    if (baseState.selectedCategories.isNotEmpty) {
      data = data
          .where((item) => baseState.selectedCategories.contains(item.category))
          .toList();
    }

    if (baseState.selectedBrands.isNotEmpty) {
      data = data
          .where((item) => baseState.selectedBrands.contains(item.brand))
          .toList();
    }

    switch (baseState.sortOrder) {
      case InventorySortOrder.nameAZ:
        data.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case InventorySortOrder.nameZA:
        data.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case InventorySortOrder.priceLowHigh:
        data.sort((a, b) => a.price.compareTo(b.price));
        break;
      case InventorySortOrder.priceHighLow:
        data.sort((a, b) => b.price.compareTo(a.price));
        break;
    }

    return baseState.copyWith(filteredItems: data);
  }
}

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return DriftInventoryRepository(database);
});

final inventoryManagerProvider =
    StateNotifierProvider<InventoryManagerNotifier, InventoryManageState>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return InventoryManagerNotifier(repository);
});

final inventoryItemByIdProvider = FutureProvider.family<InventoryItemModel?, int>(
  (ref, id) {
    return ref.watch(inventoryRepositoryProvider).getItemById(id);
  },
);
