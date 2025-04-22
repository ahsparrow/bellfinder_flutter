import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../viewmodels/home_viewmodel.dart';
import '../widgets/map.dart';
import '../widgets/visits_list.dart';
import '../widgets/nearest_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0),
        body: Column(
          children: [
            SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return Padding(
                  padding: EdgeInsets.only(top: 8, left: 8, right: 8),
                  child: SearchBar(
                    hintText: "Search towers",
                    leading: Icon(Icons.search),
                    elevation: WidgetStatePropertyAll(0),
                  ),
                );
              },
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                return [Text("foobar")];
              },
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: TabBarView(
                  children: [
                    VisitsListWidget(viewModel: viewModel),
                    NearestListWidget(viewModel: viewModel),
                    MapWidget(viewModel: viewModel),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 8,
          ),
          child: TabBar(
            tabs: [
              Tab(text: 'Visits', icon: const Icon(Icons.beenhere)),
              Tab(text: 'Near Me', icon: const Icon(Icons.near_me)),
              Tab(text: 'Map', icon: const Icon(Icons.map)),
            ],
            dividerColor: Colors.transparent,
          ),
        ),
        /*
        appBar: AppBar(
          title: const Text('BellFinder'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
        */
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
