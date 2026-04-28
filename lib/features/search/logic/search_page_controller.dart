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
    this.currentSliderValue = 0.08,
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
    searchBarSubLogic = SearchBarSubLogic(this, state);
    mapSubLogic = MapSubLogic(this, state);
    secondaryButtonsSubLogic = SecondaryButtonsSubLogic(this, state);
  }

  final double _maxRadiusKm = 50;
  double get maxRadiusKm => _maxRadiusKm;

  // Calculate the actual range to make the slider exponential (smaller increments at the start, larger increments at the end)
  double get _searchRadiusKm => _maxRadiusKm * math.pow(state.currentSliderValue, 2);
  double get searchRadiusKm => _searchRadiusKm;

  String get searchRadiusText {
    if (searchRadiusKm == 0) {
      return 'Exact Location';
    } else if (searchRadiusKm >= 1) {
      return '${searchRadiusKm.round()} km';
    } else {
      return '${(searchRadiusKm * 1000).round()} m';
    }
  }

  ValueNotifier<double> pixelRadiusNotifier = ValueNotifier(0);

  GoogleMapController? _mapController;
  set mapController(GoogleMapController? controller) {
    _mapController = controller;
  }

  Circle get searchRangeCircle => Circle(
    circleId: const CircleId('search_range'),
    center: state.searchLatLng,
    radius: (_searchRadiusKm * 1000),
    fillColor: Colors.blue.withOpacity(0.1),
    strokeColor: Colors.blue.withOpacity(0.5),
    strokeWidth: 2,
  );

  // -------- Slider handlers --------
  /// Updates the slider value and adjusts the map zoom accordingly.
  void handleRangeSliderChanged(double value, double mapWidth) {
    state.currentSliderValue = value;
    // update zoom to match the new range (value in km -> meters)
    state.currentZoom = LocationUtil.getZoomLevelForRadius(_searchRadiusKm * 1000, state.cameraLatLng, mapWidth);

    notifyListeners();

    // animate the camera to the new zoom
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: state.cameraLatLng, zoom: state.currentZoom),
        ),
      );
    }
  }

  void handleRangeSliderChangeEnd(double value) {
    // When the user finishes changing the slider, if they have already selected a search result, we should update the search results to reflect the new range
    if (state.hasSelectedSearchResult) {
      // Set flag to indicate camera movement is from slider
      // This prevents the onCameraIdle handler from triggering an additional search when the camera moves in response to the slider change
      state.isCameraMovedFromSlider = true; 
      searchBarSubLogic.performSearchForAnswers();
    }
  }
    /// Move or animate the map camera to the current location when possible.
  // Safe to call from either `initState` (after location) or `onMapCreated`.
  void moveCameraToSearchLocation(double mapWidth, {bool animate = true}) {
    // if (!mounted) return;
    if (_mapController == null) return;

    final zoom = LocationUtil.getZoomLevelForRadius(searchRadiusKm * 1000, state.searchLatLng, mapWidth);

    state.currentZoom = zoom;
    notifyListeners();

    final cameraUpdate = CameraUpdate.newCameraPosition(
      CameraPosition(target: state.searchLatLng, zoom: state.currentZoom),
    );

    if (animate) {
      _mapController!.animateCamera(cameraUpdate);
    } else {
      _mapController!.moveCamera(cameraUpdate);
    }
  }

  double calculatePixelRadius(double meters, double latitude, double zoom) {
    // 156543.03392 is the equatorial circumference / 256
    double metersPerPixel = 156543.03392 * math.cos(latitude * math.pi / 180) / math.pow(2, zoom);
    return meters/metersPerPixel;
  }
}