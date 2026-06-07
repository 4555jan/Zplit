part of 'group_bloc.dart';

@freezed
class GroupState with _$GroupState {
  const factory GroupState.initial() = GroupInitial;

  const factory GroupState.loading() = GroupLoading;

  const factory GroupState.allLoaded({required List<GroupsTableData> groups}) =
      GroupsAllLoaded;

  const factory GroupState.singleLoaded({required GroupsTableData group}) =
      GroupSingleLoaded;

  const factory GroupState.success({required String message}) = GroupSuccess;

  const factory GroupState.error({required String message}) = GroupError;
}
