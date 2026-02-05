import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:w2b_flutter/util/location_util.dart';

mixin MapWidgetMixin <T extends StatefulWidget> on State<T> {
  bool get isLoading;
  set isLoading(bool value);

  bool get isInitializing;
  set isInitializing(bool value);

  CameraPosition get currentCameraPosition;
  set currentCameraPosition(CameraPosition value);

  GoogleMapController? get mapController;
  set mapController(GoogleMapController? value);

  @override
  void initState() {
    super.initState();
  }

  /// Get the current location of the user
  Future<LatLng> getCurrentLocation({Function(LatLng position)? onLocationInitialized}) async {
    // Trigger UI rebuild to disable the My Location button
    setState(() => isLoading = true);
    
    Position position = await LocationUtil.getCurrentLocation();
    LatLng currentLocation = LatLng(position.latitude, position.longitude);
    
    if (isInitializing) {
      onLocationInitialized?.call(currentLocation);
    }

    // Trigger UI rebuild...
    setState(() {
      isInitializing = false; // ...to show the map instead of the loading indicator
      isLoading = false; // ...to re-enable the My Location button
    });

    return currentLocation;
  }

  /// Animate the camera to the current LatLng and zoom level
  void moveCameraToLatestPosition() {
    // Animate the camera to the new position
    if (mounted) {
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          currentCameraPosition,
        ),
      );
    }
  }
}