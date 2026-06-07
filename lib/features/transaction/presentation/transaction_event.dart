part of 'transaction_bloc.dart';

@freezed
class TransactionEvent with _$TransactionEvent {
  const factory TransactionEvent.loadAll() = LoadAllTransactions;

  const factory TransactionEvent.loadById({required String id}) =
      LoadTransactionById;

  const factory TransactionEvent.create({
    required String fromUserPublicKey,
    required String toUserPublicKey,
    required int amount,
    required String currency,
    String? description,
    String? tag,
  }) = CreateTransaction;

  const factory TransactionEvent.signAsSender({
    required String transactionId,
    required String senderSignature,
  }) = SignAsSender;

  const factory TransactionEvent.accept({
    required String transactionId,
    required String receiverSignature,
    required String signedBalancePayload,
  }) = AcceptTransaction;

  const factory TransactionEvent.reject({required String transactionId}) =
      RejectTransaction;
}
