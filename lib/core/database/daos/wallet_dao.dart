import 'package:drift/drift.dart';
import 'package:zplit/core/database/tables/wallet_table.dart';
import 'package:zplit/core/database/app_database.dart';

part 'wallet_dao.g.dart';

@DriftAccessor(tables: [WalletDetailsTable])
class WalletDetailsDao extends DatabaseAccessor<AppDatabase>
    with _$WalletDetailsDaoMixin {
  WalletDetailsDao(super.db);

  Future<List<WalletDetailsTableData>> getAll() {
    return select(walletDetailsTable).get();
  }

  Future<WalletDetailsTableData?> getById(int id) {
    final query = select(walletDetailsTable);
    query.where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<int> insert(WalletDetailsTableCompanion wallet) {
    return into(walletDetailsTable).insert(wallet);
  }

  Future<void> upsert(WalletDetailsTableCompanion wallet) {
    return into(walletDetailsTable).insertOnConflictUpdate(wallet);
  }

  Future<int> deletewallet(int id) {
    final query = delete(walletDetailsTable);
    query.where((t) => t.id.equals(id));
    return query.go();
  }
}
