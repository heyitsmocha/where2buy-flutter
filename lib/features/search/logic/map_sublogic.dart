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
  void handleMapCreated(GoogleMapController controller) async {
    _parent.mapController = controller;

    _parent.state.currentZoom = await controller.getZoomLevel();

    // Calculate the initial pixel radius for the search area based on the initial zoom level and search radius
    _parent.pixelRadiusNotifier.value = _parent.calculatePixelRadius(
      _parent.searchRangeKm * 1000, // Convert km to meters
      _parent.state.searchLatLng.latitude,
      await controller.getZoomLevel(),
    );
  }

  /// Stores the camera position and updates the search center if the search area is unlocked when the camera moves.
  void handleCameraMove(CameraPosition position) {
    // Update the camera position
    state.cameraLatLng = position.target;

    // Also update the search area if not locked
    if (!state.lockSearchArea) {
      state.searchLatLng = position.target;

      // Update the pixel radius for the search area based on the new zoom level and search radius
      _parent.pixelRadiusNotifier.value = _parent.calculatePixelRadius(
        _parent.searchRangeKm * 1000, // Convert km to meters
        state.searchLatLng.latitude,
        position.zoom,
      );
    }
  }
  
  /// Searches for answers if needed when the camera stops moving, and resets the slider movement flag.
  void handleCameraIdle() {
    if (state.hasSelectedSearchResult) {
      // Check if the camera movement is triggered by map panning (not zooming from the range slider)
      if (!state.lockSearchArea && !state.isCameraMovedFromSlider) {
        _parent.searchBarSubLogic.performSearchForAnswers();
      }
    }

    // Reset the flag after handling camera idle
    state.isCameraMovedFromSlider = false;
  }
}