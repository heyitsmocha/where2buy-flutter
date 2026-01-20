import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/components/base_search_bar.dart';
import 'package:w2b_flutter/features/search/logic/search_page_logic.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.mainScaffoldKey});

  final GlobalKey<ScaffoldState> mainScaffoldKey;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SearchPageLogic {
  double _currentSliderValue = 5;
  double _currentZoom = 12;

  final bool _isLoggedIn = false; // Placeholder for user authentication status
  late LatLng _currentLatLng = const LatLng(3.157445974699537, 101.71153740166021); // Default to KL Twin Towers
  late LatLng _tempLatLng = _currentLatLng;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();

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

  // Move or animate the map camera to the current location when possible.
  // Safe to call from either `initState` (after location) or `onMapCreated`.
  void _moveToCurrentLocation({bool animate = true}) {
    if (!mounted) return;
    if (_mapController == null) return;

    final mapWidth = MediaQuery.of(context).size.width - 16; // approximate padding
    final zoom = zoomLevelForRadius(_currentSliderValue * 1000, _currentLatLng, mapWidth);

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
              child: GoogleMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                  // Position the camera now that the controller exists
                  _moveToCurrentLocation();
                },
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                onCameraMove: (position) => setState(() {
                  _tempLatLng = position.target;
                }),
                onCameraIdle: () => setState(() {
                  _currentLatLng = _tempLatLng;
                }),
                markers: {
                  Marker(
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                    markerId: const MarkerId('current_location'),
                    position: _tempLatLng,
                    infoWindow: const InfoWindow(title: 'Search Location'),
                  ),
                },
                circles: {
                  Circle(
                    circleId: const CircleId('search_range'),
                    center: _currentLatLng,
                    radius: _currentSliderValue * 1000, // Convert km to meters
                    fillColor: Colors.blue.withOpacity(0.1),
                    strokeColor: Colors.blueAccent,
                    strokeWidth: 2,
                  ),
                },
                initialCameraPosition: CameraPosition(
                  target: _currentLatLng, 
                  zoom: _currentZoom,
                ),
              )
            ),
          ),
          // Maximum Range Slider here
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text('Search Range: ${_currentSliderValue > 0 ? '${_currentSliderValue.round()} km' : 'Exact Location'}'),
                  Slider(
                    value: _currentSliderValue,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value;
                        // update zoom to match the new range (value in km -> meters)
                        final mapWidth = MediaQuery.of(context).size.width - 16;
                        _currentZoom = zoomLevelForRadius(value * 1000, _currentLatLng, mapWidth);
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
}