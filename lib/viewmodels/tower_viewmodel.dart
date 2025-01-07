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
    _tower = await _database.getTower(_towerId);

    final weight = _tower!.weight;
    final cwt = weight ~/ 112;
    final qr = (weight - cwt * 112) ~/ 28;
    final lbs = weight % 28;
    _weightString = '$cwt-$qr-$lbs';

    notifyListeners();
  }
}
