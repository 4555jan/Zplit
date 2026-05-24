import 'package:drift/drift.dart';

class WalletDetailsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get privateKey => text()();
  TextColumn get publicKey => text()();
  TextColumn get mnemonic => text()();
  TextColumn get walletAddress => text()();

  @override
  String get tableName => 'wallet_details';
}
