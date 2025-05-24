import 'dart:convert' show jsonDecode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/database.dart';
import 'screens/home_screen.dart';
import 'viewmodels/home_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Application preferences
  final sharedPrefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );

  // Tower database
  final db = AppDatabase();
  await updateTowers(db, sharedPrefs);

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => db),
        Provider(create: (context) => sharedPrefs)
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(
        viewModel: HomeViewModel(
          database: context.read<AppDatabase>(),
          sharedPrefs: context.read<SharedPreferencesWithCache>(),
        ),
      ),
      title: "Bellfinder",
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<void> updateTowers(
    AppDatabase db, SharedPreferencesWithCache prefs) async {
  final packageInfo = await PackageInfo.fromPlatform();

  if (packageInfo.buildNumber != prefs.getString('build_number')) {
    await prefs.setString('build_number', packageInfo.buildNumber);

    final dove = await rootBundle.loadString('assets/dove.json');
    final towers = jsonDecode(dove) as List<dynamic>;

    await db.deleteAllTowers();
    await db.insertTowers(towers);
  }
}
