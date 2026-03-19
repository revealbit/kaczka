import 'package:drift/drift.dart';

class GpsPointsTable extends Table {
  @override
  String get tableName => 'gps_points';

  TextColumn get id => text()();
  TextColumn get sessionId => text().named('session_id')();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get accuracyMeters => real().named('accuracy_meters')();
  RealColumn get speedMps => real().named('speed_mps')();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
