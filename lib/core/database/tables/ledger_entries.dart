import 'package:drift/drift.dart';

import 'ledgers.dart';
import 'vouchers.dart';

class LedgerEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get voucherId => integer().references(Vouchers, #id)();

  IntColumn get ledgerId => integer().references(Ledgers, #id)();

  RealColumn get debit => real().withDefault(const Constant(0.0))();

  RealColumn get credit => real().withDefault(const Constant(0.0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
