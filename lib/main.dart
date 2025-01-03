import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'database.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();

  var x = await db.select(db.visits).get();
  print(x);

  final dir = await getApplicationDocumentsDirectory();
  print(dir);

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
