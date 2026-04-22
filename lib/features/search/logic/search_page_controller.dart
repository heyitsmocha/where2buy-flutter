import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:w2b_flutter/base_controller.dart';
import 'package:w2b_flutter/features/search/logic/map_sublogic.dart';
import 'package:w2b_flutter/features/search/logic/search_bar_sublogic.dart';
import 'package:w2b_flutter/features/search/logic/secondary_buttons_sublogic.dart';

enum SearchPageUiEvent implements UIEvent {
  showSnackbar,
  showLoginSnackbar,
  showNewRequestConfirmationDialog,
  newRequestPosted,
  newRequestFailed,
}

class SearchPageState {
  bool isLoggedIn;
  bool lockSearchArea;
  double currentSliderValue;
  double currentZoom;
  LatLng cameraLatLng;
  LatLng searchLatLng;

  SearchPageState({
    this.isLoggedIn = false,
    this.lockSearchArea = true,
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
  final Dio dio;

  late SearchPageState state;

  SearchPageController(this.dio) {
    state = SearchPageState(
      cameraLatLng: const LatLng(3.157445974699537, 101.71153740166021),
      searchLatLng: const LatLng(3.157445974699537, 101.71153740166021),
    );
    searchBarSubLogic = SearchBarSubLogic(this, state);
    mapSubLogic = MapSubLogic(this, state);
    secondaryButtonsSubLogic = SecondaryButtonsSubLogic(this, state);
  }

  final double _maxRangeKm = 80;
  double get maxRangeKm => _maxRangeKm;

  // Calculate the actual range to make the slider exponential (smaller increments at the start, larger increments at the end)
  double get _searchRangeKm => _maxRangeKm * math.pow(state.currentSliderValue, 2);
  double get searchRangeKm => _searchRangeKm;

  String get searchRangeText {
    if (searchRangeKm == 0) {
      return 'Exact Location';
    } else if (searchRangeKm >= 1) {
      return '${searchRangeKm.round()} km';
    } else {
      return '${(searchRangeKm * 1000).round()} m';
    }
  }
  

  GoogleMapController? _mapController;
  GoogleMapController? get mapController => _mapController;
  set mapController(GoogleMapController? controller) {
    _mapController = controller;
  }

  Circle get searchRangeCircle => Circle(
    circleId: const CircleId('search_range'),
    center: state.searchLatLng,
    radius: _searchRangeKm * 1000, // in meters
    fillColor: Colors.blue.withOpacity(0.1),
    strokeColor: Colors.blue.withOpacity(0.5),
    strokeWidth: 2,
  );

  // -------- Slider handlers --------
  /// Updates the slider value and adjusts the map zoom accordingly.
  void handleRangeSliderChanged(double value, double mapWidth) {
    state.currentSliderValue = value;
    // update zoom to match the new range (value in km -> meters)
    state.currentZoom = getZoomLevelForRadius(_searchRangeKm * 1000, state.cameraLatLng, mapWidth);

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

  /// Helper to compute a Google Maps zoom level that will approximately fit
  /// a circle of `radiusMeters` at `lat` within `mapWidthPx` pixels.
  /// Uses the Mercator meters-per-pixel formula:
  ///   metersPerPixel = 156543.03392 * cos(lat) / 2^zoom
  /// Solved for zoom with a padding factor so the radius fills ~80% of width.
  double getZoomLevelForRadius(double radiusMeters, LatLng lat, double mapWidthPx, {double paddingFactor = 0.8}) {
    if (mapWidthPx <= 0 || radiusMeters <= 0) return 17;
    final latRad = lat.latitude * math.pi / 180.0;
    final coverageMeters = (radiusMeters * 2) / paddingFactor; // total width to cover
    final metersPerPixel = coverageMeters / mapWidthPx;
    final value = (156543.03392 * math.cos(latRad)) / metersPerPixel;
    final zoom = math.log(value) / math.ln2;
    // clamp to reasonable Google Maps zoom range
    return zoom.clamp(0.0, 21.0);
  }

  
    /// Move or animate the map camera to the current location when possible.
  // Safe to call from either `initState` (after location) or `onMapCreated`.
  void moveCameraToSearchLocation(double mapWidth, {bool animate = true}) {
    // if (!mounted) return;
    if (_mapController == null) return;

    final zoom = getZoomLevelForRadius(searchRangeKm * 1000, state.searchLatLng, mapWidth);

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
}