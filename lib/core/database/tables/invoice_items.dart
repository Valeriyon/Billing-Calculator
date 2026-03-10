import 'package:drift/drift.dart';
import 'invoices.dart';

/// Invoice items table definition for Drift
class InvoiceItems extends Table {
  /// Primary key - auto increment
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key to invoice
  IntColumn get invoiceId => integer().references(Invoices, #id)();

  /// Item name (default: "Item 1", "Item 2", etc.)
  TextColumn get itemName => text().withLength(min: 1, max: 100)();

  /// Quantity (can be decimal, e.g., 1.5)
  RealColumn get quantity => real()();

  /// Rate per unit (can be decimal, e.g., 12.50)
  RealColumn get rate => real()();

  /// Total = quantity * rate
  RealColumn get total => real()();

  /// Item-level discount (optional)
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();

  /// Serial number for ordering within invoice
  IntColumn get serialNo => integer().withDefault(const Constant(1))();

  /// Created timestamp
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
