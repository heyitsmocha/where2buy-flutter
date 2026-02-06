import 'package:w2b_flutter/features/search/logic/search_page_base_mixin.dart';

mixin SearchPageSecondaryButtonsMixin on SearchPageBaseMixin {
  // -------- Search page map secondary buttons handlers --------
  void handleSearchAreaLockToggle () {
    setState(() {
      lockSearchArea = !lockSearchArea;
      if (!lockSearchArea) {
        // Set search center to current map center
        searchLatLng = cameraLatLng;
      }
    });
  }

  void handleMoveSearchAreaToCameraButtonPressed() {
    // If search area is getting unlocked, move search center to current map center
    setState(() {
      searchLatLng = cameraLatLng;
    });
  }
}