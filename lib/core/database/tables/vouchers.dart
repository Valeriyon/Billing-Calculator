import 'package:drift/drift.dart';

class Vouchers extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get type => text().withLength(min: 1, max: 20)();

  IntColumn get referenceId => integer().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}