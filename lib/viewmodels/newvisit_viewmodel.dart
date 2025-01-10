import 'package:flutter/foundation.dart';

import '../data/database.dart';

class NewVisitViewModel extends ChangeNotifier {
  NewVisitViewModel({
    required AppDatabase database,
    required int towerId,
  })  : _towerId = towerId,
        _database = database {
    _load();
  }

  final AppDatabase _database;
  final int _towerId;

  String _place = "";
  String _dedication = "";

  String get place => _place;
  String get dedication => _dedication;

  _load() async {
    var tower = await _database.getTower(_towerId);

    _place = tower.place;
    _dedication = tower.dedication;

    notifyListeners();
  }

  Future<int> insert({
    required DateTime date,
    required String notes,
    required bool quarter,
    required bool peal,
  }) async {
    return await _database.insertVisit(
        towerId: _towerId,
        date: date,
        notes: notes,
        quarter: quarter,
        peal: peal);
  }
}
