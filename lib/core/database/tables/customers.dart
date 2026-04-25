import 'package:drift/drift.dart';

import 'ledgers.dart';

class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 120)();

  TextColumn get phone => text().withLength(min: 1, max: 20).nullable()();

  TextColumn get address => text().withLength(min: 1, max: 255).nullable()();

  IntColumn get ledgerId => integer().references(Ledgers, #id)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}