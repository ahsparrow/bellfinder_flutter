import 'dart:convert' show utf8;

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static final MapController _mapController = MapController();

  SystemUiOverlayStyle _overlayStyle = SystemUiOverlayStyle.dark;
  late final TabController _tabController;

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

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      var sysBrightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;

      var brightness = _tabController.index == 0
          // Always uses dark icons for map tab
          ? Brightness.dark
          // Nearest and visit tabs follow system theme
          : sysBrightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark;

      setState(() {
        _overlayStyle =
            SystemUiOverlayStyle(statusBarIconBrightness: brightness);
      });
    });
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,

      // AppBar contains the tower search bar
      appBar: AppBar(
        automaticallyImplyActions: false,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        clipBehavior: Clip.none,
        systemOverlayStyle: _overlayStyle,
        title: buildSearchAnchor(context, context),
      ),

      // Body with tabbed widgets
      body: TabBarView(
        controller: _tabController,
        children: [
          MapWidget(viewModel: widget.viewModel, controller: _mapController),
          NearestListWidget(
              viewModel: widget.viewModel, showTowerOnMap: _showTowerOnMap),
          VisitsListWidget(
              viewModel: widget.viewModel, showTowerOnMap: _showTowerOnMap),
        ],
      ),

      // Bottom navigation with tab controller
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.near_me),
            label: 'Near Me',
          ),
          NavigationDestination(
            icon: Icon(Icons.beenhere),
            label: 'Visited',
          ),
        ],
        selectedIndex: _tabController.index,
        onDestinationSelected: (int index) {
          _tabController.animateTo(index);
        },
      ),

      endDrawer: buildDrawer(context),
    );
  }

  SearchAnchor buildSearchAnchor(
      BuildContext context, BuildContext buildContext) {
    return SearchAnchor(
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
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState!.openEndDrawer();
                },
              ),
            ],
          ),
        );
      },

      // Search suggestions
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        return widget.viewModel.towers

            // Firstly matching start of place name...
            .where((t) =>
                t.place.toLowerCase().startsWith(controller.text.toLowerCase()))

            // ...and then by rest of place name
            .followedBy(widget.viewModel.towers.where((t) => t.place
                .toLowerCase()
                .contains(controller.text.toLowerCase(), 1)))
            .take(20)
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

                  if (result == "map" && buildContext.mounted) {
                    _showTowerOnMap(buildContext, t);
                  }
                },
                onLongPress: () {
                  controller.closeView("");
                  _showTowerOnMap(buildContext, t);
                },
              ),
            );
      },
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
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
                onChanged: (val) => widget.viewModel.setIncludeUnringable(val!),
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
    );
  }

  void _showTowerOnMap(BuildContext context, Tower tower) async {
    _mapController.move(
      LatLng(tower.latitude, tower.longitude),
      13,
      id: "showtower",
    );
    _tabController.animateTo(0);
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

  Future<void> _importCsv(BuildContext context) async {
    final file = await FilePicker.pickFile(
      dialogTitle: "Choose a file",
    );

    if (file != null) {
      final data = await file.xFile.readAsString();
      final numVisits = await widget.viewModel.loadCsvVists(data);

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

  void _exportCsv(BuildContext context) async {
    final data = utf8.encode(widget.viewModel.encodeCsvVisits());

    await FilePicker.saveFile(
      dialogTitle: 'Choose a file',
      fileName: 'visits.csv',
      bytes: data,
    );
  }
}
