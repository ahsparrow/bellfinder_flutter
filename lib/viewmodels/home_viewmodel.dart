import 'dart:collection';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';

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

  _load() async {
    _towers = await _database.getTowers();
    _visits = await _database.getVisits();
    _visitTowerIds = [for (var v in _visits) v.towerId];
    notifyListeners();
  }

  UnmodifiableListView<Tower> get towers => UnmodifiableListView(_towers);
  UnmodifiableListView<VisitTower> get visits => UnmodifiableListView(_visits);

  Tower getTower(int towerId) {
    return _towers.firstWhere((tower) => tower.towerId == towerId);
  }

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

    _visits = await _database.getVisits();
    _visitTowerIds = [for (var v in _visits) v.towerId];
    notifyListeners();

    return csvVisits.length - 1;
  }

  static weightCwt(int weight) => weight / 112;
}
