import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import 'package:zplit/core/database/app_database.dart';
import 'package:zplit/core/database/daos/transactions_dao.dart';
import 'package:zplit/core/database/daos/balances_dao.dart';
import 'package:zplit/core/database/tables/transactions_table.dart';
import 'package:zplit/core/database/tables/balances_table.dart';

const _uuid = Uuid();

class TransactionRepository {
  final TransactionsDao _transactionsDao;
  final BalancesDao _balancesDao;

  TransactionRepository({
    required TransactionsDao transactionsDao,
    required BalancesDao balancesDao,
  }) : _transactionsDao = transactionsDao,
       _balancesDao = balancesDao;

  Future<List<TransactionsTableData>> getAllTransactions() {
    return _transactionsDao.getAll();
  }

  Future<TransactionsTableData?> getTransactionById(String id) {
    return _transactionsDao.getById(id);
  }

  Future<void> createTransaction({
    required String fromUserPublicKey,
    required String toUserPublicKey,
    required int amount,
    required String currency,
    String? description,
    String? tag,
  }) {
    return _transactionsDao.insert(
      TransactionsTableCompanion.insert(
        id: _uuid.v4(),
        fromUserPublicKey: fromUserPublicKey,
        toUserPublicKey: toUserPublicKey,
        amount: amount,
        currency: currency,
        status: TransactionStatus.unsigned,
        description: Value(description),
        tag: Value(tag),
      ),
    );
  }

  Future<void> signAsSender({
    required String transactionId,
    required String senderSignature,
  }) async {
    final existing = await _transactionsDao.getById(transactionId);
    if (existing == null) throw Exception('Transaction not found');

    await _transactionsDao.insert(
      TransactionsTableCompanion.insert(
        id: transactionId,
        fromUserPublicKey: existing.fromUserPublicKey,
        toUserPublicKey: existing.toUserPublicKey,
        amount: existing.amount,
        currency: existing.currency,
        status: TransactionStatus.partiallySigned,
        description: Value(existing.description),
        tag: Value(existing.tag),
        senderSignature: Value(senderSignature),
      ),
    );
  }

  Future<void> acceptTransaction({
    required String transactionId,
    required String receiverSignature,
    required String signedBalancePayload,
  }) async {
    final existing = await _transactionsDao.getById(transactionId);
    if (existing == null) throw Exception('Transaction not found');

    await _transactionsDao.insert(
      TransactionsTableCompanion.insert(
        id: transactionId,
        fromUserPublicKey: existing.fromUserPublicKey,
        toUserPublicKey: existing.toUserPublicKey,
        amount: existing.amount,
        currency: existing.currency,
        status: TransactionStatus.signed,
        description: Value(existing.description),
        tag: Value(existing.tag),
        senderSignature: Value(existing.senderSignature),
        receiverSignature: Value(receiverSignature),
      ),
    );

    final currentBalance = await _balancesDao.getByPublicKeyAndCurrency(
      existing.fromUserPublicKey,
      existing.currency,
    );
    final currentNet = currentBalance?.netAmount ?? 0;
    final newNet = currentNet - existing.amount;

    await _balancesDao.upsert(
      BalancesTableCompanion(
        userPublicKey: Value(existing.fromUserPublicKey),
        currency: Value(existing.currency),
        netAmount: Value(newNet),
        signed: Value(signedBalancePayload),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> rejectTransaction(String transactionId) async {
    // rejected transactions are simply discarded  so no db operations needed

    return;
  }
}
