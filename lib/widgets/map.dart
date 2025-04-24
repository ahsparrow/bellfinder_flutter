import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/database.dart';
import '../screens/tower_screen.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/tower_viewmodel.dart';

final tower3 = SvgPicture.asset('assets/tower3.svg');
final tower4 = SvgPicture.asset('assets/tower4.svg');
final tower5 = SvgPicture.asset('assets/tower5.svg');
final tower6 = SvgPicture.asset('assets/tower6.svg');
final tower8 = SvgPicture.asset('assets/tower8.svg');
final tower10 = SvgPicture.asset('assets/tower10.svg');
final tower12 = SvgPicture.asset('assets/tower12.svg');
final towerUnringable = SvgPicture.asset('assets/tower_unringable.svg');

class TowerMarker extends Marker {
  final int towerId;

  const TowerMarker({
    super.key,
    required super.point,
    required super.child,
    super.height = 30,
    super.width = 30,
    super.alignment,
    required this.towerId,
  });
}

class MapWidget extends StatefulWidget {
  const MapWidget(
      {super.key, required this.viewModel, required this.controller});

  final HomeViewModel viewModel;
  final MapController controller;

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  final PopupController _popupController = PopupController();

  List<TowerMarker> markers = [];

  @override
  Widget build(context) {
    return ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          markers = widget.viewModel.towers
              .map((t) => TowerMarker(
                    towerId: t.towerId,
                    point: LatLng(t.latitude, t.longitude),
                    alignment: Alignment(0, -1),
                    child: t.unringable
                        ? towerUnringable
                        : switch (t.bells) {
                            <= 3 => tower3,
                            4 => tower4,
                            5 => tower5,
                            6 || 7 => tower6,
                            8 || 9 => tower8,
                            10 || 11 => tower10,
                            _ => tower12,
                          },
                  ))
              .toList();

          return PopupScope(
            popupController: _popupController,
            child: FlutterMap(
              mapController: widget.controller,
              options: MapOptions(
                initialCenter: LatLng(51.07, -1.61),
                initialZoom: 10,
                maxZoom: 15,
                interactionOptions: InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                onTap: (_, __) => _popupController.hideAllPopups(),
              ),
              children: [
                // Map layer
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'uk.org.freeflight.bellfinder',
                ),

                // Marker layer
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    markers: markers,
                    padding: EdgeInsets.all(50),
                    popupOptions: PopupOptions(
                      popupController: _popupController,
                      popupBuilder: (_, marker) => popupBuilder(marker),
                    ),
                    disableClusteringAtZoom: 13,
                    showPolygon: false,
                    builder: (context, markers) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.blue,
                        ),
                        child: Center(
                          child: Text(
                            markers.length.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Attribution layer
                RichAttributionWidget(
                  showFlutterMapAttribution: false,
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () => launchUrl(Uri.parse(
                          'https://openstreetmap.org/copyright')), // (external)
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  Widget popupBuilder(Marker marker) {
    final tower = widget.viewModel.getTower((marker as TowerMarker).towerId);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      width: 250,
      margin: EdgeInsets.all(4),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4),
            child: Text(
              tower.place,
              textScaler: TextScaler.linear(1.3),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4),
            child: Text(
              tower.dedication,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4),
            child: Text(
              "${HomeViewModel.weightCwt(tower.weight).round()} cwt",
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () => _popupController.hideAllPopups(),
                ),
                TextButton(
                  child: Text("Info"),
                  onPressed: () {
                    _popupController.hideAllPopups();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TowerScreen(
                          viewModel: TowerViewModel(
                            database: context.read<AppDatabase>(),
                            towerId: tower.towerId,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
