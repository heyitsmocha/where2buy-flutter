import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/components/base_search_bar.dart';
import 'package:w2b_flutter/features/search/logic/search_page_logic.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.mainScaffoldKey});

  final GlobalKey<ScaffoldState> mainScaffoldKey;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SearchPageLogic, SingleTickerProviderStateMixin {
  final bool _isLoggedIn = false; // Placeholder for user authentication status

  // Slider and range variables
  double _currentSliderValue = 0;
  final double _maxRangeKm = 80;

  // Calculate the actual range to make the slider exponential (smaller ranges at the start, larger ranges at the end)
  double get _actualRangeKm => _maxRangeKm * math.pow(_currentSliderValue, 2);

  // Map variables
  double _currentZoom = 12;
  LatLng _currentLatLng = const LatLng(3.157445974699537, 101.71153740166021); // Default to KL Twin Towers
  GoogleMapController? _mapController;

  // Animation variables
  late AnimationController _pinAnimationController;
  late Animation<double> 
    _xAnimation,
    _yAnimation,
    _rotationAnimation,
    _shadowOpacity,
    _shadowScale;

  // Move or animate the map camera to the current location when possible.
  // Safe to call from either `initState` (after location) or `onMapCreated`.
  void _moveToCurrentLocation({bool animate = true}) {
    if (!mounted) return;
    if (_mapController == null) return;

    final mapWidth = MediaQuery.of(context).size.width - 16; // approximate padding
    final zoom = zoomLevelForRadius(_actualRangeKm * 1000, _currentLatLng, mapWidth);

    setState(() => _currentZoom = zoom);

    final cameraUpdate = CameraUpdate.newCameraPosition(
      CameraPosition(target: _currentLatLng, zoom: _currentZoom),
    );

    if (animate) {
      _mapController!.animateCamera(cameraUpdate);
    } else {
      _mapController!.moveCamera(cameraUpdate);
    }
  }

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
    getCurrentLocation().then((position) {
      log('Current location: ${position.latitude}, ${position.longitude}');
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
      });

      // Try to move/animate the map to the user's location if controller exists
      _moveToCurrentLocation(animate: false);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: my location FloatingActionButton
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
                      const SnackBar(content: Text('Please log in to post a new item request.')),
                    );
                  }
                }, 
                icon: const Icon(Icons.post_add), 
                tooltip: "Request new item",
              ),
            ],
            onChanged: (value) {
              // Handle search input change
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
          // Google Map here
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
                child: GoogleMap(
                  myLocationButtonEnabled: true,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    // Position the camera now that the controller exists
                    _moveToCurrentLocation();
                  },
                  onCameraMoveStarted: () => _pinAnimationController.forward(),
                  onCameraIdle: () => _pinAnimationController.reverse(),
                  onCameraMove: (position) => setState(() => _currentLatLng = position.target),
                  initialCameraPosition: CameraPosition(
                    target: _currentLatLng, 
                    zoom: _currentZoom,
                  ),
                  circles: {
                    Circle(
                      circleId: const CircleId('search_range'),
                      center: _currentLatLng,
                      radius: _actualRangeKm * 1000, // Convert km to meters
                      fillColor: Colors.blue.withOpacity(0.1),
                      strokeColor: Colors.blueAccent,
                      strokeWidth: 2,
                    ),
                  },
                ),
              ),
            ),
          ),
          // Maximum Range Slider here
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // If range is 0, show "Exact Location", else show range in km or m
                  Text('Search Range: ${_actualRangeKm == 0 ? 'Exact Location': _actualRangeKm >= 1 ? '${_actualRangeKm.round()} km' : '${(_actualRangeKm * 1000).round()} m'}'),
                  Slider(
                    value: _currentSliderValue,
                    min: 0,
                    max: 1,
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value;
                        // update zoom to match the new range (value in km -> meters)
                        final mapWidth = MediaQuery.of(context).size.width - 16;
                        _currentZoom = zoomLevelForRadius(_actualRangeKm * 1000, _currentLatLng, mapWidth);
                      });

                      // animate the camera to the new zoom
                      if (_mapController != null) {
                        _mapController!.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(target: _currentLatLng, zoom: _currentZoom),
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
}