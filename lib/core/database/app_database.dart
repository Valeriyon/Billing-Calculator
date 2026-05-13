import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/invoices.dart';
import 'tables/invoice_items.dart';
import 'tables/customers.dart';
import 'tables/ledgers.dart';
import 'tables/vouchers.dart';
import 'tables/ledger_entries.dart';
import 'tables/inventory_items.dart';
import 'tables/document_series_numbers.dart';

part 'app_database.g.dart';

/// Main database class for the billing app
@DriftDatabase(
  tables: [
    Invoices,
    InvoiceItems,
    InventoryItems,
    DocumentSeriesNumbers,
    Customers,
    Ledgers,
    Vouchers,
    LedgerEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await ensureDefaultItemSeries();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Helper to run migration steps safely and continue on non-fatal errors
        Future<void> _safe(Future<void> Function() fn, String desc) async {
          try {
            await fn();
          } catch (e) {
            debugPrint('Migration step failed ($desc): $e');
          }
        }

        // Use guarded, sequential migration steps. Each step is safe to run
        // even if the schema already contains the target table/column.
        if (from < 2) {
          await _safe(() => m.createTable(inventoryItems), 'create inventoryItems');
        }

        if (from >= 2 && from < 3) {
          await _safe(() => m.addColumn(inventoryItems, inventoryItems.barcode), 'add barcode column');
        }

        if (from >= 3 && from < 4) {
          await _safe(() => m.addColumn(inventoryItems, inventoryItems.uom), 'add uom column');
          await _safe(() => m.addColumn(inventoryItems, inventoryItems.unitValue), 'add unitValue column');
        }

        if (from >= 4 && from < 5) {
          await _safe(() => m.createTable(documentSeriesNumbers), 'create documentSeriesNumbers');
          await _safe(() => ensureDefaultItemSeries(), 'ensure default item series');
        }

        if (from >= 5 && from < 6) {
          await _safe(() => m.createTable(ledgers), 'create ledgers');
          await _safe(() => m.createTable(customers), 'create customers');
          await _safe(() => m.createTable(vouchers), 'create vouchers');
          await _safe(() => m.createTable(ledgerEntries), 'create ledgerEntries');
          await _safe(() => m.addColumn(invoices, invoices.customerId), 'add invoices.customerId');
          await _safe(() => m.addColumn(invoices, invoices.paidAmount), 'add invoices.paidAmount');
        }

        if (from >= 6 && from < 7) {
            // Prefer explicit existence checks for customer columns to avoid
            // duplicate-column errors on databases that already have them.
            final customersTable = 'customers';
            if (!await _columnExists(customersTable, 'credit_limit')) {
              await _safe(() => m.addColumn(customers, customers.creditLimit), 'add customers.creditLimit');
            } else {
              debugPrint('Skipping add customers.creditLimit: column already exists');
            }

            if (!await _columnExists(customersTable, 'credit_due')) {
              await _safe(() => m.addColumn(customers, customers.creditDue), 'add customers.creditDue');
            } else {
              debugPrint('Skipping add customers.creditDue: column already exists');
            }
        }
      },
    );
  }

  static const String itemSeriesModule = 'item';

  // ============ Invoice Operations ============

  /// Get all invoices ordered by creation date (newest first)
  Future<List<Invoice>> getAllInvoices() {
    return (select(
      invoices,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  /// Get invoices by date range
  Future<List<Invoice>> getInvoicesByDateRange(DateTime start, DateTime end) {
    return (select(invoices)
          ..where((t) => t.createdAt.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Get invoices by payment mode
  Future<List<Invoice>> getInvoicesByPaymentMode(PaymentMode mode) {
    return (select(invoices)
          ..where((t) => t.paymentMode.equals(mode.index))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Get single invoice by ID
  Future<Invoice?> getInvoiceById(int id) {
    return (select(invoices)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Get invoice by invoice number
  Future<Invoice?> getInvoiceByNumber(String invoiceNo) {
    return (select(
      invoices,
    )..where((t) => t.invoiceNo.equals(invoiceNo))).getSingleOrNull();
  }

  /// Insert a new invoice
  Future<int> insertInvoice(InvoicesCompanion invoice) {
    return into(invoices).insert(invoice);
  }

  /// Update an invoice
  Future<bool> updateInvoice(Invoice invoice) {
    return update(invoices).replace(invoice);
  }

  /// Delete an invoice
  Future<int> deleteInvoice(int id) {
    return (delete(invoices)..where((t) => t.id.equals(id))).go();
  }

  /// Get invoice count for a specific date (for serial number generation)
  Future<int> getInvoiceCountForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await (select(
      invoices,
    )..where((t) => t.createdAt.isBetweenValues(startOfDay, endOfDay))).get();

    return result.length;
  }

  /// Get daily summary (total amount, count per payment mode)
  Future<Map<String, dynamic>> getDailySummary(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final dayInvoices = await (select(
      invoices,
    )..where((t) => t.createdAt.isBetweenValues(startOfDay, endOfDay))).get();

    double totalAmount = 0;
    double cashAmount = 0;
    double upiAmount = 0;
    double creditAmount = 0;

    for (final inv in dayInvoices) {
      totalAmount += inv.totalAmount;
      switch (inv.paymentMode) {
        case PaymentMode.cash:
          cashAmount += inv.totalAmount;
          break;
        case PaymentMode.upi:
          upiAmount += inv.totalAmount;
          break;
        case PaymentMode.credit:
          creditAmount += inv.totalAmount;
          break;
      }
    }

    return {
      'date': date,
      'invoiceCount': dayInvoices.length,
      'totalAmount': totalAmount,
      'cashAmount': cashAmount,
      'upiAmount': upiAmount,
      'creditAmount': creditAmount,
    };
  }

  // ============ Invoice Items Operations ============

  /// Get all items for an invoice
  Future<List<InvoiceItem>> getItemsForInvoice(int invoiceId) {
    return (select(invoiceItems)
          ..where((t) => t.invoiceId.equals(invoiceId))
          ..orderBy([(t) => OrderingTerm.asc(t.serialNo)]))
        .get();
  }

  /// Insert invoice item
  Future<int> insertInvoiceItem(InvoiceItemsCompanion item) {
    return into(invoiceItems).insert(item);
  }

  /// Insert multiple invoice items
  Future<void> insertInvoiceItems(List<InvoiceItemsCompanion> items) async {
    await batch((batch) {
      batch.insertAll(invoiceItems, items);
    });
  }

  /// Delete all items for an invoice
  Future<int> deleteItemsForInvoice(int invoiceId) {
    return (delete(
      invoiceItems,
    )..where((t) => t.invoiceId.equals(invoiceId))).go();
  }

  /// Get total items count across all invoices
  Future<int> getTotalItemsCount() async {
    final result = await select(invoiceItems).get();
    return result.length;
  }

  // ============ Inventory Operations ============

  /// Watch all inventory items (excluding archived by default)
  Stream<List<InventoryItem>> watchAllInventoryItems({
    bool includeArchived = false,
  }) {
    final query = select(inventoryItems)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

    if (!includeArchived) {
      query.where(
        (t) => t.status.isNotValue(InventoryItemStatus.archived.index),
      );
    }

    return query.watch();
  }

  /// Get inventory item by unique code
  Future<InventoryItem?> getInventoryItemByCode(String code) {
    return (select(
      inventoryItems,
    )..where((t) => t.code.equals(code))).getSingleOrNull();
  }

  /// Get inventory item by ID
  Future<InventoryItem?> getInventoryItemById(int id) {
    return (select(
      inventoryItems,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Insert a new inventory item
  Future<int> insertInventoryItem(InventoryItemsCompanion item) {
    return into(inventoryItems).insert(item);
  }

  /// Update an existing inventory item
  Future<bool> updateInventoryItem(InventoryItem item) {
    return update(inventoryItems).replace(item);
  }

  /// Delete inventory item by ID
  Future<int> deleteInventoryItem(int id) {
    return (delete(inventoryItems)..where((t) => t.id.equals(id))).go();
  }

  // ============ Ledger Operations ============

  /// Insert a new ledger entry and return the generated id.
  Future<int> insertLedger(LedgersCompanion ledger) {
    return into(ledgers).insert(ledger);
  }

  // ============ Customer Operations ============

  /// Watch all customers ordered by newest first.
  Stream<List<Customer>> watchAllCustomers() {
    return (select(
      customers,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  /// Get single customer by ID.
  Future<Customer?> getCustomerById(int id) {
    return (select(customers)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Insert a new customer.
  Future<int> insertCustomer(CustomersCompanion customer) {
    return into(customers).insert(customer);
  }

  /// Create a customer and linked customer ledger in a single transaction.
  Future<int> createCustomerWithLedger({
    required String customerName,
    String? phone,
    String? address,
  }) {
    return transaction(() async {
      final normalizedName = customerName.trim();
      final normalizedPhone = phone?.trim();
      final normalizedAddress = address?.trim();

      final ledgerId = await insertLedger(
        LedgersCompanion.insert(name: normalizedName, type: 'customer'),
      );

      return insertCustomer(
        CustomersCompanion.insert(
          name: normalizedName,
          creditLimit: const Value(500.0),
          creditDue: const Value(0.0),
          phone: Value(
            normalizedPhone == null || normalizedPhone.isEmpty
                ? null
                : normalizedPhone,
          ),
          address: Value(
            normalizedAddress == null || normalizedAddress.isEmpty
                ? null
                : normalizedAddress,
          ),
          ledgerId: ledgerId,
        ),
      );
    });
  }

  /// Update an existing customer.
  Future<bool> updateCustomer(Customer customer) {
    return update(customers).replace(customer);
  }

  /// Delete customer by ID.
  Future<int> deleteCustomer(int id) {
    return (delete(customers)..where((t) => t.id.equals(id))).go();
  }

  // ============ Document Series Operations ============

  Future<DocumentSeriesNumber?> getSeriesByModule(String module) {
    return (select(documentSeriesNumbers)
          ..where((t) => t.module.equals(module.trim().toLowerCase())))
        .getSingleOrNull();
  }

  Future<void> ensureDefaultItemSeries() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS document_series_numbers (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        module TEXT NOT NULL UNIQUE,
        starting_number INTEGER NOT NULL DEFAULT 1001,
        current_number INTEGER NOT NULL DEFAULT 1001,
        prefix TEXT,
        suffix TEXT,
        pattern TEXT NOT NULL DEFAULT '{prefix}-{current_number}',
        status INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000),
        updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000)
      )
    ''');

    // Repair older rows where timestamps may have been stored as text.
    await customStatement('''
      UPDATE document_series_numbers
      SET created_at = CAST(strftime('%s', created_at) AS INTEGER) * 1000
      WHERE typeof(created_at) = 'text'
    ''');

    await customStatement('''
      UPDATE document_series_numbers
      SET updated_at = CAST(strftime('%s', updated_at) AS INTEGER) * 1000
      WHERE typeof(updated_at) = 'text'
    ''');

    final existing = await getSeriesByModule(itemSeriesModule);
    if (existing != null) {
      return;
    }

    await into(documentSeriesNumbers).insert(
      DocumentSeriesNumbersCompanion.insert(
        module: itemSeriesModule,
        prefix: const Value('ITM'),
        startingNumber: const Value(1001),
        currentNumber: const Value(1001),
        pattern: const Value('{prefix}-{current_number}'),
        status: const Value(1),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> incrementSeriesNumber(String module) async {
    final normalizedModule = module.trim().toLowerCase();
    final nowMillis = DateTime.now().millisecondsSinceEpoch;

    await customStatement(
      'UPDATE document_series_numbers '
      'SET current_number = current_number + 1, updated_at = ? '
      'WHERE module = ?',
      [nowMillis, normalizedModule],
    );
  }

  /// Check whether a specific column exists in a table using PRAGMA.
  Future<bool> _columnExists(String table, String column) async {
    try {
      final rows = await customSelect('PRAGMA table_info("$table")').get();
      for (final row in rows) {
        try {
          final name = row.readString('name');
          if (name == column) return true;
        } catch (_) {
          // ignore rows that don't have the expected column
        }
      }
      return false;
    } catch (e) {
      debugPrint('Failed to check column existence for $table.$column: $e');
      // If we can't determine, be conservative and return false so migration will attempt
      return false;
    }
  }
}

/// Opens a connection to the database
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'billing_app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
