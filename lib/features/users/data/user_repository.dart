import 'package:drift/drift.dart';
import 'package:zplit/core/database/app_database.dart';
import 'package:zplit/core/database/daos/users_dao.dart';
import 'package:zplit/core/database/tables/users_table.dart';

class UserRepository {
  final UsersDao _usersDao;

  UserRepository({required UsersDao usersDao}) : _usersDao = usersDao;

  Future<List<UsersTableData>> getAllUsers() {
    return _usersDao.getAll();
  }

  Future<UsersTableData?> getUserByPublicKey(String publicKey) {
    return _usersDao.getByPublicKey(publicKey);
  }

  Future<void> upsertUser({
    required String publicKey,
    required String displayName,
    String? cryptoAddress,
    String? profilePicture,
    String? defaultCurrency,
  }) {
    return _usersDao.upsert(
      UsersTableCompanion(
        publicKey: Value(publicKey),
        displayName: Value(displayName),
        cryptoAddress: Value(cryptoAddress),
        profilePicture: Value(profilePicture),
        defaultCurrency: Value(defaultCurrency),
      ),
    );
  }

  Future<int> deleteUser(String publicKey) {
    return _usersDao.deleteUser(publicKey);
  }
}
