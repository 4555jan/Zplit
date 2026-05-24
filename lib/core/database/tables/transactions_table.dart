import 'package:drift/drift.dart';

enum TransactionStatus { unsigned, partiallySigned, signed }

class TransactionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get fromUserPublicKey => text()();
  TextColumn get toUserPublicKey => text()();
  IntColumn get amount => integer()();
  TextColumn get description => text().nullable()();
  TextColumn get tag => text().nullable()();
  TextColumn get status => textEnum<TransactionStatus>()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get senderSignature => text().nullable()();
  TextColumn get receiverSignature => text().nullable()();

  @override
  String get tableName => 'transactions';

  @override
  Set<Column> get primaryKey => {id};
}
