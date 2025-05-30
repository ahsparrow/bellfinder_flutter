import 'dart:io' show Platform;
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class DateConverter extends TypeConverter<DateTime, int> {
  @override
  fromSql(int date) {
    final day = date % 100;
    final month = (date ~/ 100) % 100 + 1;
    final year = date ~/ 10000;
    return DateTime.utc(year, month, day);
  }

  @override
  toSql(DateTime date) {
    return date.year * 10000 + (date.month - 1) * 100 + date.day;
  }
}

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
  IntColumn get date => integer().map(DateConverter())();
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
    required this.notes,
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
  String? notes;
}

@DriftDatabase(tables: [Towers, Visits])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

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
  Future<List<Tower>> getTowers() =>
      managers.towers.orderBy((o) => o.place.asc() & o.dedication.asc()).get();

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

  // Get visits to specified tower
  Stream<List<Visit>> getTowerVisits(int towerId) {
    return managers.visits.filter((v) => v.towerId.equals(towerId)).watch();
  }

  // Get visits merged with tower info
  Stream<List<VisitTower>> getVisits() {
    final query = select(visits)
        .join([innerJoin(towers, towers.towerId.equalsExp(visits.towerId))]);
    query.orderBy([OrderingTerm.desc(visits.date)]);

    return query.map((row) {
      final visit = row.readTable(visits);
      final tower = row.readTable(towers);

      return VisitTower(
        visitId: visit.visitId,
        date: visit.date,
        peal: visit.peal,
        quarter: visit.quarter,
        towerId: visit.towerId,
        notes: visit.notes,
        place: tower.place,
        dedication: tower.dedication,
        county: tower.county,
        bells: tower.bells,
      );
    }).watch();
  }
}
