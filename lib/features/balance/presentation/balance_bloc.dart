import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zplit/core/database/app_database.dart';
import 'package:zplit/core/database/tables/balances_table.dart';
import 'package:zplit/features/balance/data/balance_repository.dart';

part 'balance_event.dart';
part 'balance_state.dart';
part 'balance_bloc.freezed.dart';

class BalancesBloc extends Bloc<BalancesEvent, BalancesState> {
  final BalancesRepository _repository;

  BalancesBloc({required BalancesRepository repository})
    : _repository = repository,
      super(const BalancesState.initial()) {
    on<LoadAllBalances>(_onLoadAll);
    on<LoadBalanceByUser>(_onLoadByUser);
    on<LoadBalanceByUserAndCurrency>(_onLoadByUserAndCurrency);
    on<LoadPositiveBalances>(_onLoadPositive);
    on<LoadNegativeBalances>(_onLoadNegative);
    on<UpsertBalance>(_onUpsert);
    on<DeleteBalance>(_onDelete);
  }

  Future<void> _onLoadAll(
    LoadAllBalances event,
    Emitter<BalancesState> emit,
  ) async {
    emit(const BalancesState.loading());
    try {
      final balances = await _repository.getAllBalances();
      emit(BalancesState.allLoaded(balances: balances));
    } catch (e) {
      emit(BalancesState.error(message: e.toString()));
    }
  }

  Future<void> _onLoadByUser(
    LoadBalanceByUser event,
    Emitter<BalancesState> emit,
  ) async {
    emit(const BalancesState.loading());
    try {
      final balances = await _repository.getBalancesForUser(
        event.userPublicKey,
      );
      emit(BalancesState.userLoaded(balances: balances));
    } catch (e) {
      emit(BalancesState.error(message: e.toString()));
    }
  }

  Future<void> _onLoadByUserAndCurrency(
    LoadBalanceByUserAndCurrency event,
    Emitter<BalancesState> emit,
  ) async {
    emit(const BalancesState.loading());
    try {
      final balance = await _repository.getBalanceForUserAndCurrency(
        event.userPublicKey,
        event.currency,
      );
      emit(BalancesState.singleLoaded(balance: balance));
    } catch (e) {
      emit(BalancesState.error(message: e.toString()));
    }
  }

  Future<void> _onLoadPositive(
    LoadPositiveBalances event,
    Emitter<BalancesState> emit,
  ) async {
    emit(const BalancesState.loading());
    try {
      final balances = await _repository.getPositiveBalances();
      emit(BalancesState.allLoaded(balances: balances));
    } catch (e) {
      emit(BalancesState.error(message: e.toString()));
    }
  }

  Future<void> _onLoadNegative(
    LoadNegativeBalances event,
    Emitter<BalancesState> emit,
  ) async {
    emit(const BalancesState.loading());
    try {
      final balances = await _repository.getNegativeBalances();
      emit(BalancesState.allLoaded(balances: balances));
    } catch (e) {
      emit(BalancesState.error(message: e.toString()));
    }
  }

  Future<void> _onUpsert(
    UpsertBalance event,
    Emitter<BalancesState> emit,
  ) async {
    emit(const BalancesState.loading());
    try {
      await _repository.upsertBalance(event.balance);
      emit(const BalancesState.success(message: 'Balance updated'));
    } catch (e) {
      emit(BalancesState.error(message: e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteBalance event,
    Emitter<BalancesState> emit,
  ) async {
    emit(const BalancesState.loading());
    try {
      await _repository.deleteByPublicKey(event.userPublicKey);
      emit(const BalancesState.success(message: 'Balance deleted'));
    } catch (e) {
      emit(BalancesState.error(message: e.toString()));
    }
  }
}
