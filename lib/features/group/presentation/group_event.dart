part of 'group_bloc.dart';

@freezed
class GroupEvent with _$GroupEvent {
  /// Load all local groups
  const factory GroupEvent.loadAll() = LoadAllGroups;

  /// Load a single group by id
  const factory GroupEvent.loadById({required String id}) = LoadGroupById;

  /// Create or update a group
  const factory GroupEvent.upsert({
    required String name,
    String? description,
    String? users,
  }) = UpsertGroup;

  /// Delete a group
  const factory GroupEvent.delete({required String id}) = DeleteGroup;
}
