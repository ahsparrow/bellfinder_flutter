import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database.dart';
import 'router.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) {
          if (Platform.isLinux) {
            sqfliteFfiInit();
            databaseFactory = databaseFactoryFfi;
          }
          return AppDatabase();
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
