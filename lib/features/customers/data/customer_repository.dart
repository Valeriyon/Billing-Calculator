import 'package:drift/drift.dart' hide Column;

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/invoices.dart';
import '../domain/customer_model.dart';

abstract class CustomerRepository {
  Stream<List<CustomerModel>> watchAllCustomers();
  Future<CustomerModel?> getCustomerById(int id);
  Future<List<CustomerCreditEntry>> getCreditsForCustomer(int customerId);
  Future<List<CustomerCollectionEntry>> getCollectionsForCustomer(int customerId);
  Future<int> insertCustomer(CustomerDraft draft);
  Future<void> updateCustomer(int id, CustomerDraft draft);
  Future<void> recordCollection({required int customerId, required double amount});
  Future<void> updateCollection({
    required int customerId,
    required int voucherId,
    required double amount,
  });
  Future<void> deleteCustomer(int id);
}

class DriftCustomerRepository implements CustomerRepository {
  DriftCustomerRepository(this._db);

  final AppDatabase _db;
  static const String _customerCollectionVoucherType = 'collection';
  static const double _moneyTolerance = 0.0001;

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
  Future<List<CustomerCreditEntry>> getCreditsForCustomer(int customerId) async {
    final rows = await (_db.select(_db.invoices)
          ..where(
            (t) =>
                t.customerId.equals(customerId) &
                t.paymentMode.equals(PaymentMode.credit.index),
          )
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .get();

    return rows
        .map(
          (invoice) => CustomerCreditEntry(
            invoiceId: invoice.id,
            invoiceNo: invoice.invoiceNo,
            invoiceDate: invoice.createdAt,
            totalAmount: invoice.totalAmount,
            paidAmount: invoice.paidAmount,
            balanceDue: _dueAmount(invoice.totalAmount, invoice.paidAmount),
            paymentStatus: invoice.paymentStatus,
          ),
        )
        .toList();
  }

  @override
  Future<List<CustomerCollectionEntry>> getCollectionsForCustomer(
    int customerId,
  ) async {
    final query = _db.select(_db.vouchers).join([
      innerJoin(
        _db.ledgerEntries,
        _db.ledgerEntries.voucherId.equalsExp(_db.vouchers.id),
      ),
    ])
      ..where(
        _db.vouchers.type.equals(_customerCollectionVoucherType) &
            _db.vouchers.referenceId.equals(customerId),
      )
      ..orderBy([
        OrderingTerm.desc(_db.vouchers.createdAt),
        OrderingTerm.desc(_db.vouchers.id),
      ]);

    final rows = await query.get();
    return rows.map((row) {
      final voucher = row.readTable(_db.vouchers);
      final ledgerEntry = row.readTable(_db.ledgerEntries);
      final amount = ledgerEntry.credit > 0
          ? ledgerEntry.credit
          : ledgerEntry.debit;

      return CustomerCollectionEntry(
        voucherId: voucher.id,
        amount: amount,
        createdAt: voucher.createdAt,
      );
    }).toList();
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

    await _db.transaction(() async {
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

      await (_db.update(_db.ledgers)..where((t) => t.id.equals(current.ledgerId)))
          .write(LedgersCompanion(name: Value(normalizedName)));
    });
  }

  @override
  Future<void> recordCollection({
    required int customerId,
    required double amount,
  }) async {
    final normalizedAmount = _normalizeAmount(amount);

    await _db.transaction(() async {
      final customer = await _db.getCustomerById(customerId);
      if (customer == null) {
        throw StateError('Customer not found');
      }

      final context = await _loadCreditStateContext(customerId);
      if (context.creditInvoices.isEmpty) {
        throw StateError('No credit invoices found for this customer');
      }

      if (context.currentDue <= _moneyTolerance) {
        throw StateError('This customer has no pending credit due');
      }

      if (normalizedAmount - context.currentDue > _moneyTolerance) {
        throw StateError(
          'Received amount cannot be more than the current due balance',
        );
      }

      final voucherId = await _db.into(_db.vouchers).insert(
        VouchersCompanion.insert(
          type: _customerCollectionVoucherType,
          referenceId: Value(customerId),
        ),
      );

      await _db.into(_db.ledgerEntries).insert(
        LedgerEntriesCompanion.insert(
          voucherId: voucherId,
          ledgerId: customer.ledgerId,
          credit: Value(normalizedAmount),
        ),
      );

      await _recalculateCustomerCreditState(
        customer: customer,
        context: context,
        extraCollectedAmount: normalizedAmount,
      );
    });
  }

  @override
  Future<void> updateCollection({
    required int customerId,
    required int voucherId,
    required double amount,
  }) async {
    final normalizedAmount = _normalizeAmount(amount);

    await _db.transaction(() async {
      final customer = await _db.getCustomerById(customerId);
      if (customer == null) {
        throw StateError('Customer not found');
      }

      final context = await _loadCreditStateContext(customerId);
      final targetCollection = context.collections.cast<_CustomerCollectionRecord?>()
          .firstWhere(
            (collection) => collection?.voucherId == voucherId,
            orElse: () => null,
          );

      if (targetCollection == null) {
        throw StateError('Received amount not found');
      }

      final latestCollection = context.collections.isEmpty
          ? null
          : context.collections.last;
      if (latestCollection == null || latestCollection.voucherId != voucherId) {
        throw StateError('Only the latest received amount can be edited');
      }

      final maxEditableAmount = context.currentDue + targetCollection.amount;
      if (normalizedAmount - maxEditableAmount > _moneyTolerance) {
        throw StateError(
          'Received amount cannot be more than the current due balance',
        );
      }

      await (_db.update(_db.ledgerEntries)
            ..where((t) => t.id.equals(targetCollection.ledgerEntryId)))
          .write(
            LedgerEntriesCompanion(
              credit: Value(normalizedAmount),
              debit: const Value(0.0),
            ),
          );

      await _recalculateCustomerCreditState(
        customer: customer,
        context: context,
        replacedVoucherId: voucherId,
        replacementAmount: normalizedAmount,
      );
    });
  }

  Future<void> _recalculateCustomerCreditState({
    required Customer customer,
    required _CustomerCreditStateContext context,
    double extraCollectedAmount = 0.0,
    int? replacedVoucherId,
    double? replacementAmount,
  }) async {
    final totalCreditAmount = context.creditInvoices.fold<double>(
      0.0,
      (sum, invoice) => sum + invoice.totalAmount,
    );

    var totalCollectedAmount = extraCollectedAmount;
    for (final collection in context.collections) {
      if (collection.voucherId == replacedVoucherId) {
        totalCollectedAmount += replacementAmount ?? collection.amount;
      } else {
        totalCollectedAmount += collection.amount;
      }
    }

    totalCollectedAmount = _normalizeMoney(totalCollectedAmount);

    final representedPaidAmount = context.creditInvoices.fold<double>(
      0.0,
      (sum, invoice) => sum + invoice.paidAmount,
    );
    final basePaidAmount = representedPaidAmount > context.totalCollectedAmount
        ? _normalizeMoney(
            representedPaidAmount - context.totalCollectedAmount,
          )
        : 0.0;

    final targetPaidAmount = _normalizeMoney(basePaidAmount + totalCollectedAmount);
    if (targetPaidAmount - totalCreditAmount > _moneyTolerance) {
      throw StateError('Received amount cannot be more than the current due balance');
    }

    var remainingPaidAmount = targetPaidAmount;
    final now = DateTime.now();

    for (final invoice in context.creditInvoices) {
      final nextPaidAmount = remainingPaidAmount <= _moneyTolerance
          ? 0.0
          : _normalizeMoney(
              remainingPaidAmount < invoice.totalAmount
                  ? remainingPaidAmount
                  : invoice.totalAmount,
            );

      final nextStatus = _resolvePaymentStatus(
        totalAmount: invoice.totalAmount,
        paidAmount: nextPaidAmount,
      );
      await (_db.update(_db.invoices)..where((t) => t.id.equals(invoice.id)))
          .write(
            InvoicesCompanion(
              paidAmount: Value(nextPaidAmount),
              paymentStatus: Value(nextStatus),
              updatedAt: Value(now),
            ),
          );

      remainingPaidAmount = _normalizeMoney(remainingPaidAmount - nextPaidAmount);
    }

    if (remainingPaidAmount > _moneyTolerance) {
      throw StateError('Unable to apply the full amount to customer credits');
    }

    final nextDue = _normalizeMoney(totalCreditAmount - targetPaidAmount);
    final didUpdateCustomer = await _db.updateCustomer(
      customer.copyWith(creditDue: nextDue <= _moneyTolerance ? 0.0 : nextDue),
    );

    if (!didUpdateCustomer) {
      throw StateError('Unable to update customer balance');
    }
  }

  Future<_CustomerCreditStateContext> _loadCreditStateContext(
    int customerId,
  ) async {
    final creditInvoices = await (_db.select(_db.invoices)
          ..where(
            (t) =>
                t.customerId.equals(customerId) &
                t.paymentMode.equals(PaymentMode.credit.index),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.createdAt),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();

    final collectionRows = await (_db.select(_db.vouchers).join([
      innerJoin(
        _db.ledgerEntries,
        _db.ledgerEntries.voucherId.equalsExp(_db.vouchers.id),
      ),
    ])
          ..where(
            _db.vouchers.type.equals(_customerCollectionVoucherType) &
                _db.vouchers.referenceId.equals(customerId),
          )
          ..orderBy([
            OrderingTerm.asc(_db.vouchers.createdAt),
            OrderingTerm.asc(_db.vouchers.id),
          ]))
        .get();

    final collections = collectionRows.map((row) {
      final voucher = row.readTable(_db.vouchers);
      final ledgerEntry = row.readTable(_db.ledgerEntries);
      return _CustomerCollectionRecord(
        voucherId: voucher.id,
        ledgerEntryId: ledgerEntry.id,
        amount: ledgerEntry.credit > 0 ? ledgerEntry.credit : ledgerEntry.debit,
      );
    }).toList();

    return _CustomerCreditStateContext(
      creditInvoices: creditInvoices,
      collections: collections,
      totalCollectedAmount: _normalizeMoney(
        collections.fold<double>(0.0, (sum, collection) => sum + collection.amount),
      ),
      currentDue: _normalizeMoney(
        creditInvoices.fold<double>(
          0.0,
          (sum, invoice) => sum + _dueAmount(invoice.totalAmount, invoice.paidAmount),
        ),
      ),
    );
  }

  @override
  Future<void> deleteCustomer(int id) async {
    final current = await _db.getCustomerById(id);
    if (current == null) {
      throw StateError('Customer not found');
    }

    final linkedInvoices = await (_db.select(_db.invoices)
          ..where((t) => t.customerId.equals(id))
          ..limit(1))
        .get();
    if (linkedInvoices.isNotEmpty) {
      throw StateError(
        'This customer already has invoice history and cannot be deleted',
      );
    }

    await _db.transaction(() async {
      final deleted = await _db.deleteCustomer(id);
      if (deleted == 0) {
        throw StateError('Customer not found');
      }

      await (_db.delete(_db.ledgers)..where((t) => t.id.equals(current.ledgerId)))
          .go();
    });
  }

  CustomerModel _mapFromDb(Customer row) {
    return CustomerModel(
      id: row.id,
      name: row.name,
      creditLimit: row.creditLimit,
      creditDue: row.creditDue,
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

  double _dueAmount(double totalAmount, double paidAmount) {
    final due = totalAmount - paidAmount;
    if (due <= _moneyTolerance) {
      return 0.0;
    }
    return double.parse(due.toStringAsFixed(2));
  }

  PaymentStatus _resolvePaymentStatus({
    required double totalAmount,
    required double paidAmount,
  }) {
    if (paidAmount <= _moneyTolerance) {
      return PaymentStatus.pending;
    }
    if (paidAmount + _moneyTolerance >= totalAmount) {
      return PaymentStatus.fulfilled;
    }
    return PaymentStatus.partial;
  }

  double _normalizeAmount(double amount) {
    final normalizedAmount = _normalizeMoney(amount);
    if (normalizedAmount <= 0) {
      throw StateError('Enter a valid amount');
    }
    return normalizedAmount;
  }

  double _normalizeMoney(double amount) {
    final normalized = double.parse(amount.toStringAsFixed(2));
    if (normalized.abs() <= _moneyTolerance) {
      return 0.0;
    }
    return normalized;
  }
}

class _CustomerCreditStateContext {
  const _CustomerCreditStateContext({
    required this.creditInvoices,
    required this.collections,
    required this.totalCollectedAmount,
    required this.currentDue,
  });

  final List<Invoice> creditInvoices;
  final List<_CustomerCollectionRecord> collections;
  final double totalCollectedAmount;
  final double currentDue;
}

class _CustomerCollectionRecord {
  const _CustomerCollectionRecord({
    required this.voucherId,
    required this.ledgerEntryId,
    required this.amount,
  });

  final int voucherId;
  final int ledgerEntryId;
  final double amount;
}
