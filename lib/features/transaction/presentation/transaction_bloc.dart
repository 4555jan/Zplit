import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zplit/core/database/app_database.dart';
import 'package:zplit/core/database/tables/transactions_table.dart';
import 'package:zplit/features/transaction/data/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';
part 'transaction_bloc.freezed.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _repository;

  TransactionBloc({required TransactionRepository repository})
    : _repository = repository,
      super(const TransactionState.initial()) {
    on<LoadAllTransactions>(_onLoadAll);
    on<LoadTransactionById>(_onLoadById);
    on<CreateTransaction>(_onCreate);
    on<SignAsSender>(_onSignAsSender);
    on<AcceptTransaction>(_onAccept);
    on<RejectTransaction>(_onReject);
  }

  Future<void> _onLoadAll(
    LoadAllTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionState.loading());
    try {
      final transactions = await _repository.getAllTransactions();
      emit(TransactionState.allLoaded(transactions: transactions));
    } catch (e) {
      emit(TransactionState.error(message: e.toString()));
    }
  }

  Future<void> _onLoadById(
    LoadTransactionById event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionState.loading());
    try {
      final transaction = await _repository.getTransactionById(event.id);
      if (transaction == null) {
        emit(const TransactionState.error(message: 'Transaction not found'));
        return;
      }
      emit(TransactionState.singleLoaded(transaction: transaction));
    } catch (e) {
      emit(TransactionState.error(message: e.toString()));
    }
  }

  Future<void> _onCreate(
    CreateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionState.loading());
    try {
      await _repository.createTransaction(
        fromUserPublicKey: event.fromUserPublicKey,
        toUserPublicKey: event.toUserPublicKey,
        amount: event.amount,
        currency: event.currency,
        description: event.description,
        tag: event.tag,
      );
      emit(const TransactionState.success(message: 'Transaction created'));
    } catch (e) {
      emit(TransactionState.error(message: e.toString()));
    }
  }

  Future<void> _onSignAsSender(
    SignAsSender event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionState.loading());
    try {
      await _repository.signAsSender(
        transactionId: event.transactionId,
        senderSignature: event.senderSignature,
      );
      emit(const TransactionState.success(message: 'Transaction signed'));
    } catch (e) {
      emit(TransactionState.error(message: e.toString()));
    }
  }

  Future<void> _onAccept(
    AcceptTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionState.loading());
    try {
      await _repository.acceptTransaction(
        transactionId: event.transactionId,
        receiverSignature: event.receiverSignature,
        signedBalancePayload: event.signedBalancePayload,
      );
      emit(
        const TransactionState.success(
          message: 'Transaction accepted and balance updated',
        ),
      );
    } catch (e) {
      emit(TransactionState.error(message: e.toString()));
    }
  }

  Future<void> _onReject(
    RejectTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _repository.rejectTransaction(event.transactionId);
      emit(const TransactionState.success(message: 'Transaction rejected'));
    } catch (e) {
      emit(TransactionState.error(message: e.toString()));
    }
  }
}
