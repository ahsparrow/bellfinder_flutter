import 'package:flutter/foundation.dart';

import 'database.dart';

class TowerViewModel extends ChangeNotifier {
  TowerViewModel({
    required AppDatabase database,
    required int towerId,
  })  : _towerId = towerId,
        _database = database {
    _load();
  }

  final AppDatabase _database;
  final int _towerId;

  Tower? _tower;

  Tower? get tower => _tower;

  _load() async {
    _tower = await _database.getTower(_towerId);
    notifyListeners();
  }
}
