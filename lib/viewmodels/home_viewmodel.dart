import 'dart:collection';
import 'package:flutter/foundation.dart';

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

  _load() async {
    _towers = await _database.getTowers();
    _visits = await _database.getVisits();
    notifyListeners();
  }

  UnmodifiableListView<Tower> get towers => UnmodifiableListView(_towers);
  UnmodifiableListView<VisitTower> get visits => UnmodifiableListView(_visits);

  Tower getTower(int towerId) {
    return _towers.firstWhere((tower) => tower.towerId == towerId);
  }

  static weightCwt(int weight) => weight / 112;
}
