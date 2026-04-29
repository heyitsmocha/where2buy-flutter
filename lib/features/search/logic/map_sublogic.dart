import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:w2b_flutter/features/search/logic/search_page_controller.dart';

class MapSubLogic {
  // -------- Google Map handlers --------
  final SearchPageController _parent; 
  MapSubLogic(this._parent);

  /// Initializes the camera and search location when the user's location is first obtained.
  void handleOnLocationInitialized(LatLng position, double mapWidth) {
    _parent.state.cameraLatLng = position;
    _parent.state.searchLatLng = position;
    _parent.notifyListeners();
  }

  /// Stores the map controller reference when the map is created.
  void handleMapCreated(GoogleMapController controller) async {
    _parent.mapController = controller;

    // Calculate the initial pixel radius for the search area based on the initial zoom level and search radius
    _parent.state.currentZoom = await controller.getZoomLevel();
    _parent.recalculatePixelRadius();
  }

  /// Stores the camera position and updates the search center if the search area is unlocked when the camera moves.
  void handleCameraMove(CameraPosition position) {
    // Update the camera position
    _parent.state.cameraLatLng = position.target;
    _parent.state.currentZoom = position.zoom;

    // Also update the search area if not locked
    if (!_parent.state.lockSearchArea) {
      _parent.state.searchLatLng = position.target;

      // Update the pixel radius for the search area based on the new zoom level and search radius
      _parent.recalculatePixelRadius(zoom: position.zoom);
    }
  }
  
  /// Searches for answers if needed when the camera stops moving, and resets the slider movement flag.
  void handleCameraIdle() {
    // Check if the camera movement is triggered by map panning (not zooming from the range slider)
    if (!_parent.state.lockSearchArea && !_parent.state.isCameraMovedFromSlider) {
      _parent.searchBarSubLogic.performSearchForAnswers();
    }
    
    // Reset the flag after handling camera idle
    _parent.state.isCameraMovedFromSlider = false;
  }
}