import 'package:flutter/foundation.dart';

import '../data/database.dart';

class EditVisitViewModel extends ChangeNotifier {
  EditVisitViewModel({
    required AppDatabase database,
    required int visitId,
  })  : _visitId = visitId,
        _database = database {
    _load();
  }

  final AppDatabase _database;
  final int _visitId;

  int _towerId = 0;
  String _place = "";
  String _dedication = "";
  int _bells = 0;
  DateTime? _date;
  String _notes = "";
  bool _quarter = false;
  bool _peal = false;

  int get towerId => _towerId;
  String get place => _place;
  String get dedication => _dedication;
  int get bells => _bells;
  DateTime? get date => _date;
  String get notes => _notes;
  bool get quarter => _quarter;
  bool get peal => _peal;

  _load() async {
    var visit = await _database.getVisit(_visitId);
    var tower = await _database.getTower(visit.towerId);

    _towerId = tower.towerId;
    _place = tower.place;
    _dedication = tower.dedication;
    _bells = tower.bells;
    _date = visit.date;
    _notes = visit.notes ?? "";
    _quarter = visit.quarter;
    _peal = visit.peal;

    notifyListeners();
  }

  Future<int> update(
      {required DateTime date,
      required String notes,
      required bool peal,
      required bool quarter}) async {
    return await _database.updateVisit(
        visitId: _visitId,
        date: date,
        notes: notes,
        peal: peal,
        quarter: quarter);
  }

  Future<int> delete() async {
    return await _database.deleteVisit(_visitId);
  }
}
