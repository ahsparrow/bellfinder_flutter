import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import 'package:bellfinder/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();

  await database.into(database.towers).insert(TowersCompanion.insert(
        towerId: Value(1),
        place: 'Lockerley',
        dedication: 'S Johns',
        county: 'UK',
        bells: 6,
        weight: 500,
        practice: 'Thur',
        unringable: false,
        latitude: 51,
        longitude: -1,
      ));
}
