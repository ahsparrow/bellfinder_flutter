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
    required SharedPreferencesWithCache sharedPrefs,
  })  : _database = database,
        _sharedPrefs = sharedPrefs {
    _load();
  }

  // Database
  final AppDatabase _database;

  // Shared preferences
  final SharedPreferencesWithCache _sharedPrefs;

  // Towers and visits
  List<Tower> _towers = [];
  List<VisitTower> _visits = [];
  List<int> _visitTowerIds = [];

  // Position
  Position? _position;

  Stream<Position>? positionStream;
  StreamSubscription<Position>? positionStreamSubscription;

  // Map state
  Future<void> saveMapCenter(
      double latitude, double longitude, double zoom) async {
    await _sharedPrefs.setDouble("latitude", latitude);
    await _sharedPrefs.setDouble("longitude", longitude);
    await _sharedPrefs.setDouble("zoom", zoom);
  }

  ({double latitude, double longitude, double zoom}) getMapCenter() {
    final latitude = _sharedPrefs.getDouble("latitude") ?? 54.0;
    final longitude = _sharedPrefs.getDouble("longitude") ?? -2.5;
    final zoom = _sharedPrefs.getDouble("zoom") ?? 6.0;

    return (latitude: latitude, longitude: longitude, zoom: zoom);
  }

  bool get includeUnringable =>
      _sharedPrefs.getBool("includeUnringable") ?? true;

  Future<void> setIncludeUnringable(bool value) async {
    await _sharedPrefs.setBool("includeUnringable", value);
    notifyListeners();
  }

  // Load database
  _load() async {
    _towers = await _database.getTowers();
    notifyListeners();

    // Stream visit updates
    await for (final visits in _database.getVisits()) {
      _visits = visits;
      _visitTowerIds = [for (var v in _visits) v.towerId];
      notifyListeners();
    }
  }

  List<Tower> get towers {
    return _towers.where((t) => includeUnringable || !t.unringable).toList();
  }

  List<({double dist, Tower tower})> getNearest([int numTowers = 100]) {
    var pos = _position;

    if (pos == null) {
      return [];
    } else {
      var towerDistances = [
        for (final t in _towers)
          if (includeUnringable || !t.unringable)
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
    _position = await getLastKnownPosition();
    if (_position != null) {
      notifyListeners();
    }

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

  static double weightCwt(int weight) => weight / 112;
}
