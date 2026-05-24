import 'package:drift/drift.dart';

class BalancesTable extends Table {
  TextColumn get userPublicKey => text()();
  IntColumn get netAmount => integer()();
  TextColumn get signed => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  String get tableName => 'balances';

  @override
  Set<Column> get primaryKey => {userPublicKey};
}
