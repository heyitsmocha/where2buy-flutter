import 'package:w2b_flutter/features/search/logic/search_page_controller.dart';

class SecondaryButtonsSubLogic {
  final SearchPageController _parent;
  final SearchPageState state;
  SecondaryButtonsSubLogic(this._parent, this.state);

  // -------- Search page map secondary buttons handlers --------
  void handleSearchAreaLockToggle () {
    state.lockSearchArea = !state.lockSearchArea;
      // If unlocking the search area
    if (!state.lockSearchArea) {
      if (state.hasSelectedSearchResult) {
        _parent.searchBarSubLogic.performSearchForAnswers();
      }

      // Set search center to current map center
      state.searchLatLng = state.cameraLatLng;

      // Recalculate the pixel radius for the search area based on the current zoom level and search radius
      _parent.pixelRadiusNotifier.value = _parent.calculatePixelRadius(
        _parent.searchRangeKm * 1000, // Convert km to meters
        state.searchLatLng.latitude,
        state.currentZoom,
      );
    }
    _parent.notifyListeners();
  }

  void handleMoveSearchAreaToCameraButtonPressed() {
    state.searchLatLng = state.cameraLatLng;
    _parent.notifyListeners();

    if (state.hasSelectedSearchResult) {
      _parent.searchBarSubLogic.performSearchForAnswers();
    }
  }
}