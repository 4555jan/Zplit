import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zplit/features/balance/domain/repositories/balance_repository.dart';
import 'package:zplit/features/balance/presentation/balance_event.dart';
import 'package:zplit/features/balance/presentation/balance_state.dart';

class BalanceBloc extends Bloc<BalanceEvent, BalanceState> {
  final BalanceRepository _balanceRepository;

  BalanceBloc({required BalanceRepository balanceRepository})
    : _balanceRepository = balanceRepository,
      super(BalanceInitial()) {
    on<BalanceEvent>((event, emit) async {
      if (event is LoadAllBalances) {
        emit(BalanceLoading());
        try {
          final balances = await _balanceRepository.getAllBalances();
          emit(BalanceLoaded(balances));
        } catch (e) {
          emit(BalanceError(e.toString()));
        }
      } else if (event is LoadBalancesForUser) {
        emit(BalanceLoading());
        try {
          final balances = await _balanceRepository.getBalancesForUser(
            event.userPublicKey,
          );
          emit(BalanceLoaded(balances));
        } catch (e) {
          emit(BalanceError(e.toString()));
        }
      } else if (event is LoadPositiveBalances) {
        emit(BalanceLoading());
        try {
          final balances = await _balanceRepository.getPositiveBalances();
          emit(BalanceLoaded(balances));
        } catch (e) {
          emit(BalanceError(e.toString()));
        }
      } else if (event is LoadNegativeBalances) {
        emit(BalanceLoading());
        try {
          final balances = await _balanceRepository.getNegativeBalances();
          emit(BalanceLoaded(balances));
        } catch (e) {
          emit(BalanceError(e.toString()));
        }
      } else if (event is UpsertBalance) {
        emit(BalanceLoading());
        try {
          await _balanceRepository.upsertBalance(
            userPublicKey: event.userPublicKey,
            netAmount: event.netAmount,
            currency: event.currency,
            signed: event.signed,
          );
          final balances = await _balanceRepository.getAllBalances();
          emit(BalanceLoaded(balances));
        } catch (e) {
          emit(BalanceError(e.toString()));
        }
      } else if (event is DeleteBalance) {
        emit(BalanceLoading());
        try {
          await _balanceRepository.deleteByPublicKey(event.userPublicKey);
          final balances = await _balanceRepository.getAllBalances();
          emit(BalanceLoaded(balances));
        } catch (e) {
          emit(BalanceError(e.toString()));
        }
      }
    });
  }
}
