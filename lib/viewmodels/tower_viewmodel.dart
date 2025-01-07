import 'package:flutter/foundation.dart';

import '../data/database.dart';

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
  String _weightString = "";

  Tower? get tower => _tower;
  String get weightString => _weightString;

  _load() async {
    var tower = await _database.getTower(_towerId);

    var weight = tower.weight;
    var weightLbs = weight % 28;
    weight = (weight - weightLbs) ~/ 28;
    var weightQr = weight % 4;
    var weightCwt = (weight - weightQr) ~/ 4;
    _weightString = '$weightCwt-$weightQr-$weightLbs';

    _tower = tower;
    notifyListeners();
  }
}
