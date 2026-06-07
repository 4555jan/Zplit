part of 'user_bloc.dart';

@freezed
class UserState with _$UserState {
  const factory UserState.initial() = UserInitial;

  const factory UserState.loading() = UserLoading;

  const factory UserState.allLoaded({required List<UsersTableData> users}) =
      UsersAllLoaded;

  const factory UserState.singleLoaded({required UsersTableData user}) =
      UserSingleLoaded;

  const factory UserState.success({required String message}) = UserSuccess;

  const factory UserState.error({required String message}) = UserError;
}
