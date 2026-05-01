import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:w2b_flutter/base_controller.dart';
import 'package:w2b_flutter/features/search/logic/map_sublogic.dart';
import 'package:w2b_flutter/features/search/logic/search_bar_sublogic.dart';
import 'package:w2b_flutter/features/search/logic/secondary_buttons_sublogic.dart';
import 'package:w2b_flutter/util/location_util.dart';

enum SearchPageUiEvent implements UIEvent {
  showSnackbar,
  showLoginSnackbar,
  showNewRequestConfirmationDialog,
  showNoNearbyResultsSnackbar,
  searchResultSelected,
  newRequestPosted,
  newRequestFailed,
  searchLockedWarning,
}

class SearchPageState {
  bool isLoggedIn;
  bool lockSearchArea;
  bool hasSelectedSearchResult;

  /// Flag to check if the slider is the cause of the camera movement
  bool isCameraMovedFromSlider;

  double currentSliderValue;
  double currentZoom;
  LatLng cameraLatLng;
  LatLng searchLatLng;
  List<Marker> markers = [];

  String snackbarMessage = '';

  SearchPageState({
    this.isLoggedIn = false,
    this.hasSelectedSearchResult = false,
    this.lockSearchArea = true,
    this.isCameraMovedFromSlider = false,
    this.currentSliderValue = 0,
    this.currentZoom = 12,
    required this.cameraLatLng,
    required this.searchLatLng,
  });
}

class SearchPageController extends BaseController<SearchPageUiEvent> {
  late final SearchBarSubLogic searchBarSubLogic;
  late final MapSubLogic mapSubLogic;
  late final SecondaryButtonsSubLogic secondaryButtonsSubLogic;
  final TextEditingController searchBarController;
  final Dio dio;

  late SearchPageState state;

  SearchPageController(this.dio, this.searchBarController) {
    state = SearchPageState(
      cameraLatLng: const LatLng(3.157445974699537, 101.71153740166021),
      searchLatLng: const LatLng(3.157445974699537, 101.71153740166021),
    );
    searchBarSubLogic = SearchBarSubLogic(this);
    mapSubLogic = MapSubLogic(this);
    secondaryButtonsSubLogic = SecondaryButtonsSubLogic(this);
  }

  final double minRadiusKm = 0.5;
  final double maxRadiusKm = 50;

  // Calculate the actual range to make the slider exponential (smaller increments at the start, larger increments at the end)
  double get searchRadiusKm {
    final t = math.pow(state.currentSliderValue, 2);
    return minRadiusKm + (maxRadiusKm - minRadiusKm) * t;
  }

  String get searchRadiusText {
    if (searchRadiusKm == 0) {
      return 'Exact Location';
    } else if (searchRadiusKm >= 1) {
      return '${searchRadiusKm.round()} km';
    } else {
      return '${(searchRadiusKm * 1000).round()} m';
    }
  }

  ValueNotifier<double> searchRadiusPixelsNotifier = ValueNotifier(0);

  GoogleMapController? mapController;

  Circle get searchRangeCircle => Circle(
    circleId: const CircleId('search_range'),
    center: state.searchLatLng,
    radius: (searchRadiusKm * 1000),
    fillColor: Colors.blue.withOpacity(0.1),
    strokeColor: Colors.blue.withOpacity(0.5),
    strokeWidth: 2,
  );

  // -------- Slider handlers --------
  /// Updates the slider value and notifies ensure the slider is rebuilt with the latest value.
  void handleRangeSliderChanged(double value) {
    state.currentSliderValue = value;
    if (!state.lockSearchArea) {
      recalculatePixelRadius();
    }
    notifyListeners();
  }

  /// Searches for answers if needed and moves the camera to the search location
  void handleRangeSliderChangeEnd(double mapWidth) {
    // When the user finishes changing the slider, if they have already selected a search result, we should update the search results to reflect the new range
    if (state.hasSelectedSearchResult) {
      // Set flag to indicate camera movement is from slider
      // This prevents the onCameraIdle handler from triggering an additional search when the camera moves in response to the slider change
      state.isCameraMovedFromSlider = true; 
      searchBarSubLogic.performSearchForAnswers();
    }
    moveCameraToSearchLocation(mapWidth);
  }
  
  /// Move or animate the map camera to the current location when possible.
  // Safe to call from either `initState` (after location) or `onMapCreated`.
  void moveCameraToSearchLocation(double mapWidth, {bool animate = true}) {
    // if (!mounted) return;
    if (mapController == null) return;

    final zoom = LocationUtil.getZoomLevelForRadius(searchRadiusKm * 1000, state.searchLatLng, mapWidth);
    state.currentZoom = zoom;
    notifyListeners();

    final cameraUpdate = CameraUpdate.newCameraPosition(
      CameraPosition(target: state.searchLatLng, zoom: state.currentZoom),
    );

    if (animate) {
      mapController!.animateCamera(cameraUpdate);
    } else {
      mapController!.moveCamera(cameraUpdate);
    }
  }

  /// Recalculates the pixel radius for the search area based on the zoom provided. 
  /// 
  /// If no zoom is provided, it uses the current zoom level from the state.
  void recalculatePixelRadius({double? zoom}) {
    // 156543.03392 is the equatorial circumference / 256
    double metersPerPixel = 156543.03392 * math.cos(state.searchLatLng.latitude * math.pi / 180) / math.pow(2, zoom ?? state.currentZoom);

    double searchRadiusMeters = searchRadiusKm * 1000;

    searchRadiusPixelsNotifier.value = searchRadiusMeters/metersPerPixel;
  }
}