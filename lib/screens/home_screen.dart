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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final MapController _mapController = MapController();

  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onHide: () async {
        final camera = _mapController.camera;
        await widget.viewModel.saveMapCenter(
            camera.center.latitude, camera.center.longitude, camera.zoom);
      },
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
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
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: SearchBar(
                    controller: controller,
                    elevation: WidgetStatePropertyAll(0),
                    hintText: "Search towers",
                    keyboardType: TextInputType.none,
                    leading: const Icon(Icons.search),
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
                    ],
                  ),
                );
              },

              // Search suggestions
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                return widget.viewModel.towers

                    // Firstly matching start of place name...
                    .where((t) => t.place
                        .toLowerCase()
                        .startsWith(controller.text.toLowerCase()))

                    // ...and then by rest of place name
                    .followedBy(widget.viewModel.towers.where((t) => t.place
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
            padding: const EdgeInsets.only(top: 8),
            child: TabBarView(
              children: [
                MapWidget(
                    viewModel: widget.viewModel, controller: _mapController),
                NearestListWidget(
                    viewModel: widget.viewModel,
                    showTowerOnMap: _showTowerOnMap),
                VisitsListWidget(
                    viewModel: widget.viewModel,
                    showTowerOnMap: _showTowerOnMap),
              ],
            ),
          ),

          // Bottom navigation with tab controller
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            child: const TabBar(
              tabs: [
                Tab(text: 'Map', icon: Icon(Icons.map)),
                Tab(text: 'Near Me', icon: Icon(Icons.near_me)),
                Tab(text: 'Visits', icon: Icon(Icons.beenhere)),
              ],
              dividerColor: Colors.transparent,
            ),
          ),

          drawer: Drawer(
            child: SafeArea(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const ListTile(
                    title: Text("Settings"),
                  ),
                  const Divider(),
                  ListenableBuilder(
                    listenable: widget.viewModel,
                    builder: (context, child) => CheckboxListTile(
                      title: Text("Show unringable"),
                      secondary: Icon(Icons.notifications_off),
                      value: widget.viewModel.includeUnringable,
                      onChanged: (val) =>
                          widget.viewModel.setIncludeUnringable(val!),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("Import Visits"),
                    leading: const Icon(Icons.file_open),
                    onTap: () async {
                      _importCsv(context);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text("Export Visits"),
                    leading: const Icon(Icons.save),
                    onTap: () async {
                      _exportCsv(context);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text("About"),
                    leading: const Icon(Icons.info_outline),
                    onTap: () {
                      _showAboutDialog(context);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showTowerOnMap(BuildContext context, Tower tower) async {
    _mapController.move(LatLng(tower.latitude, tower.longitude), 13);
    DefaultTabController.of(context).animateTo(0);
  }

  Future<void> _showAboutDialog(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();
    if (context.mounted) {
      showAboutDialog(
        context: context,
        applicationName: "Bell Finder",
        applicationVersion: info.version,
        applicationIcon: Image.asset(
          'assets/icon/bell.png',
          width: 64,
        ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dove Data',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Release date: ${const String.fromEnvironment(
                  "DOVE_DATE",
                  defaultValue: "Unknown",
                )}'),
                Text('Total towers: ${widget.viewModel.numTowers}'),
                Text('Visited: ${widget.viewModel.numVisits}'),
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
      withReadStream: true,
    );

    if (result == null || result.count == 0) {
      return;
    }

    final data = await result.xFiles[0].readAsString();
    final numVisits = await widget.viewModel.loadCsvVists(data);

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
    final data = utf8.encode(widget.viewModel.encodeCsvVisits());
    await FilePicker.platform.saveFile(
      dialogTitle: 'Choose a file',
      fileName: 'visits.csv',
      bytes: data,
    );
  }
}
