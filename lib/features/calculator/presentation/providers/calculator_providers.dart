import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/bill_item.dart';
import '../../domain/calc_logic.dart';

class CalculatorNotifier extends Notifier<CalculatorState> {
  @override
  CalculatorState build() => const CalculatorState();

  /// Append digit to current input
  void appendDigit(String digit) {
    final currentInput = state.currentInput;

    // Prevent multiple decimals
    if (digit == '.' && currentInput.contains('.')) {
      return;
    }

    // Prevent leading zeros (except for decimal)
    if (digit == '0' && currentInput == '0') {
      return;
    }

    // Limit decimal places to 2
    if (currentInput.contains('.')) {
      final decimalPart = currentInput.split('.')[1];
      if (decimalPart.length >= 2) {
        return;
      }
    }

    // Limit total length
    if (currentInput.length >= 10) {
      return;
    }

    final newInput = currentInput + digit;
    _updateCurrentInput(newInput);
  }

  /// Append "00" for quick entry
  void appendDoubleZero() {
    final currentInput = state.currentInput;

    // Don't add 00 if already has decimal part
    if (currentInput.contains('.')) {
      return;
    }

    // Don't add 00 to empty or just "0"
    if (currentInput.isEmpty || currentInput == '0') {
      return;
    }

    final newInput = '${currentInput}00';
    _updateCurrentInput(newInput);
  }

  /// Delete last character
  void backspace() {
    final currentInput = state.currentInput;
    if (currentInput.isNotEmpty) {
      final newInput = currentInput.substring(0, currentInput.length - 1);
      _updateCurrentInput(newInput);
    }
  }

  /// Clear current input
  void clearInput() {
    _updateCurrentInput('');
  }

  /// Clear all (current input and bill)
  void clearAll() {
    state = const CalculatorState();
  }

  /// Switch input mode
  void setMode(CalcInputMode mode) {
    state = state.copyWith(currentMode: mode);
  }

  /// Toggle between quantity and rate
  void toggleMode() {
    final newMode = state.currentMode == CalcInputMode.quantity
        ? CalcInputMode.rate
        : CalcInputMode.quantity;
    state = state.copyWith(currentMode: newMode);
  }

  /// Add current item to bill
  void addItem() {
    if (!state.canAddItem) return;

    final newItem = BillItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Item ${state.itemCounter}',
      quantity: state.quantity,
      rate: state.rate,
    );

    state = state.copyWith(
      billItems: [...state.billItems, newItem],
      quantityInput: '',
      rateInput: '',
      currentMode: CalcInputMode.rate,
      itemCounter: state.itemCounter + 1,
    );
  }

  /// Append a prepared bill item to the bill.
  /// Returns true when the item was merged into an existing line.
  bool addBillItem(BillItem item) {
    final existingIndex = findMatchingItemIndex(
      inventoryItemId: item.inventoryItemId,
      barcode: item.barcode,
    );

    if (existingIndex != -1) {
      final existingItem = state.billItems[existingIndex];
      final mergedItem = existingItem.copyWith(
        quantity: existingItem.quantity + item.quantity,
      );
      final newItems = List<BillItem>.from(state.billItems);
      newItems[existingIndex] = mergedItem;
      state = state.copyWith(billItems: newItems);
      return true;
    }

    state = state.copyWith(
      billItems: [...state.billItems, item],
      itemCounter: state.itemCounter + 1,
    );
    return false;
  }

  /// Remove item from bill by index
  void removeItem(int index) {
    if (index < 0 || index >= state.billItems.length) return;

    final newItems = List<BillItem>.from(state.billItems)..removeAt(index);
    state = state.copyWith(billItems: newItems);
  }

  /// Remove item from bill by id
  void removeItemById(String id) {
    final newItems = state.billItems.where((item) => item.id != id).toList();
    state = state.copyWith(billItems: newItems);
  }

  /// Update item at index
  void updateItem(int index, BillItem updatedItem) {
    if (index < 0 || index >= state.billItems.length) return;
    if (updatedItem.quantity <= 0 || updatedItem.rate <= 0) return;

    final newItems = List<BillItem>.from(state.billItems);
    newItems[index] = updatedItem;
    state = state.copyWith(billItems: newItems);
  }

  /// Find an existing bill item for the same inventory product.
  int findMatchingItemIndex({int? inventoryItemId, String? barcode}) {
    final normalizedBarcode = barcode?.trim();

    return state.billItems.indexWhere((item) {
      if (inventoryItemId != null && item.inventoryItemId == inventoryItemId) {
        return true;
      }

      return normalizedBarcode != null &&
          normalizedBarcode.isNotEmpty &&
          item.barcode?.trim() == normalizedBarcode;
    });
  }

  /// Set items (for restoring state)
  void setItems(List<BillItem> items) {
    state = state.copyWith(billItems: items, itemCounter: items.length + 1);
  }

  /// Clear bill items only (keep counter)
  void clearBill() {
    state = state.copyWith(billItems: [], itemCounter: 1);
  }

  /// Helper to update current input
  void _updateCurrentInput(String value) {
    if (state.currentMode == CalcInputMode.quantity) {
      state = state.copyWith(quantityInput: value);
    } else {
      state = state.copyWith(rateInput: value);
    }
  }
}

final calculatorProvider =
    NotifierProvider<CalculatorNotifier, CalculatorState>(
      CalculatorNotifier.new,
    );
