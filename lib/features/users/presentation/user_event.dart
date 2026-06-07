part of 'user_bloc.dart';

@freezed
class UserEvent with _$UserEvent {
  const factory UserEvent.loadAll() = LoadAllUsers;

  const factory UserEvent.loadByPublicKey({required String publicKey}) =
      LoadUserByPublicKey;

  const factory UserEvent.upsert({
    required String publicKey,
    required String displayName,
    String? cryptoAddress,
    String? profilePicture,
    String? defaultCurrency,
  }) = UpsertUser;

  const factory UserEvent.delete({required String publicKey}) = DeleteUser;
}
