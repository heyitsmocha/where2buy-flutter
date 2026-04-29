import 'package:w2b_flutter/features/search/logic/search_page_controller.dart';

class SecondaryButtonsSubLogic {
  final SearchPageController _parent;
  SecondaryButtonsSubLogic(this._parent);

  // -------- Search page map secondary buttons handlers --------
  void handleSearchAreaLockToggle () {
    _parent.state.lockSearchArea = !_parent.state.lockSearchArea;
      // If unlocking the search area
    if (!_parent.state.lockSearchArea) {
      _parent.searchBarSubLogic.performSearchForAnswers();
      
      // Set search center to current map center
      _parent.state.searchLatLng = _parent.state.cameraLatLng;

      _parent.recalculatePixelRadius();
    }
    _parent.notifyListeners();
  }

  void handleMoveSearchAreaToCameraButtonPressed() {
    _parent.state.searchLatLng = _parent.state.cameraLatLng;
    _parent.notifyListeners();

    _parent.searchBarSubLogic.performSearchForAnswers();
  }
}