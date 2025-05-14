import 'dart:async';
import 'dart:collection';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database.dart';
import '../data/location.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required AppDatabase database,
  })  : _database = database,
        _sharedPrefs = SharedPreferencesAsync() {
    _load();
  }

  // Database
  final AppDatabase _database;

  // Shared preferences
  final SharedPreferencesAsync _sharedPrefs;

  // Towers and visits
  List<Tower> _towers = [];
  List<VisitTower> _visits = [];
  List<int> _visitTowerIds = [];

  // Position
  Position? _position;

  Stream<Position>? positionStream;
  StreamSubscription<Position>? positionStreamSubscription;

  // Unringable
  bool _includeUnringable = true;

  bool get includeUnringable => _includeUnringable;

  void setIncludeUnringable(bool value) async {
    _includeUnringable = value;

    await _sharedPrefs.setBool("includeUnringable", value);
    notifyListeners();
  }

  // Load database
  _load() async {
    _towers = await _database.getTowers();

    _includeUnringable =
        await _sharedPrefs.getBool("includeUnringable") ?? true;

    notifyListeners();

    // Stream visit updates
    await for (final visits in _database.getVisits()) {
      _visits = visits;
      _visitTowerIds = [for (var v in _visits) v.towerId];
      notifyListeners();
    }
  }

  List<Tower> get towers {
    return _towers.where((t) => _includeUnringable || !t.unringable).toList();
  }

  List<({double dist, Tower tower})> getNearest([int numTowers = 100]) {
    var pos = _position;

    if (pos == null) {
      return [];
    } else {
      var towerDistances = [
        for (final t in _towers)
          if (_includeUnringable || !t.unringable)
            (tower: t, dist: distanceFrom(t, pos))
      ];
      towerDistances.sort((a, b) => a.dist.compareTo(b.dist));

      return towerDistances.sublist(0, numTowers);
    }
  }

  UnmodifiableListView<VisitTower> get visits => UnmodifiableListView(_visits);

  Tower getTower(int towerId) {
    return _towers.firstWhere((tower) => tower.towerId == towerId);
  }

  int get numTowers => _towers.length;
  int get numVisits => _visits.length;

  bool hasVisit(int towerId) {
    return _visitTowerIds.contains(towerId);
  }

  // Import visits
  Future<int> loadCsvVists(String data) async {
    final csvVisits =
        CsvToListConverter(shouldParseNumbers: false).convert(data);

    if (csvVisits.isEmpty ||
        csvVisits[0].length != 7 ||
        csvVisits[0][0] != 'VisitId') {
      return 0;
    }

    List<Visit> visits = [];
    for (var visit in csvVisits.sublist(1)) {
      var v = Visit(
        visitId: int.parse(visit[0]),
        towerId: int.parse(visit[1]),
        date: DateFormat('yyyy-MM-dd').parse(visit[2]),
        notes: visit[3],
        peal: (visit[4] == "") ? false : true,
        quarter: (visit[5] == "") ? false : true,
      );
      visits.add(v);
    }

    await _database.insertVisits(visits);

    return csvVisits.length - 1;
  }

  // Export visits
  String encodeCsvVisits() {
    const header = [
      <Object?>[
        "VisitId",
        "TowerBase",
        "Date",
        "Notes",
        "Peal",
        "Quarter",
        "Place"
      ]
    ];

    final formatter = DateFormat("yyyy-MM-dd");

    final rows = _visits.map((v) => [
          v.visitId,
          v.towerId,
          formatter.format(v.date),
          v.notes,
          v.peal ? "Y" : "",
          v.quarter ? "Y" : "",
          v.place
        ]);
    final out =
        const ListToCsvConverter().convert(header.followedBy(rows).toList());

    return out;
  }

  // Start/stop location updates
  void startLocationUpdates() async {
    positionStream = await getPositionStream();

    positionStreamSubscription = positionStream?.listen((Position position) {
      _position = position;

      notifyListeners();
    });
  }

  void stopLocationUpdates() async {
    await positionStreamSubscription?.cancel();

    _position = null;
  }

  // Conversion utilities
  double distanceFrom(Tower t, Position p) {
    return Geolocator.distanceBetween(
        p.latitude, p.longitude, t.latitude, t.longitude);
  }

  static weightCwt(int weight) => weight / 112;
}
