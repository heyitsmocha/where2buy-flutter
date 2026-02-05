import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

mixin SearchPageLogicMixin<T extends StatefulWidget> on State<T>{
  GoogleMapController? get mapController;
  set mapController(GoogleMapController? value);

  LatLng get searchLatLng;
  set searchLatLng(LatLng value);

  double get currentZoom;
  set currentZoom(double value);

  double get searchRangeKm;
  set searchRangeKm(double value);

  /// Helper to compute a Google Maps zoom level that will approximately fit
  /// a circle of `radiusMeters` at `lat` within `mapWidthPx` pixels.
  /// Uses the Mercator meters-per-pixel formula:
  ///   metersPerPixel = 156543.03392 * cos(lat) / 2^zoom
  /// Solved for zoom with a padding factor so the radius fills ~80% of width.
  double zoomLevelForRadius(double radiusMeters, LatLng lat, double mapWidthPx, {double paddingFactor = 0.8}) {
    if (mapWidthPx <= 0 || radiusMeters <= 0) return 17;
    final latRad = lat.latitude * math.pi / 180.0;
    final coverageMeters = (radiusMeters * 2) / paddingFactor; // total width to cover
    final metersPerPixel = coverageMeters / mapWidthPx;
    final value = (156543.03392 * math.cos(latRad)) / metersPerPixel;
    final zoom = math.log(value) / math.ln2;
    // clamp to reasonable Google Maps zoom range
    return zoom.clamp(0.0, 21.0);
  }

  /// Move or animate the map camera to the current location when possible.
  // Safe to call from either `initState` (after location) or `onMapCreated`.
  void moveToSearchLocation({bool animate = true}) {
    if (!mounted) return;
    if (mapController == null) return;

    final mapWidth = MediaQuery.of(context).size.width - 16; // approximate padding
    final zoom = zoomLevelForRadius(searchRangeKm * 1000, searchLatLng, mapWidth);

    setState(() => currentZoom = zoom);

    final cameraUpdate = CameraUpdate.newCameraPosition(
      CameraPosition(target: searchLatLng, zoom: currentZoom),
    );

    if (animate) {
      mapController!.animateCamera(cameraUpdate);
    } else {
      mapController!.moveCamera(cameraUpdate);
    }
  }
}