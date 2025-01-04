import 'dart:collection';
import 'package:flutter/foundation.dart';

import 'database.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required AppDatabase database,
  }) : _database = database {
    _load();
  }

  final AppDatabase _database;

  List<Tower> _towers = [];
  UnmodifiableListView<Tower> get towers => UnmodifiableListView(_towers);

  List<Visit> _visits = [];
  UnmodifiableListView<Visit> get visits => UnmodifiableListView(_visits);

  _load() async {
    _towers = await _database.getTowers();
    _visits = await _database.getVisits();
    notifyListeners();
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
}
