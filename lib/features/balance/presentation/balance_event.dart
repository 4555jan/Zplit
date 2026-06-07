part of 'balance_bloc.dart';

@freezed
class BalancesEvent with _$BalancesEvent {
  const factory BalancesEvent.loadAll() = LoadAllBalances;

  const factory BalancesEvent.loadByUser({required String userPublicKey}) =
      LoadBalanceByUser;

  const factory BalancesEvent.loadByUserAndCurrency({
    required String userPublicKey,
    required String currency,
  }) = LoadBalanceByUserAndCurrency;

  const factory BalancesEvent.loadPositive() = LoadPositiveBalances;

  const factory BalancesEvent.loadNegative() = LoadNegativeBalances;

  const factory BalancesEvent.upsert({
    required BalancesTableCompanion balance,
  }) = UpsertBalance;

  const factory BalancesEvent.delete({required String userPublicKey}) =
      DeleteBalance;
}
