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
    final svg = SvgPicture.asset('assets/tower6.svg');

    for (var tower in widget.viewModel.towers) {
      markers.add(Marker(
        point: LatLng(tower.latitude, tower.longitude),
        child: svg,
        height: 30,
        width: 60,
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
