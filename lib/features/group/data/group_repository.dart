import 'package:drift/drift.dart';
import 'package:zplit/core/database/app_database.dart';
import 'package:zplit/core/database/daos/groups_dao.dart';
import 'package:zplit/core/database/tables/groups_table.dart';

class GroupRepository {
  final GroupsDao _groupsDao;

  GroupRepository({required GroupsDao groupsDao}) : _groupsDao = groupsDao;

  Future<List<GroupsTableData>> getAllGroups() {
    return _groupsDao.getAll();
  }

  Future<GroupsTableData?> getGroupById(String id) {
    return _groupsDao.getById(id);
  }

  Future<void> upsertGroup({
    required String name,
    String? description,
    String? users,
  }) {
    return _groupsDao.upsert(
      GroupsTableCompanion(
        name: Value(name),
        description: Value(description),
        users: Value(users ?? ''),
      ),
    );
  }

  Future<int> deleteGroup(String id) {
    return _groupsDao.deleteGroup(id);
  }
}
