import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/invoices.dart';
import 'tables/invoice_items.dart';

part 'app_database.g.dart';

/// Main database class for the billing app
@DriftDatabase(tables: [Invoices, InvoiceItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future migrations here
      },
    );
  }

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
}

/// Opens a connection to the database
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'billing_app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
