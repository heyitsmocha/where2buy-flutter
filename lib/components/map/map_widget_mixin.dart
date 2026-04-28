import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:w2b_flutter/components/map/map_widget.dart';
import 'package:w2b_flutter/util/location_util.dart';

mixin MapWidgetMixin on State<MapWidget> {
  bool 
    _isInitializing = true,
    _isLoading = true;
  bool get isInitializing => _isInitializing;
  bool get isLoading => _isLoading;

  late CameraPosition _currentCameraPosition;
  CameraPosition get currentCameraPosition => _currentCameraPosition;

  final List<Widget> _enabledBaseButtons = [];
  List<Widget> get enabledBaseButtons {
    _enabledBaseButtons.clear();
    // Configure enabled buttons
    if (widget.showZoomControls) {
      _enabledBaseButtons.addAll(
        [
          IconButton.filled(
            tooltip: 'Zoom In',
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              setState(() => _currentCameraPosition = CameraPosition(target: _currentCameraPosition.target, zoom: _currentCameraPosition.zoom+1));
              _moveCameraToLatestPosition();
            } 
          ),
          IconButton.filled(
            tooltip: 'Zoom Out',
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              setState(() => _currentCameraPosition = CameraPosition(target: _currentCameraPosition.target, zoom: _currentCameraPosition.zoom-1));
              _moveCameraToLatestPosition();
            } 
          ),
        ]
      );
    } 
    if (widget.showMyLocationButton) {
      _enabledBaseButtons.add(
        IconButton.filled(
          tooltip: 'My Location',
          icon: _isLoading ? const SizedBox(width:24, height:24, child: CircularProgressIndicator(strokeWidth:2.5)) : const Icon(Icons.my_location),
          onPressed: _isLoading 
            ? null 
            : () => _getCurrentLocation()
              .then((location) {
                setState(() {
                  _currentCameraPosition = CameraPosition(
                    target: location,
                    zoom: _currentCameraPosition.zoom,
                  );
                });
              })
              .whenComplete(() => 
                _moveCameraToLatestPosition()
              ),
        )
      );
    }
    return _enabledBaseButtons;
  }

  GoogleMapController? _mapController;
  GoogleMapController? get mapController => _mapController;

  @override
  void initState() {
    super.initState();

    // Get the current location and initialize camera position
    _getCurrentLocation()
      .then((location) {
          _currentCameraPosition = CameraPosition(
            target: location,
            zoom: 15,
          );
        _moveCameraToLatestPosition();
      }
    );
  }

  Future<void> handleMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    widget.onMapCreated?.call(controller);
  }

  Future<void> handleCameraMove(CameraPosition position) async {
    _currentCameraPosition = position;
    widget.onCameraMove?.call(position);
  }

  /// Get the current location of the user
  Future<LatLng> _getCurrentLocation() async {
    if (!mounted) return Future.value(const LatLng(0,0));
    // Trigger UI rebuild to disable the My Location button
    setState(() => _isLoading = true);
    
    try {
      Position position = await LocationUtil.getCurrentLocation();
      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      if (isInitializing) {
        widget.onLocationInitialized?.call(currentLocation);
      }
    
      return currentLocation;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      return Future.value(const LatLng(0,0));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitializing = false;
        });     
      }
    }
  }

  /// Animate the camera to the current LatLng and zoom level
  void _moveCameraToLatestPosition() {
    // Animate the camera to the new position
    if (mounted) {
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          currentCameraPosition,
        ),
      );
    }
  }
}