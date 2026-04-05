import 'package:drift/drift.dart';

/// Configurable number series for document modules (item, invoice, etc.)
class DocumentSeriesNumbers extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Module key, e.g. 'item', 'invoice'
  TextColumn get module => text().withLength(min: 1, max: 40).unique()();

  /// First number of the series
  IntColumn get startingNumber => integer().withDefault(const Constant(1001))();

  /// Current number to be used for formatting
  IntColumn get currentNumber => integer().withDefault(const Constant(1001))();

  /// Optional prefix in the formatted code
  TextColumn get prefix => text().withLength(min: 1, max: 20).nullable()();

  /// Optional suffix in the formatted code
  TextColumn get suffix => text().withLength(min: 1, max: 20).nullable()();

  /// Supported tokens: {prefix}, {current_number}, {suffix}
  TextColumn get pattern =>
      text().withDefault(const Constant('{prefix}-{current_number}'))();

  /// 1: Active, 0: Inactive
  IntColumn get status => integer().withDefault(const Constant(1))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
