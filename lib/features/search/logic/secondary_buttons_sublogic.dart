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
      // Set search center to current map center
      state.searchLatLng = state.cameraLatLng;
    }
    _parent.notifyListeners();
  }

  void handleMoveSearchAreaToCameraButtonPressed() {
    state.searchLatLng = state.cameraLatLng;
    _parent.notifyListeners();
  }
}