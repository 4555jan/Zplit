part of 'transaction_bloc.dart';

@freezed
class TransactionState with _$TransactionState {
  const factory TransactionState.initial() = TransactionInitial;

  const factory TransactionState.loading() = TransactionLoading;

  const factory TransactionState.allLoaded({
    required List<TransactionsTableData> transactions,
  }) = TransactionsAllLoaded;

  const factory TransactionState.singleLoaded({
    required TransactionsTableData transaction,
  }) = TransactionSingleLoaded;

  const factory TransactionState.success({required String message}) =
      TransactionSuccess;

  const factory TransactionState.error({required String message}) =
      TransactionError;
}
