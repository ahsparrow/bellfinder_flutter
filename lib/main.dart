import 'dart:convert' show jsonDecode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  await checkUpdateTowers(db);

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) {
          return db;
        }),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}

Future<void> checkUpdateTowers(AppDatabase db) async {
  final prefs = await SharedPreferences.getInstance();
  final packageInfo = await PackageInfo.fromPlatform();

  if (packageInfo.buildNumber != prefs.getString('build_number')) {
    print("updating...");
    await prefs.setString('build_number', packageInfo.buildNumber);

    final dove = await rootBundle.loadString('assets/dove.json');
    final towers = jsonDecode(dove) as List<dynamic>;

    await db.deleteAllTowers();
    await db.insertTowers(towers);
  }
}
