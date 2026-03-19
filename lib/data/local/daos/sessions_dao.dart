import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/sessions_table.dart';

part 'sessions_dao.g.dart';

@DriftAccessor(tables: [SessionsTable])
class SessionsDao extends DatabaseAccessor<AppDatabase> with _$SessionsDaoMixin {
  SessionsDao(super.db);

  Future<void> insertSession(SessionsTableCompanion session) =>
      into(sessionsTable).insert(session);

  Future<SessionsTableData?> getSession(String id) =>
      (select(sessionsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> updateSession(SessionsTableCompanion session) =>
      (update(sessionsTable)..where((t) => t.id.equals(session.id.value))).write(session);

  Future<List<SessionsTableData>> getUnsyncedSessions() =>
      (select(sessionsTable)..where((t) => t.synced.equals(false))).get();

  Future<void> markSynced(String id) =>
      (update(sessionsTable)..where((t) => t.id.equals(id))).write(
        const SessionsTableCompanion(synced: Value(true)),
      );

  Future<List<SessionsTableData>> getCompletedSessions() =>
      (select(sessionsTable)
            ..where((t) => t.endedAt.isNotNull())
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
          .get();
}
