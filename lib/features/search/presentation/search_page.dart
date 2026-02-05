import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/components/base_search_bar.dart';
import 'package:w2b_flutter/components/map/map_widget.dart';
import 'package:w2b_flutter/features/search/logic/search_page_mixin.dart';
import 'package:w2b_flutter/util/location_util.dart';

class SearchPage extends StatefulWidget {
  const SearchPage(this.dio, {super.key, required this.mainScaffoldKey});

  final GlobalKey<ScaffoldState> mainScaffoldKey;
  final Dio dio;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SearchPageLogicMixin, SingleTickerProviderStateMixin {
  final bool _isLoggedIn = false; // Placeholder for user authentication status

  // Slider and range variables
  double _currentSliderValue = 0.08;
  final double _maxRangeKm = 80;

  // Calculate the actual range to make the slider exponential (smaller increments at the start, larger increments at the end)
  double get _searchRangeKm => _maxRangeKm * math.pow(_currentSliderValue, 2);

  // Map variables
  double _currentZoom = 12;
  LatLng _cameraLatLng = const LatLng(3.157445974699537, 101.71153740166021); // Default to KL Twin Towers
  LatLng _searchLatLng = const LatLng(3.157445974699537, 101.71153740166021);

  GoogleMapController? _mapController;
  bool _lockSearchArea = true;

  // Animation variables
  late AnimationController _pinAnimationController;
  late Animation<double> 
    _xAnimation,
    _yAnimation,
    _rotationAnimation,
    _shadowOpacity,
    _shadowScale;

  @override
  void initState() {
    super.initState();

    // Initialise animations
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

    // Set _currentLatLng to current location 
    // LocationUtil.getCurrentLocation().then((position) {
    //   log('Current location: ${position.latitude}, ${position.longitude}');
    //   setState(() {
    //     _cameraLatLng = LatLng(position.latitude, position.longitude);
    //   });

    //   // Try to move/animate the map to the user's location if controller exists
    //   moveToCurrentLocation(animate: false);
    // }).catchError((error) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Error getting location: $error')),
    //   );
    // });
  }

  ButtonStyle _secondaryButtonStyle(BuildContext context, {bool translucentOnUnlock = true}) {
    // Secondary buttons are disabled when the search area is unlocked
    return !_lockSearchArea && translucentOnUnlock
    ? ButtonStyle(
        // Semi-transparent background color
        backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onInverseSurface.withOpacity(0.8)),
        iconColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onSurface.withOpacity(0.38))
      )
    : ButtonStyle(
      // Solid background color
      backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.inversePrimary),
      iconColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary)
      ); 
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout( 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          BaseSearchBar(
            mainScaffoldKey: widget.mainScaffoldKey,
            hintText: 'Search for items...',
            trailing: [
              IconButton(
                onPressed: () {
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
                }, 
                icon: const Icon(Icons.post_add), 
                tooltip: "Request new item",
              ),
            ],
            onChanged: (value) {
              // Handle search input change
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
            },
            onSubmitted: (value) {
              // Handle search submission
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Searching for: $value')),
              );
            },
          ),
          // Google Map
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: AnimatedBuilder(
                animation: _pinAnimationController,
                builder: (context, child) {
                  return Stack(
                    children: [
                      child!,
                      // Pin Icon
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: Center(
                          child: Transform(
                            alignment: Alignment.bottomCenter,
                            transform: Matrix4.identity()
                              ..translate(_xAnimation.value, _yAnimation.value)
                              ..rotateZ(_rotationAnimation.value),
                            child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                          ),
                        ),
                      ),
                      // Pin Shadow
                      Transform.translate(
                        offset: const Offset(0, 4),
                        child: Opacity(
                          opacity: _shadowOpacity.value,
                          child: Center(
                            child: Transform.scale(
                              scale: _shadowScale.value,
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
                },
                child: MapWidget(
                  showMyLocationButton: true,
                  showZoomControls: true,
                  extraButtons: [
                    IconButton.filled(
                      style: _secondaryButtonStyle(context, translucentOnUnlock: false),
                      icon: Icon(_lockSearchArea ? Icons.lock : Icons.lock_open),
                      onPressed: () {
                        setState(() {
                          _lockSearchArea = !_lockSearchArea;
                          if (!_lockSearchArea) {
                            // Set search center to current map center
                            _searchLatLng = _cameraLatLng;
                          }
                        });
                      },
                      tooltip: _lockSearchArea ? 'Unlock Search Area' : 'Lock Search Area',
                    ),
                    IconButton.filled(
                      style: _secondaryButtonStyle(context),
                      onPressed: !_lockSearchArea ? null : () {
                        // If search area is getting unlocked, move search center to current map center
                        setState(() {
                          _searchLatLng = _cameraLatLng;
                        });
                      }, 
                      icon: const Icon(Icons.pin_drop_outlined),
                      tooltip: 'Move search area to current location',
                    ),
                    IconButton.filled(
                      style: _secondaryButtonStyle(context),
                      onPressed: !_lockSearchArea ? null : () => moveToSearchLocation(animate: true),
                      icon: const Icon(Icons.center_focus_strong_outlined),
                      tooltip: 'Move Map to Search Area',  
                    ),
                  ],
                  onLocationInitialized: (position) {
                    setState(() {
                      _cameraLatLng = position;
                      _searchLatLng = position;
                    });
                    moveToSearchLocation(animate: false);
                  },
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onCameraMoveStarted: () => _pinAnimationController.forward(),
                  onCameraIdle: () => _pinAnimationController.reverse(),
                  onCameraMove: (position)  {
                    _cameraLatLng = position.target;
                    if (!_lockSearchArea) {
                      setState(() => _searchLatLng = position.target);
                    }
                  },
                  circles: {
                    Circle(
                      circleId: const CircleId('search_range'),
                      center: _searchLatLng,
                      radius: _searchRangeKm * 1000, // Convert km to meters
                      fillColor: Colors.blue.withOpacity(0.1),
                      strokeColor: Colors.blueAccent,
                      strokeWidth: 2,
                    ),
                  },
                ),
              ),
            ),
          ),
          // Maximum Range Slider
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // If range is 0, show "Exact Location", else show range in km or m
                  Text('Search Range: ${_searchRangeKm == 0 ? 'Exact Location': _searchRangeKm >= 1 ? '${_searchRangeKm.round()} km' : '${(_searchRangeKm * 1000).round()} m'}'),
                  Slider(
                    value: _currentSliderValue,
                    min: 0.08,
                    max: 1,
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value;
                        // update zoom to match the new range (value in km -> meters)
                        final mapWidth = MediaQuery.of(context).size.width - 16;
                        _currentZoom = zoomLevelForRadius(_searchRangeKm * 1000, _cameraLatLng, mapWidth);
                      });

                      // animate the camera to the new zoom
                      if (_mapController != null) {
                        _mapController!.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(target: _cameraLatLng, zoom: _currentZoom),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pinAnimationController.dispose();
    super.dispose();
  }

  // Mixin getters and setters
  @override
  GoogleMapController? get mapController => _mapController;
  @override
  set mapController(GoogleMapController? value) => _mapController = value;

  @override
  LatLng get searchLatLng => _searchLatLng;
  @override
  set searchLatLng(LatLng value) => _searchLatLng = value;

  @override
  double get currentZoom => _currentZoom;
  @override
  set currentZoom(double value) => _currentZoom = value;

  @override
  double get searchRangeKm => _searchRangeKm;
  @override
  set searchRangeKm(double value) {
    _currentSliderValue = value;
  }
}