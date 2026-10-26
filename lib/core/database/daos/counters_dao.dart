import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/counters_table.dart';
import '../tables/enums.dart';

part 'counters_dao.g.dart';

/// Gap-free document numbers (003 research R4).
@DriftAccessor(tables: [Counters])
class CountersDao extends DatabaseAccessor<AppDatabase>
    with _$CountersDaoMixin {
  CountersDao(super.attachedDatabase);

  /// The next number for [type]. Call it inside the document's transaction:
  /// a rollback also undoes the increment, so no number is burned.
  Future<int> take(DocType type, DateTime now) async {
    final rows = await customWriteReturning(
      'UPDATE counters SET next_value = next_value + 1, updated_at = ?1 '
      'WHERE doc_type = ?2 RETURNING next_value - 1 AS n',
      variables: [
        Variable<int>(now.millisecondsSinceEpoch),
        Variable<String>(type.name),
      ],
      updates: {counters},
      updateKind: UpdateKind.update,
    );
    if (rows.length != 1) throw StateError('no counter for ${type.name}');
    return rows.single.read<int>('n');
  }
}
