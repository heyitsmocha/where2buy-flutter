import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:w2b_flutter/features/search/logic/search_page_controller.dart';

class MapSubLogic {
  // -------- Google Map handlers --------
  final SearchPageController _parent;
  final SearchPageState state;
  MapSubLogic(this._parent, this.state);

  /// Initializes the camera and search location when the user's location is first obtained.
  void handleOnLocationInitialized(LatLng position, double mapWidth) {
    state.cameraLatLng = position;
    state.searchLatLng = position;
    _parent.notifyListeners();
  }

  /// Stores the map controller reference when the map is created.
  void handleMapCreated(GoogleMapController controller) {
    _parent.mapController = controller;
  }

  /// Stores the camera position and updates the search center if the search area is unlocked when the camera moves.
  void handleCameraMove(CameraPosition position) {
    // Update the camera position
    state.cameraLatLng = position.target;

    // Also update the search center if not locked
    if (!state.lockSearchArea) {
      state.searchLatLng = position.target;

      // Notify listener to make the circle follow the camera
      _parent.notifyListeners();
    }
  }
}