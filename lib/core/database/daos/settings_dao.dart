import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/app_settings_table.dart';

part 'settings_dao.g.dart';

/// The single `app_settings` row. No insert (it is seeded in `onCreate`) and
/// no delete (contracts/settings-and-state.md).
@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.attachedDatabase);

  Future<AppSettingsRow> getSingleton() => select(appSettings).getSingle();

  Stream<AppSettingsRow> watchSingleton() => select(appSettings).watchSingle();

  /// Writes [changes] to the singleton row. Throws [StateError] unless exactly
  /// one row was updated.
  Future<void> updateSingleton(AppSettingsCompanion changes) async {
    final count = await update(appSettings).write(changes);
    if (count != 1) {
      throw StateError('app_settings update affected $count rows, expected 1');
    }
  }
}
