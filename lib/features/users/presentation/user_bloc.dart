import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zplit/core/database/app_database.dart';
import 'package:zplit/core/database/tables/users_table.dart';

import 'package:zplit/features/users/data/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';
part 'user_bloc.freezed.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _repository;

  UserBloc({required UserRepository repository})
    : _repository = repository,
      super(const UserState.initial()) {
    on<LoadAllUsers>(_onLoadAll);
    on<LoadUserByPublicKey>(_onLoadByPublicKey);
    on<UpsertUser>(_onUpsert);
    on<DeleteUser>(_onDelete);
  }

  Future<void> _onLoadAll(LoadAllUsers event, Emitter<UserState> emit) async {
    emit(const UserState.loading());
    try {
      final users = await _repository.getAllUsers();
      emit(UserState.allLoaded(users: users));
    } catch (e) {
      emit(UserState.error(message: e.toString()));
    }
  }

  Future<void> _onLoadByPublicKey(
    LoadUserByPublicKey event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserState.loading());
    try {
      final user = await _repository.getUserByPublicKey(event.publicKey);
      if (user == null) {
        emit(const UserState.error(message: 'User not found'));
        return;
      }
      emit(UserState.singleLoaded(user: user));
    } catch (e) {
      emit(UserState.error(message: e.toString()));
    }
  }

  Future<void> _onUpsert(UpsertUser event, Emitter<UserState> emit) async {
    emit(const UserState.loading());
    try {
      await _repository.upsertUser(
        publicKey: event.publicKey,
        displayName: event.displayName,
        cryptoAddress: event.cryptoAddress,
        profilePicture: event.profilePicture,
        defaultCurrency: event.defaultCurrency,
      );
      emit(const UserState.success(message: 'User saved successfully'));
    } catch (e) {
      emit(UserState.error(message: e.toString()));
    }
  }

  Future<void> _onDelete(DeleteUser event, Emitter<UserState> emit) async {
    emit(const UserState.loading());
    try {
      await _repository.deleteUser(event.publicKey);
      emit(const UserState.success(message: 'User deleted successfully'));
    } catch (e) {
      emit(UserState.error(message: e.toString()));
    }
  }
}
