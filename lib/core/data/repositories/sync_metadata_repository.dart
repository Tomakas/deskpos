import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';

class SyncMetadataRepository {
  SyncMetadataRepository(this._db);
  final AppDatabase _db;

  static const _uuid = Uuid();

  Future<String?> getLastPulledAt(String companyId, String tableName) async {
    final entry = await (_db.select(_db.syncMetadata)
          ..where((t) =>
              t.companyId.equals(companyId) & t.entityTableName.equals(tableName)))
        .getSingleOrNull();
    return entry?.lastPulledAt;
  }

  Future<void> setLastPulledAt(
    String companyId,
    String tableName,
    String pulledAt,
  ) async {
    await _db.transaction(() async {
      final existing = await (_db.select(_db.syncMetadata)
            ..where((t) =>
                t.companyId.equals(companyId) & t.entityTableName.equals(tableName)))
          .getSingleOrNull();

      if (existing != null) {
        await (_db.update(_db.syncMetadata)
              ..where((t) => t.id.equals(existing.id)))
            .write(SyncMetadataCompanion(
          lastPulledAt: Value(pulledAt),
          updatedAt: Value(DateTime.now()),
        ));
      } else {
        await _db.into(_db.syncMetadata).insert(SyncMetadataCompanion.insert(
          id: _uuid.v7(),
          companyId: companyId,
          entityTableName: tableName,
          lastPulledAt: Value(pulledAt),
        ));
      }
    });
  }
}
