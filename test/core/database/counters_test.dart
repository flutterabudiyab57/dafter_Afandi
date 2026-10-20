import 'package:daftar_afandi/core/database/app_database.dart';
import 'package:daftar_afandi/core/database/transaction_runner.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_database.dart';

/// The allocation statement documented in data-model.md (counters).
Future<int> _next(AppDatabase db, String docType) async {
  final rows = await db.customWriteReturning(
    'UPDATE counters SET next_value = next_value + 1, updated_at = ? '
    'WHERE doc_type = ? RETURNING next_value - 1 AS allocated',
    variables: [const Variable<int>(2000), Variable<String>(docType)],
    updates: {db.counters},
  );
  return rows.single.read<int>('allocated');
}

void main() {
  late TempDatabase t;
  late TransactionRunner tx;

  setUp(() async {
    t = await TempDatabase.open();
    tx = DriftTransactionRunner(t.db);
  });
  tearDown(() => t.dispose());

  test('returns 1, 2, 3 inside one transaction', () async {
    final numbers = await tx.run(
      () async => [
        await _next(t.db, 'SALE'),
        await _next(t.db, 'SALE'),
        await _next(t.db, 'SALE'),
      ],
    );
    expect(numbers, [1, 2, 3]);
    expect(
      await t.db.scalar(
        "SELECT next_value FROM counters WHERE doc_type = 'SALE'",
      ),
      4,
    );
  });

  test('each doc type counts on its own', () async {
    expect(await _next(t.db, 'SALE'), 1);
    expect(await _next(t.db, 'EXPENSE'), 1);
    expect(await _next(t.db, 'SALE'), 2);
  });

  test('a rolled-back transaction does not consume a number', () async {
    expect(await tx.run(() => _next(t.db, 'PURCHASE')), 1);
    await expectLater(
      tx.run(() async {
        expect(await _next(t.db, 'PURCHASE'), 2);
        throw StateError('document save failed');
      }),
      throwsStateError,
    );
    expect(await tx.run(() => _next(t.db, 'PURCHASE')), 2);
  });

  test('next_value can never drop below 1', () async {
    await expectLater(
      t.db.exec("UPDATE counters SET next_value = 0 WHERE doc_type = 'SALE'"),
      throwsA(anything),
    );
  });
}
