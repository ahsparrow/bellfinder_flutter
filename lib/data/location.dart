import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';

export 'package:geolocator/geolocator.dart' show Position;

Future<bool> hasPermission() async {
  final log = Logger("BF");

  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    log.info("Location service not enabled");
    return false;
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      log.info("Location permission denied");
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    log.info("Location permission denied forever");
    return false;
  }

  return true;
}

Future<Position?> getLastKnownPosition() async {
  final pos = await Geolocator.getLastKnownPosition();
  if (pos != null && DateTime.now().difference(pos.timestamp).inSeconds < 60) {
    return pos;
  } else {
    return null;
  }
}

Future<Stream<Position>?> getPositionStream() async {
  if (await hasPermission()) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(distanceFilter: 10),
    );
  } else {
    return null;
  }
}
