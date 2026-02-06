import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:w2b_flutter/features/search/logic/search_page_base_mixin.dart';

mixin SearchPageMapMixin on SearchPageBaseMixin {
  // -------- Google Map handlers --------
  void handleOnLocationInitialized(LatLng position) {
    setState(() {
      cameraLatLng = position;
      searchLatLng = position;
    });
    moveCameraToSearchLocation(animate: false);
  }

  void handleMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void handleCameraMove(CameraPosition position) {
    cameraLatLng = position.target;
    if (!lockSearchArea) {
      setState(() => searchLatLng = position.target);
    }
  }
}