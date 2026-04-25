import 'package:drift/drift.dart' hide Column;

import '../../../core/database/app_database.dart';
import '../domain/customer_model.dart';

abstract class CustomerRepository {
  Stream<List<CustomerModel>> watchAllCustomers();
  Future<CustomerModel?> getCustomerById(int id);
  Future<int> insertCustomer(CustomerDraft draft);
  Future<void> updateCustomer(int id, CustomerDraft draft);
  Future<void> deleteCustomer(int id);
}

class DriftCustomerRepository implements CustomerRepository {
  DriftCustomerRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<CustomerModel>> watchAllCustomers() {
    return _db.watchAllCustomers().map((rows) => rows.map(_mapFromDb).toList());
  }

  @override
  Future<CustomerModel?> getCustomerById(int id) async {
    final row = await _db.getCustomerById(id);
    if (row == null) {
      return null;
    }
    return _mapFromDb(row);
  }

  @override
  Future<int> insertCustomer(CustomerDraft draft) {
    final normalizedName = draft.name.trim();
    if (normalizedName.isEmpty) {
      throw StateError('Customer name is required');
    }

    return _db.createCustomerWithLedger(
      customerName: normalizedName,
      phone: _nullableTrim(draft.phone),
      address: _nullableTrim(draft.address),
    );
  }

  @override
  Future<void> updateCustomer(int id, CustomerDraft draft) async {
    final current = await _db.getCustomerById(id);
    if (current == null) {
      throw StateError('Customer not found');
    }

    final normalizedName = draft.name.trim();
    if (normalizedName.isEmpty) {
      throw StateError('Customer name is required');
    }

    final didUpdate = await _db.updateCustomer(
      current.copyWith(
        name: normalizedName,
        phone: Value(_nullableTrim(draft.phone)),
        address: Value(_nullableTrim(draft.address)),
      ),
    );

    if (!didUpdate) {
      throw StateError('Unable to update customer');
    }
  }

  @override
  Future<void> deleteCustomer(int id) async {
    final deleted = await _db.deleteCustomer(id);
    if (deleted == 0) {
      throw StateError('Customer not found');
    }
  }

  CustomerModel _mapFromDb(Customer row) {
    return CustomerModel(
      id: row.id,
      name: row.name,
      phone: row.phone,
      address: row.address,
      ledgerId: row.ledgerId,
      createdAt: row.createdAt,
    );
  }

  String? _nullableTrim(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
