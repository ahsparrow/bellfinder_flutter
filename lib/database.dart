import 'dart:io' show Platform;
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Towers extends Table {
  IntColumn get towerId => integer().named('towerId')();
  TextColumn get place => text()();
  TextColumn get county => text()();
  TextColumn get dedication => text()();
  IntColumn get bells => integer()();
  IntColumn get weight => integer()();
  BoolColumn get unringable => boolean()();
  TextColumn get practice => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();

  @override
  Set<Column> get primaryKey => {towerId};
}

class Visits extends Table {
  IntColumn get visitId => integer().autoIncrement().named('visitId')();
  IntColumn get towerId => integer().named('towerId')();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
  BoolColumn get peal => boolean()();
  BoolColumn get quarter => boolean()();
}

@DriftDatabase(tables: [Towers, Visits])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    DriftNativeOptions? nativeOpts;
    if (Platform.isAndroid) {
      nativeOpts = DriftNativeOptions(databasePath: () async {
        var dir = await getApplicationSupportDirectory();
        return path.join(dir.path, '../databases', 'tower_database');
      });
    }

    return driftDatabase(name: 'tower_database', native: nativeOpts);
  }

  Future<List<Tower>> get allTowers => managers.towers.get();
  Future<List<Visit>> get allVisits => managers.visits.get();
}
