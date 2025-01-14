import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../viewmodels/home_viewmodel.dart';
import '../widgets/map.dart';
import '../widgets/towers_list.dart';
import '../widgets/visits_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BellFinder'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Towers'),
              Tab(text: 'Visits'),
              Tab(text: 'Nearby'),
              Tab(text: 'Map'),
            ],
          ),
          actions: [
            // Settings menu item
            PopupMenuButton(itemBuilder: (context) {
              return [
                // Import visits menu item
                PopupMenuItem<int>(
                  onTap: () async {
                    _importCsv(context);
                  },
                  child: const Text('Import visits'),
                ),

                // Import visits menu item
                PopupMenuItem<int>(
                  child: const Text('Export visits'),
                ),

                // About menu item
                const PopupMenuItem<int>(
                  child: Text('About'),
                ),
              ];
            }),
          ],
        ),
        body: TabBarView(
          children: [
            TowerListWidget(viewModel: viewModel),
            VisitsListWidget(viewModel: viewModel),
            Center(child: Text('Nearby')),
            MapWidget(viewModel: viewModel),
          ],
        ),
      ),
    );
  }

  _importCsv(BuildContext context) async {
    const typeGroup = XTypeGroup(label: 'CSV files', extensions: ['csv']);
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) {
      return;
    }

    final data = await file.readAsString();
    final numVisits = await viewModel.loadCsvVists(data);

    if (numVisits == 0 && context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Cannot load visit data from ${file.name}'),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }
}
