import 'package:drift/drift.dart';

/// Payment mode enum for invoices
enum PaymentMode { cash, upi, credit }

/// Payment status enum
enum PaymentStatus { pending, partial, fulfilled }

/// Invoices table definition for Drift
class Invoices extends Table {
  /// Primary key - auto increment
  IntColumn get id => integer().autoIncrement()();

  /// Unique invoice number (e.g., INV-20260125-001)
  TextColumn get invoiceNo => text().withLength(min: 1, max: 50).unique()();

  /// Total amount before discount
  RealColumn get subtotalAmount => real().withDefault(const Constant(0.0))();

  /// Discount amount
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();

  /// Total amount after discount
  RealColumn get totalAmount => real().withDefault(const Constant(0.0))();

  /// Payment mode (cash, upi, credit)
  IntColumn get paymentMode => intEnum<PaymentMode>()();

  /// Payment status (pending, partial, fulfilled)
  IntColumn get paymentStatus => intEnum<PaymentStatus>()();

  /// Optional notes
  TextColumn get notes => text().nullable()();

  /// Created timestamp
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Updated timestamp
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
