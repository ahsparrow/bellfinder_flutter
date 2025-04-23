import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../screens/tower_screen.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/tower_viewmodel.dart';
import '../widgets/map.dart';
import '../widgets/nearest_list.dart';
import '../widgets/visits_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        // AppBar contains the tower search bar
        appBar: AppBar(
          centerTitle: true,
          clipBehavior: Clip.none,
          titleSpacing: 0,
          title: SearchAnchor(
            builder: (BuildContext context, SearchController controller) {
              return Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: SearchBar(
                  controller: controller,
                  elevation: WidgetStatePropertyAll(0),
                  hintText: "Search towers",
                  keyboardType: TextInputType.none,
                  leading: Icon(Icons.search),
                  onChanged: (_) => controller.openView(),
                  onTap: () => controller.openView(),
                  // Settings menu
                  trailing: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        controller.clear();
                        FocusScope.of(context).unfocus();
                      },
                    ),
                    PopupMenuButton(
                      icon: Icon(Icons.menu),
                      itemBuilder: (context) {
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
                      },
                    ),
                  ],
                ),
              );
            },

            // Search suggestions
            suggestionsBuilder:
                (BuildContext context, SearchController controller) {
              return viewModel.towers
                  .where((t) => t.place
                      .toLowerCase()
                      .startsWith(controller.text.toLowerCase()))
                  .followedBy(viewModel.towers.where((t) => t.place
                      .toLowerCase()
                      .contains(controller.text.toLowerCase(), 1)))
                  .take(15)
                  .map(
                    (t) => ListTile(
                      title: Text("${t.place}, ${t.dedication}"),
                      onTap: () {
                        controller.closeView("");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TowerScreen(
                              viewModel: TowerViewModel(
                                database: context.read<AppDatabase>(),
                                towerId: t.towerId,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
            },
          ),
        ),

        // Body with tabbed widgets
        body: Padding(
          padding: EdgeInsets.only(top: 8),
          child: TabBarView(
            children: [
              VisitsListWidget(viewModel: viewModel),
              NearestListWidget(viewModel: viewModel),
              MapWidget(viewModel: viewModel),
            ],
          ),
        ),

        // Bottom navigation with tab controller
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
