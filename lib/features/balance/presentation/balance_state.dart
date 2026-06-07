part of 'balance_bloc.dart';

@freezed
class BalancesState with _$BalancesState {
  const factory BalancesState.initial() = BalancesInitial;

  const factory BalancesState.loading() = BalancesLoading;

  const factory BalancesState.allLoaded({
    required List<BalancesTableData> balances,
  }) = BalancesAllLoaded;

  const factory BalancesState.userLoaded({
    required List<BalancesTableData> balances,
  }) = BalancesUserLoaded;

  const factory BalancesState.singleLoaded({
    required BalancesTableData? balance,
  }) = BalancesSingleLoaded;

  const factory BalancesState.success({required String message}) =
      BalancesSuccess;

  const factory BalancesState.error({required String message}) = BalancesError;
}
