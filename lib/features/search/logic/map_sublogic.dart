import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:w2b_flutter/features/search/logic/search_page_controller.dart';

class MapSubLogic {
  // -------- Google Map handlers --------
  final SearchPageController _parent;
  final SearchPageState state;
  MapSubLogic(this._parent, this.state);

  /// Initializes the camera and search location when the user's location is first obtained.
  void handleOnLocationInitialized(LatLng position) {
    state.cameraLatLng = position;
    state.searchLatLng = position;
    _parent.notify();
    _parent.moveCameraToSearchLocation(animate: false);
  }

  void handleMapCreated(GoogleMapController controller) {
    _parent.mapController = controller;
  }

  void handleCameraMove(CameraPosition position) {
    // Update the camera position
    state.cameraLatLng = position.target;
    // Also update the search center if not locked
    if (!state.lockSearchArea) {
      state.searchLatLng = position.target;
    }
    _parent.notify();
  }
}