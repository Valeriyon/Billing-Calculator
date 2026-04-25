import 'package:drift/drift.dart';

class Ledgers extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 120)();

  TextColumn get type => text().withLength(min: 1, max: 20)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}