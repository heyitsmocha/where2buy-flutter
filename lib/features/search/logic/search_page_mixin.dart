import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:w2b_flutter/features/search/presentation/search_page.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

mixin SearchPageMixin on State<SearchPage>, SingleTickerProviderStateMixin<SearchPage> {
  final bool _isLoggedIn = false; // Placeholder for user authentication status
  bool get isLoggedIn => _isLoggedIn;

  // Slider and range variables
  double _currentSliderValue = 0.08;
  double get currentSliderValue => _currentSliderValue;
  final double _maxRangeKm = 80;
  double get maxRangeKm => _maxRangeKm;

  // Calculate the actual range to make the slider exponential (smaller increments at the start, larger increments at the end)
  double get _searchRangeKm => _maxRangeKm * math.pow(_currentSliderValue, 2);
  double get searchRangeKm => _searchRangeKm;

  // Map variables
  double _currentZoom = 12;
  double get currentZoom => _currentZoom;
  LatLng _cameraLatLng = const LatLng(3.157445974699537, 101.71153740166021); // Default to KL Twin Towers
  LatLng get cameraLatLng => _cameraLatLng;
  LatLng _searchLatLng = const LatLng(3.157445974699537, 101.71153740166021);
  LatLng get searchLatLng => _searchLatLng;

  GoogleMapController? _mapController;

  Circle get searchRangeCircle => Circle(
    circleId: const CircleId('search_range'),
    center: _searchLatLng,
    radius: _searchRangeKm * 1000, // in meters
    fillColor: Colors.blue.withOpacity(0.1),
    strokeColor: Colors.blue.withOpacity(0.5),
    strokeWidth: 2,
  );

  bool _lockSearchArea = true;
  bool get lockSearchArea => _lockSearchArea;

  Matrix4 get pinTransform {
    return Matrix4
    .identity()
      ..translate(_xAnimation.value, _yAnimation.value)
      ..rotateZ(_rotationAnimation.value);
  }

  // Animation variables
  late AnimationController _pinAnimationController;
  get pinAnimationController => _pinAnimationController;
  late Animation<double> 
    _xAnimation,
    _yAnimation,
    _rotationAnimation,
    _shadowOpacity,
    _shadowScale;

  Animation<double> get shadowOpacity => _shadowOpacity;
  Animation<double> get shadowScale => _shadowScale;

  // -------- Search bar handlers --------
  void handleNewRequestButtonPressed () {
    if (_isLoggedIn) {
      // Navigate to request new item page
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Navigating to Request New Item Page...')),
      );
    } else {
      // Prompt user to log in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please log in to post a new item request.'),
          action: SnackBarAction(label: 'Log In', onPressed: () {
            // Navigate to login page
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Navigating to Login Page...')),
            );
          }
        ),
      ));
    }
  }

  void handleSearchInputChanged(String value) {
    if (value.length < 3) return; // only suggest for 3+ characters
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Display suggestions for: $value'),
        //dismiss
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {},
        ),
        duration: const Duration(milliseconds: 50),
      )
    );
  }

  void handleSearchSubmitted(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for: $value')),
    );
  }

  Widget pinAnimationBuilder(BuildContext context, Widget? child) {
    return Stack(
      children: [
        child!,
        // Pin Icon
        Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Center(
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: pinTransform,
              child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
            ),
          ),
        ),
        // Pin Shadow
        Transform.translate(
          offset: const Offset(0, 4),
          child: Opacity(
            opacity: shadowOpacity.value,
            child: Center(
              child: Transform.scale(
                scale: shadowScale.value,
                child: Container(
                  width: 20,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: const BorderRadius.all(Radius.elliptical(12, 4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      )
                    ]
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  // -------- Search page map secondary buttons handlers --------
  void handleSearchAreaLockToggle () {
    setState(() {
      _lockSearchArea = !_lockSearchArea;
      if (!_lockSearchArea) {
        // Set search center to current map center
        _searchLatLng = _cameraLatLng;
      }
    });
  }

  void handleMoveSearchAreaToCameraButtonPressed() {
    // If search area is getting unlocked, move search center to current map center
    setState(() {
      _searchLatLng = _cameraLatLng;
    });
  }

  /// Move or animate the map camera to the current location when possible.
  // Safe to call from either `initState` (after location) or `onMapCreated`.
  void moveCameraToSearchLocation({bool animate = true}) {
    if (!mounted) return;
    if (_mapController == null) return;

    final mapWidth = MediaQuery.of(context).size.width - 16; // approximate padding
    final zoom = _zoomLevelForRadius(_searchRangeKm * 1000, _searchLatLng, mapWidth);

    setState(() => _currentZoom = zoom);

    final cameraUpdate = CameraUpdate.newCameraPosition(
      CameraPosition(target: _searchLatLng, zoom: _currentZoom),
    );

    if (animate) {
      _mapController!.animateCamera(cameraUpdate);
    } else {
      _mapController!.moveCamera(cameraUpdate);
    }
  }

  // -------- Google Map handlers --------
  void handleOnLocationInitialized(LatLng position) {
    setState(() {
      _cameraLatLng = position;
      _searchLatLng = position;
    });
    moveCameraToSearchLocation(animate: false);
  }

  void handleMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void handleCameraMove(CameraPosition position) {
    _cameraLatLng = position.target;
    if (!_lockSearchArea) {
      setState(() => _searchLatLng = position.target);
    }
  }

  // -------- Slider handlers --------
  void handleRangeSliderChanged(double value) {
    setState(() {
      _currentSliderValue = value;
      // update zoom to match the new range (value in km -> meters)
      final mapWidth = MediaQuery.of(context).size.width - 16;
      _currentZoom = _zoomLevelForRadius(_searchRangeKm * 1000, _cameraLatLng, mapWidth);
    });

    // animate the camera to the new zoom
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _cameraLatLng, zoom: _currentZoom),
        ),
      );
    }
  }

  /// Initialise the animation controller and the animations for the pin drop effect.
  void initializeAnimations() {
    _pinAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Moves the pin up by 20 pixels
    _yAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(
        parent: _pinAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // Moves the pin right by 10 pixels
    _xAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _pinAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // Rotates the pin by 15 degrees
    _rotationAnimation = Tween<double>(begin: 0, end: 0.26).animate(
      CurvedAnimation(
        parent: _pinAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _shadowOpacity = Tween<double>(begin: 0.0, end: 0.4).animate(
      CurvedAnimation(
        parent: _pinAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _shadowScale = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _pinAnimationController,
        curve: Curves.easeOut,
      ),
    );
  }

  /// Helper to compute a Google Maps zoom level that will approximately fit
  /// a circle of `radiusMeters` at `lat` within `mapWidthPx` pixels.
  /// Uses the Mercator meters-per-pixel formula:
  ///   metersPerPixel = 156543.03392 * cos(lat) / 2^zoom
  /// Solved for zoom with a padding factor so the radius fills ~80% of width.
  double _zoomLevelForRadius(double radiusMeters, LatLng lat, double mapWidthPx, {double paddingFactor = 0.8}) {
    if (mapWidthPx <= 0 || radiusMeters <= 0) return 17;
    final latRad = lat.latitude * math.pi / 180.0;
    final coverageMeters = (radiusMeters * 2) / paddingFactor; // total width to cover
    final metersPerPixel = coverageMeters / mapWidthPx;
    final value = (156543.03392 * math.cos(latRad)) / metersPerPixel;
    final zoom = math.log(value) / math.ln2;
    // clamp to reasonable Google Maps zoom range
    return zoom.clamp(0.0, 21.0);
  }
}