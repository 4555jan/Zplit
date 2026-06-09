import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zplit/features/users/domain/repositories/user_repository.dart';
import 'package:zplit/features/users/presentation/user_event.dart';
import 'package:zplit/features/users/presentation/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(UserInitial()) {
    on<UserEvent>((event, emit) async {
      if (event is LoadAllUsers) {
        emit(UserLoading());
        try {
          final users = await _userRepository.getAllUsers();
          emit(UserLoaded(users));
        } catch (e) {
          emit(UserError(e.toString()));
        }
      } else if (event is GetUserByPublicKey) {
        emit(UserLoading());
        try {
          final user = await _userRepository.getUserByPublicKey(
            event.publicKey,
          );
          emit(UserLoaded(user == null ? [] : [user]));
        } catch (e) {
          emit(UserError(e.toString()));
        }
      } else if (event is UpsertUser) {
        emit(UserLoading());
        try {
          await _userRepository.upsertUser(
            publicKey: event.publicKey,
            displayName: event.displayName,
            cryptoAddress: event.cryptoAddress,
            profilePicture: event.profilePicture,
            defaultCurrency: event.defaultCurrency,
          );
          final users = await _userRepository.getAllUsers();
          emit(UserLoaded(users));
        } catch (e) {
          emit(UserError(e.toString()));
        }
      } else if (event is DeleteUser) {
        emit(UserLoading());
        try {
          await _userRepository.deleteUser(event.publicKey);
          final users = await _userRepository.getAllUsers();
          emit(UserLoaded(users));
        } catch (e) {
          emit(UserError(e.toString()));
        }
      }
    });
  }
}
