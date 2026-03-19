import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/gps_points_table.dart';

part 'gps_dao.g.dart';

@DriftAccessor(tables: [GpsPointsTable])
class GpsDao extends DatabaseAccessor<AppDatabase> with _$GpsDaoMixin {
  GpsDao(super.db);

  Future<void> insertPoint(GpsPointsTableCompanion point) =>
      into(gpsPointsTable).insert(point);

  Future<List<GpsPointsTableData>> getUnsyncedPoints(String sessionId) =>
      (select(gpsPointsTable)
            ..where((t) => t.sessionId.equals(sessionId) & t.synced.equals(false)))
          .get();

  Future<List<GpsPointsTableData>> getSessionPoints(String sessionId) =>
      (select(gpsPointsTable)..where((t) => t.sessionId.equals(sessionId))).get();

  Future<void> markSynced(List<String> ids) =>
      (update(gpsPointsTable)..where((t) => t.id.isIn(ids))).write(
        const GpsPointsTableCompanion(synced: Value(true)),
      );

  Future<void> deleteSessionPoints(String sessionId) =>
      (delete(gpsPointsTable)..where((t) => t.sessionId.equals(sessionId))).go();
}
