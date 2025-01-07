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
  List<Visit> _visits = [];

  _load() async {
    _towers = await _database.getTowers();
    _visits = await _database.getVisits();
    notifyListeners();
  }

  UnmodifiableListView<Tower> get towers => UnmodifiableListView(_towers);
  UnmodifiableListView<Visit> get visits => UnmodifiableListView(_visits);

  Tower getTower(int towerId) {
    return _towers.firstWhere((tower) => tower.towerId == towerId);
  }

  void insertVisit() async {
    await _database.into(_database.visits).insert(VisitsCompanion.insert(
          towerId: 123,
          date: DateTime.now(),
          quarter: false,
          peal: false,
        ));

    _visits = await _database.getVisits();
    notifyListeners();
  }

  static weightCwt(int weight) => weight / 112;
}
