import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../home_viewmodel.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  @override
  Widget build(context) {
    List<Marker> markers = [];
    final tower3 = SvgPicture.asset('assets/tower3.svg');
    final tower4 = SvgPicture.asset('assets/tower4.svg');
    final tower5 = SvgPicture.asset('assets/tower5.svg');
    final tower6 = SvgPicture.asset('assets/tower6.svg');
    final tower8 = SvgPicture.asset('assets/tower8.svg');
    final tower10 = SvgPicture.asset('assets/tower10.svg');
    final tower12 = SvgPicture.asset('assets/tower12.svg');
    final towerUnringable = SvgPicture.asset('assets/tower_unringable.svg');

    for (var tower in widget.viewModel.towers) {
      markers.add(Marker(
        point: LatLng(tower.latitude, tower.longitude),
        child: GestureDetector(
          onTap: () => showDialog<void>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text(tower.place),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text(tower.dedication),
                    Text(
                        "${HomeViewModel.weightCwt(tower.weight).toStringAsFixed(0)} cwt"),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text("More Info"),
                  onPressed: () {},
                )
              ],
              actionsAlignment: MainAxisAlignment.spaceBetween,
            ),
          ),
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
        height: 40,
      ));
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(51.07, -1.61),
        initialZoom: 10,
        interactionOptions: InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'uk.org.freeflight.bellfinder',
        ),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            markers: markers,
            builder: (context, markers) {
              return Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blue),
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
    );
  }
}
