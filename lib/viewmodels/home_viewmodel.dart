import 'dart:async';
import 'dart:collection';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../data/location.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required AppDatabase database,
  }) : _database = database {
    _load();
  }

  final AppDatabase _database;

  List<Tower> _towers = [];
  List<VisitTower> _visits = [];
  List<int> _visitTowerIds = [];
  List<Tower> _nearest = [];

  Stream<Position>? positionStream;
  StreamSubscription<Position>? positionStreamSubscription;

  bool _includeUnringable = true;

  bool get includeUnringable => _includeUnringable;
  set includeUnringable(bool value) {
    _includeUnringable = value;
    notifyListeners();
  }

  _load() async {
    _towers = await _database.getTowers();
    notifyListeners();

    await for (final visits in _database.getVisits()) {
      _visits = visits;
      _visitTowerIds = [for (var v in _visits) v.towerId];
      notifyListeners();
    }
  }

  List<Tower> get towers {
    return _towers.where((t) => _includeUnringable || !t.unringable).toList();
  }

  List<Tower> get nearest {
    return _nearest.where((t) => _includeUnringable || !t.unringable).toList();
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

  void startLocationUpdates() async {
    positionStream = await getPositionStream();

    positionStreamSubscription = positionStream?.listen((Position position) {
      var towerDistances = [
        for (final t in _towers) (tower: t, dist: distanceFrom(t, position))
      ];
      towerDistances.sort((a, b) => a.dist.compareTo(b.dist));
      _nearest = [for (final td in towerDistances.sublist(0, 100)) td.tower];

      notifyListeners();
    });
  }

  double distanceFrom(Tower t, Position p) {
    return Geolocator.distanceBetween(
        p.latitude, p.longitude, t.latitude, t.longitude);
  }

  void stopLocationUpdates() async {
    await positionStreamSubscription?.cancel();
    _nearest = [];
  }

  static weightCwt(int weight) => weight / 112;
}
