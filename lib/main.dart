import 'dart:convert' show jsonDecode;
import 'dart:io' show Platform;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart' show rootBundle;
//import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'data/database.dart';
import 'screens/home_screen.dart';
import 'viewmodels/home_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /*
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  */

  // Tower database
  final db = AppDatabase();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => db),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    var db = context.read<AppDatabase>();

    return FutureBuilder(
        future: updateTowers(db),
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) {
            return Material(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox.square(
                    dimension: 60,
                    child: CircularProgressIndicator(),
                  ),
                  SizedBox(height: 16),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      "Loading database",
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return MaterialApp(
              home: HomeScreen(
                viewModel: HomeViewModel(
                  database: db,
                  sharedPrefs: data,
                ),
              ),
              title: "Bellfinder",
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: ThemeMode.system,
              debugShowCheckedModeBanner: false,
            );
          }
        });
  }
}

// Update with new towers on first run (also migrate visits from old database)
Future<SharedPreferencesWithCache> updateTowers(AppDatabase db) async {
  // Application preferences
  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );

  final packageInfo = await PackageInfo.fromPlatform();

  final prevBuildNumber = prefs.getString('build_number');
  if (packageInfo.buildNumber != prevBuildNumber) {
    await prefs.setString('build_number', packageInfo.buildNumber);

    final dove = await rootBundle.loadString('assets/dove.json');
    final towers = jsonDecode(dove) as List<dynamic>;

    await db.deleteAllTowers();
    await db.insertTowers(towers);

    // prevBuildNumber will be null on initial install or first upgrade
    // to flutter version
    if (prevBuildNumber == null) {
      await migrateOldVisits(db);
    }
  }

  return prefs;
}

// Migrate visits from old database
Future<void> migrateOldVisits(AppDatabase db) async {
  if (Platform.isAndroid) {
    final dirPath = await getDatabasesPath();
    final dbPath = path.join(dirPath, 'tower_database');

    if (await databaseExists(dbPath)) {
      var oldDb = await openReadOnlyDatabase('tower_database');
      final oldVisits = await oldDb.rawQuery('select * from visits');

      final visits = oldVisits.map((v) => Visit(
            visitId: v['visitId'] as int,
            towerId: v['towerId'] as int,
            date: DateTime.parse(((v['date'] as int) + 100).toString()),
            notes: v['notes'] as String,
            peal: v['peal'] as int == 1,
            quarter: v['quarter'] as int == 1,
          ));

      await db.insertVisits(visits.toList());

      await oldDb.close();
      await deleteDatabase(dbPath);
    }
  }
}
