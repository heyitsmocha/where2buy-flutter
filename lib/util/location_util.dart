import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

class LocationUtil {
  /// Get the current location of the device, including handling permission
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(); 
  }

  /// Get the last known location of the device, or current location if last known is not available
  static Future<Position> getLastKnownLocation() async {
    return await Geolocator.getLastKnownPosition() ?? await getCurrentLocation();
  }

  /// Helper to compute a Google Maps zoom level that will approximately fit
  /// a circle of `radiusMeters` at `lat` within `mapWidthPx` pixels.
  /// Uses the Mercator meters-per-pixel formula:
  ///   metersPerPixel = 156543.03392 * cos(lat) / 2^zoom
  /// Solved for zoom with a padding factor so the radius fills ~80% of width.
  static double getZoomLevelForRadius(double radiusMeters, LatLng lat, double mapWidthPx, {double paddingFactor = 0.8}) {
    if (mapWidthPx <= 0 || radiusMeters <= 0) return 17;
    final latRad = lat.latitude * math.pi / 180.0;
    final coverageMeters = (radiusMeters * 2) / paddingFactor; // total width to cover
    final metersPerPixel = coverageMeters / mapWidthPx;
    final value = (156543.03392 * math.cos(latRad)) / metersPerPixel;
    final zoom = math.log(value) / math.ln2;
    // clamp to reasonable Google Maps zoom range
    return zoom.clamp(0.0, 21.0);
  }
}