import 'package:drift/drift.dart';
import 'package:zplit/core/database/app_database.dart';
import 'package:zplit/core/database/daos/balances_dao.dart';
import 'package:zplit/core/database/tables/balances_table.dart';

class BalancesRepository {
  final BalancesDao _balancesDao;

  BalancesRepository({required BalancesDao balancesDao})
    : _balancesDao = balancesDao;

  Future<List<BalancesTableData>> getAllBalances() {
    return _balancesDao.getAll();
  }

  Future<List<BalancesTableData>> getBalancesForUser(
    String userPublicKey,
  ) async {
    final all = await _balancesDao.getAll();
    return all.where((b) => b.userPublicKey == userPublicKey).toList();
  }

  Future<BalancesTableData?> getBalanceForUserAndCurrency(
    String userPublicKey,
    String currency,
  ) {
    return _balancesDao.getByPublicKeyAndCurrency(userPublicKey, currency);
  }

  Future<List<BalancesTableData>> getPositiveBalances() async {
    final all = await _balancesDao.getAll();
    return all.where((b) => b.netAmount > 0).toList();
  }

  Future<List<BalancesTableData>> getNegativeBalances() async {
    final all = await _balancesDao.getAll();
    return all.where((b) => b.netAmount < 0).toList();
  }

  Future<void> upsertBalance(BalancesTableCompanion balance) {
    return _balancesDao.upsert(balance);
  }

  Future<int> deleteByPublicKey(String userPublicKey) {
    return _balancesDao.deleteBalances(userPublicKey);
  }
}
