import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zplit/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:zplit/features/transaction/presentation/transaction_event.dart';
import 'package:zplit/features/transaction/presentation/transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository;

  TransactionBloc({required TransactionRepository transactionRepository})
    : _transactionRepository = transactionRepository,
      super(TransactionInitial()) {
    on<TransactionEvent>((event, emit) async {
      if (event is LoadAllTransactions) {
        emit(TransactionLoading());
        try {
          final transactions = await _transactionRepository
              .getAllTransactions();
          emit(TransactionLoaded(transactions));
        } catch (e) {
          emit(TransactionError(e.toString()));
        }
      } else if (event is GetTransactionById) {
        emit(TransactionLoading());
        try {
          final tx = await _transactionRepository.getTransactionById(event.id);
          emit(TransactionLoaded(tx == null ? [] : [tx]));
        } catch (e) {
          emit(TransactionError(e.toString()));
        }
      } else if (event is CreateTransaction) {
        emit(TransactionLoading());
        try {
          await _transactionRepository.createTransaction(
            fromUserPublicKey: event.fromUserPublicKey,
            toUserPublicKey: event.toUserPublicKey,
            amount: event.amount,
            currency: event.currency,
            description: event.description,
            tag: event.tag,
          );
          final transactions = await _transactionRepository
              .getAllTransactions();
          emit(TransactionLoaded(transactions));
        } catch (e) {
          emit(TransactionError(e.toString()));
        }
      } else if (event is SignAsSender) {
        emit(TransactionLoading());
        try {
          await _transactionRepository.signAsSender(
            transactionId: event.transactionId,
            senderSignature: event.senderSignature,
          );
          final transactions = await _transactionRepository
              .getAllTransactions();
          emit(TransactionLoaded(transactions));
        } catch (e) {
          emit(TransactionError(e.toString()));
        }
      } else if (event is AcceptTransaction) {
        emit(TransactionLoading());
        try {
          await _transactionRepository.acceptTransaction(
            transactionId: event.transactionId,
            receiverSignature: event.receiverSignature,
            signedBalancePayload: event.signedBalancePayload,
          );
          final transactions = await _transactionRepository
              .getAllTransactions();
          emit(TransactionLoaded(transactions));
        } catch (e) {
          emit(TransactionError(e.toString()));
        }
      } else if (event is RejectTransaction) {
        emit(TransactionLoading());
        try {
          await _transactionRepository.rejectTransaction(event.transactionId);
          final transactions = await _transactionRepository
              .getAllTransactions();
          emit(TransactionLoaded(transactions));
        } catch (e) {
          emit(TransactionError(e.toString()));
        }
      }
    });
  }
}
