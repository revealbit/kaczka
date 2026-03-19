import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/gps_dao.dart';
import 'daos/sessions_dao.dart';
import 'tables/gps_points_table.dart';
import 'tables/sessions_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [GpsPointsTable, SessionsTable],
  daos: [GpsDao, SessionsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbDir.path, 'kaczka.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
