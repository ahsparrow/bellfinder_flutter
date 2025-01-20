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

class VisitTower {
  VisitTower({
    required this.visitId,
    required this.towerId,
    required this.place,
    required this.county,
    required this.dedication,
    required this.bells,
    required this.date,
    required this.peal,
    required this.quarter,
  });

  int visitId;
  int towerId;
  DateTime date;
  bool peal;
  bool quarter;
  String place;
  String county;
  String dedication;
  int bells;
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
        return path.join(dir.path, '..', 'databases', 'tower_database');
      });
    }

    return driftDatabase(name: 'tower_database', native: nativeOpts);
  }

  // Get all the towers
  Future<List<Tower>> getTowers() => managers.towers.get();

  // Get a single tower
  Future<Tower> getTower(int towerId) =>
      managers.towers.filter((f) => f.towerId(towerId)).getSingle();

  // Delete all towers
  Future<int> deleteAllTowers() => managers.towers.delete();

  // Add a list of towers
  Future<void> insertTowers(towers) {
    return transaction(() async {
      for (final tower in towers) {
        await managers.towers.create((o) => o(
              towerId: Value(tower['towerId']),
              place: tower['place'],
              county: tower['county'],
              dedication: tower['dedication'],
              bells: tower['bells'],
              weight: tower['weight'],
              unringable: tower['unringable'],
              practice: tower['practice'],
              latitude: tower['latitude'],
              longitude: tower['longitude'],
            ));
      }
    });
  }

  // Add a visit
  Future<int> insertVisit(
      {required int towerId,
      required DateTime date,
      required String notes,
      required bool quarter,
      required bool peal}) async {
    return await managers.visits.create((o) => o(
          towerId: towerId,
          date: date,
          notes: Value(notes),
          quarter: quarter,
          peal: peal,
        ));
  }

  // Update a visit
  Future<int> updateVisit(
      {required int visitId,
      required DateTime date,
      required String notes,
      required bool quarter,
      required bool peal}) async {
    return await managers.visits
        .filter((v) => v.visitId.equals(visitId))
        .update(
          (v) => v(
            date: Value(date),
            notes: Value(notes),
            peal: Value(peal),
            quarter: Value(quarter),
          ),
        );
  }

  Future<void> insertVisits(List<Visit> newVisits) async {
    await batch((batch) {
      batch.insertAll(visits, newVisits, mode: InsertMode.replace);
    });
  }

  // Delete a visit
  deleteVisit(int visitId) async {
    return managers.visits.filter((v) => v.visitId.equals(visitId)).delete();
  }

  // Get a visit
  Future<Visit> getVisit(int visitId) {
    return (select(visits)..where((v) => v.visitId.equals(visitId)))
        .getSingle();
  }

  // Get visits merged with tower info
  Stream<List<VisitTower>> getVisits() {
    final query = select(visits)
        .join([innerJoin(towers, towers.towerId.equalsExp(visits.towerId))]);

    return query.map((row) {
      final visit = row.readTable(visits);
      final tower = row.readTable(towers);

      return VisitTower(
        visitId: visit.visitId,
        date: visit.date,
        peal: visit.peal,
        quarter: visit.quarter,
        towerId: visit.towerId,
        place: tower.place,
        dedication: tower.dedication,
        county: tower.county,
        bells: tower.bells,
      );
    }).watch();
  }
}
