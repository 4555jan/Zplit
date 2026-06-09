import 'package:zplit/features/group/domain/models/group_model.dart';

abstract class GroupRepository {
  Future<List<GroupModel>> getAllGroups();
  Future<GroupModel?> getGroupById(String id);
  Future<void> upsertGroup({
    required String name,
    String? description,
    List<String> users,
  });
  Future<int> deleteGroup(String id);
}
