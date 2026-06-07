import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zplit/core/database/app_database.dart';
import 'package:zplit/core/database/tables/groups_table.dart';
import 'package:zplit/features/group/data/group_repository.dart';

part 'group_event.dart';
part 'group_state.dart';
part 'group_bloc.freezed.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupRepository _repository;

  GroupBloc({required GroupRepository repository})
    : _repository = repository,
      super(const GroupState.initial()) {
    on<LoadAllGroups>(_onLoadAll);
    on<LoadGroupById>(_onLoadById);
    on<UpsertGroup>(_onUpsert);
    on<DeleteGroup>(_onDelete);
  }

  Future<void> _onLoadAll(LoadAllGroups event, Emitter<GroupState> emit) async {
    emit(const GroupState.loading());
    try {
      final groups = await _repository.getAllGroups();
      emit(GroupState.allLoaded(groups: groups));
    } catch (e) {
      emit(GroupState.error(message: e.toString()));
    }
  }

  Future<void> _onLoadById(
    LoadGroupById event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupState.loading());
    try {
      final group = await _repository.getGroupById(event.id);
      if (group == null) {
        emit(const GroupState.error(message: 'Group not found'));
        return;
      }
      emit(GroupState.singleLoaded(group: group));
    } catch (e) {
      emit(GroupState.error(message: e.toString()));
    }
  }

  Future<void> _onUpsert(UpsertGroup event, Emitter<GroupState> emit) async {
    emit(const GroupState.loading());
    try {
      await _repository.upsertGroup(
        name: event.name,
        description: event.description,
        users: event.users,
      );
      emit(const GroupState.success(message: 'Group saved'));
    } catch (e) {
      emit(GroupState.error(message: e.toString()));
    }
  }

  Future<void> _onDelete(DeleteGroup event, Emitter<GroupState> emit) async {
    emit(const GroupState.loading());
    try {
      await _repository.deleteGroup(event.id);
      emit(const GroupState.success(message: 'Group deleted'));
    } catch (e) {
      emit(GroupState.error(message: e.toString()));
    }
  }
}
