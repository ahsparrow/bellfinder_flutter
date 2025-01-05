import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../home_viewmodel.dart';

final tower3 = SvgPicture.asset('assets/tower3.svg');
final tower4 = SvgPicture.asset('assets/tower4.svg');
final tower5 = SvgPicture.asset('assets/tower5.svg');
final tower6 = SvgPicture.asset('assets/tower6.svg');
final tower8 = SvgPicture.asset('assets/tower8.svg');
final tower10 = SvgPicture.asset('assets/tower10.svg');
final tower12 = SvgPicture.asset('assets/tower12.svg');
final towerUnringable = SvgPicture.asset('assets/tower_unringable.svg');

class TowerMarker extends Marker {
  final String place;

  const TowerMarker({
    super.key,
    required super.point,
    required super.child,
    super.height = 30,
    required this.place,
  });
}

class MapWidget extends StatefulWidget {
  const MapWidget({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  final PopupController _popupController = PopupController();

  List<TowerMarker> markers = [];

  @override
  initState() {
    for (var tower in widget.viewModel.towers) {
      markers.add(
        TowerMarker(
          place: tower.place,
          point: LatLng(tower.latitude, tower.longitude),
          child: tower.unringable
              ? towerUnringable
              : switch (tower.bells) {
                  <= 3 => tower3,
                  4 => tower4,
                  5 => tower5,
                  6 || 7 => tower6,
                  8 || 9 => tower8,
                  10 || 11 => tower10,
                  _ => tower12,
                },
        ),
      );

      super.initState();
    }
  }

  @override
  Widget build(context) {
    return PopupScope(
      popupController: _popupController,
      child: FlutterMap(
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
                popupBuilder: (_, marker) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  width: 200,
                  height: 100,
                  child: Text((marker as TowerMarker).place),
                ),
              ),
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
  }
}
