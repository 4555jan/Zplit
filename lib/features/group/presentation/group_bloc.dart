import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zplit/features/group/domain/repositories/group_repository.dart';
import 'package:zplit/features/group/presentation/group_event.dart';
import 'package:zplit/features/group/presentation/group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupRepository _groupRepository;

  GroupBloc({required GroupRepository groupRepository})
    : _groupRepository = groupRepository,
      super(GroupInitial()) {
    on<GroupEvent>((event, emit) async {
      if (event is LoadAllGroups) {
        emit(GroupLoading());
        try {
          final groups = await _groupRepository.getAllGroups();
          emit(GroupLoaded(groups));
        } catch (e) {
          emit(GroupError(e.toString()));
        }
      } else if (event is GetGroupById) {
        emit(GroupLoading());
        try {
          final group = await _groupRepository.getGroupById(event.id);
          emit(GroupLoaded(group == null ? [] : [group]));
        } catch (e) {
          emit(GroupError(e.toString()));
        }
      } else if (event is UpsertGroup) {
        emit(GroupLoading());
        try {
          await _groupRepository.upsertGroup(
            name: event.name,
            description: event.description,
            users: event.users,
          );
          final groups = await _groupRepository.getAllGroups();
          emit(GroupLoaded(groups));
        } catch (e) {
          emit(GroupError(e.toString()));
        }
      } else if (event is DeleteGroup) {
        emit(GroupLoading());
        try {
          await _groupRepository.deleteGroup(event.id);
          final groups = await _groupRepository.getAllGroups();
          emit(GroupLoaded(groups));
        } catch (e) {
          emit(GroupError(e.toString()));
        }
      }
    });
  }
}
