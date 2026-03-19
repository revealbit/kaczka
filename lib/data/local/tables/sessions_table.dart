import 'package:drift/drift.dart';

class SessionsTable extends Table {
  @override
  String get tableName => 'sessions';

  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get activityType => text().named('activity_type')();
  DateTimeColumn get startedAt => dateTime().named('started_at')();
  DateTimeColumn get endedAt => dateTime().named('ended_at').nullable()();
  RealColumn get distanceKm => real().named('distance_km').withDefault(const Constant(0.0))();
  IntColumn get pointsEarned => integer().named('points_earned').withDefault(const Constant(0))();
  BoolColumn get isValidated => boolean().named('is_validated').withDefault(const Constant(false))();
  IntColumn get cheatFlagsCount =>
      integer().named('cheat_flags_count').withDefault(const Constant(0))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
