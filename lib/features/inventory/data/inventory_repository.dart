import 'package:drift/drift.dart' hide Column;

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/inventory_items.dart';
import '../domain/inventory_item_model.dart';

abstract class InventoryRepository {
  Stream<List<InventoryItemModel>> watchAllItems({bool includeArchived = false});
  Future<InventoryItemModel?> getItemById(int id);
  Future<String> getNextItemCode();
  Future<int> insertItem(InventoryItemDraft draft);
  Future<void> updateItem(int id, InventoryItemDraft draft);
  Future<void> deleteItem(int id);
}

class DriftInventoryRepository implements InventoryRepository {
  DriftInventoryRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<InventoryItemModel>> watchAllItems({bool includeArchived = false}) {
    return _db
        .watchAllInventoryItems(includeArchived: includeArchived)
        .map((rows) => rows.map(_mapFromDb).toList());
  }

  @override
  Future<InventoryItemModel?> getItemById(int id) async {
    final row = await _db.getInventoryItemById(id);
    if (row == null) {
      return null;
    }
    return _mapFromDb(row);
  }

  @override
  Future<String> getNextItemCode() async {
    await _db.ensureDefaultItemSeries();
    final series = await _db.getSeriesByModule(AppDatabase.itemSeriesModule);
    if (series == null) {
      throw StateError('Item series not found');
    }
    return _formatSeriesCode(
      pattern: series.pattern,
      prefix: series.prefix,
      suffix: series.suffix,
      currentNumber: series.currentNumber,
    );
  }

  @override
  Future<int> insertItem(InventoryItemDraft draft) async {
    return _db.transaction(() async {
      await _db.ensureDefaultItemSeries();
      final series = await _db.getSeriesByModule(AppDatabase.itemSeriesModule);
      if (series == null) {
        throw StateError('Item series not found');
      }
      if (series.status != 1) {
        throw StateError('Item series is inactive');
      }

      final normalizedCode = _formatSeriesCode(
        pattern: series.pattern,
        prefix: series.prefix,
        suffix: series.suffix,
        currentNumber: series.currentNumber,
      );

      final existing = await _db.getInventoryItemByCode(normalizedCode);
      if (existing != null) {
        throw StateError('Generated item code already exists. Please check series settings.');
      }

      final id = await _db.insertInventoryItem(
        InventoryItemsCompanion.insert(
          code: normalizedCode,
          barcode: Value(
            draft.barcode?.trim().isEmpty == true ? null : draft.barcode?.trim(),
          ),
          name: draft.name.trim(),
          category: draft.category.trim(),
          brand: draft.brand.trim(),
          price: draft.price,
          uom: Value(draft.uom.name),
          unitValue: Value(draft.unitValue),
          imagePath: Value(draft.imagePath?.trim().isEmpty == true
              ? null
              : draft.imagePath?.trim()),
          status: Value(_mapStatusToDb(draft.status)),
        ),
      );

      await _db.incrementSeriesNumber(AppDatabase.itemSeriesModule);
      return id;
    });
  }

  @override
  Future<void> updateItem(int id, InventoryItemDraft draft) async {
    final current = await _db.getInventoryItemById(id);
    if (current == null) {
      throw StateError('Item not found');
    }

    final normalizedCode = draft.code.trim();
    final existing = await _db.getInventoryItemByCode(normalizedCode);
    if (existing != null && existing.id != id) {
      throw StateError('Item code already exists');
    }

    final updated = current.copyWith(
      code: normalizedCode,
      barcode: Value(
        draft.barcode?.trim().isEmpty == true ? null : draft.barcode?.trim(),
      ),
      name: draft.name.trim(),
      category: draft.category.trim(),
      brand: draft.brand.trim(),
      price: draft.price,
      uom: draft.uom.name,
      unitValue: draft.unitValue,
      imagePath: Value(
        draft.imagePath?.trim().isEmpty == true ? null : draft.imagePath?.trim(),
      ),
      status: _mapStatusToDb(draft.status),
    );

    final didUpdate = await _db.updateInventoryItem(updated);
    if (!didUpdate) {
      throw StateError('Unable to update item');
    }
  }

  @override
  Future<void> deleteItem(int id) async {
    await _db.deleteInventoryItem(id);
  }

  InventoryItemModel _mapFromDb(InventoryItem row) {
    return InventoryItemModel(
      id: row.id,
      code: row.code,
      barcode: row.barcode,
      name: row.name,
      category: row.category,
      brand: row.brand,
      price: row.price,
      uom: _mapUomFromDb(row.uom),
      unitValue: row.unitValue,
      imagePath: row.imagePath,
      status: _mapStatusFromDb(row.status),
      createdAt: row.createdAt,
    );
  }

  InventoryStatus _mapStatusFromDb(InventoryItemStatus status) {
    switch (status) {
      case InventoryItemStatus.available:
        return InventoryStatus.available;
      case InventoryItemStatus.outOfStock:
        return InventoryStatus.outOfStock;
      case InventoryItemStatus.archived:
        return InventoryStatus.archived;
    }
  }

  InventoryItemStatus _mapStatusToDb(InventoryStatus status) {
    switch (status) {
      case InventoryStatus.available:
        return InventoryItemStatus.available;
      case InventoryStatus.outOfStock:
        return InventoryItemStatus.outOfStock;
      case InventoryStatus.archived:
        return InventoryItemStatus.archived;
    }
  }

  InventoryUom _mapUomFromDb(String uom) {
    return InventoryUom.values.firstWhere(
      (value) => value.name == uom,
      orElse: () => InventoryUom.pcs,
    );
  }

  String _formatSeriesCode({
    required String pattern,
    required String? prefix,
    required String? suffix,
    required int currentNumber,
  }) {
    final prefixValue = (prefix ?? '').trim();
    final suffixValue = (suffix ?? '').trim();

    var output = pattern
        .replaceAll('{prefix}', prefixValue)
        .replaceAll('{current_number}', currentNumber.toString())
        .replaceAll('{suffix}', suffixValue);

    output = output
        .replaceAll('--', '-')
        .replaceAll('//', '/')
        .replaceAll('__', '_')
        .trim();

    if (output.startsWith('-') || output.startsWith('/') || output.startsWith('_')) {
      output = output.substring(1);
    }
    if (output.endsWith('-') || output.endsWith('/') || output.endsWith('_')) {
      output = output.substring(0, output.length - 1);
    }

    return output.isEmpty ? currentNumber.toString() : output;
  }
}
