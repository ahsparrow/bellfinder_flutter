import 'dart:convert' show utf8;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../screens/tower_screen.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/tower_viewmodel.dart';
import '../widgets/map.dart';
import '../widgets/nearest_list.dart';
import '../widgets/visits_list.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;
  final MapController mapController = MapController();

  void _showTowerOnMap(BuildContext context, Tower tower) {
    DefaultTabController.of(context).animateTo(0);
    mapController.move(LatLng(tower.latitude, tower.longitude), 13);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Builder(builder: (BuildContext tabContext) {
        return Scaffold(
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

                    // Trailing actions
                    trailing: [
                      // Clear and unfocus search bar
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          controller.clear();
                          FocusScope.of(context).unfocus();
                        },
                      ),

                      // Application menu
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
                              onTap: () async {
                                _exportCsv(context);
                              },
                              child: const Text('Export visits'),
                            ),

                            // About menu item
                            PopupMenuItem<int>(
                              onTap: () => _showAboutDialog(context),
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

                    // Firstly matching start of place name...
                    .where((t) => t.place
                        .toLowerCase()
                        .startsWith(controller.text.toLowerCase()))

                    // ...and then by rest of place name
                    .followedBy(viewModel.towers.where((t) => t.place
                        .toLowerCase()
                        .contains(controller.text.toLowerCase(), 1)))
                    .take(15)
                    .map(
                      (t) => ListTile(
                          title: Text("${t.place}, ${t.dedication}"),
                          onTap: () async {
                            // Close suggestions view
                            controller.closeView("");

                            // Navigate to tower screen
                            final result = await Navigator.push(
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

                            if (result == "map" && tabContext.mounted) {
                              _showTowerOnMap(tabContext, t);
                            }
                          },
                          onLongPress: () {
                            controller.closeView("");
                            _showTowerOnMap(tabContext, t);
                          }),
                    );
              },
            ),
          ),

          // Body with tabbed widgets
          body: Padding(
            padding: EdgeInsets.only(top: 8),
            child: TabBarView(
              children: [
                MapWidget(viewModel: viewModel, controller: mapController),
                NearestListWidget(
                    viewModel: viewModel, showTowerOnMap: _showTowerOnMap),
                VisitsListWidget(
                    viewModel: viewModel, showTowerOnMap: _showTowerOnMap),
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
                Tab(text: 'Map', icon: const Icon(Icons.map)),
                Tab(text: 'Near Me', icon: const Icon(Icons.near_me)),
                Tab(text: 'Visits', icon: const Icon(Icons.beenhere)),
              ],
              dividerColor: Colors.transparent,
            ),
          ),
        );
      }),
    );
  }

  Future<void> _showAboutDialog(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();
    if (context.mounted) {
      showAboutDialog(
        context: context,
        applicationName: "Bell Finder",
        applicationVersion: info.version,
        applicationLegalese:
            "Bell Finder is copyright Alan Sparrow and licensed under GPLv3.\n\n"
            "Dove data is copyright Central Council of Church Bell Ringers "
            "and licensed under the Creative Commons Attribution-ShareAlike "
            "4.0 international license\n\n"
            "Map data is copyright OpenStreetMap contributors and licensed "
            "under the Open Data Commons Open Database License",
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Column(
              spacing: 2,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dove Data',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Release date: ${const String.fromEnvironment(
                  "DOVE_DATE",
                  defaultValue: "Unknown",
                )}'),
                Text('Total towers: ${viewModel.towers.length}'),
                Text('Visited: ${viewModel.visits.length}'),
              ],
            ),
          ),
        ],
      );
    }
  }

  _importCsv(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: "Choose a file",
      allowedExtensions: ["csv"],
      withReadStream: true,
    );

    if (result == null || result.count == 0) {
      return;
    }

    final data = await result.xFiles[0].readAsString();
    final numVisits = await viewModel.loadCsvVists(data);

    if (numVisits == 0 && context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Cannot load visit data from ${result.names[0]}'),
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

  void _exportCsv(BuildContext context) async {
    final data = utf8.encode(viewModel.encodeCsvVisits());
    await FilePicker.platform.saveFile(
      dialogTitle: 'Choose a file',
      fileName: 'visits.csv',
      bytes: data,
    );
  }
}
