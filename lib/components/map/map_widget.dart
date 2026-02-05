import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:w2b_flutter/components/map/map_widget_mixin.dart';
import 'package:w2b_flutter/main.dart';

class MapWidget extends StatefulWidget{
  const MapWidget(
    {super.key, 
    this.showZoomControls = false, 
    this.showMyLocationButton = 
    true, this.extraButtons = const [],
    this.circles = const {},
    this.markers = const {},
    this.onLocationInitialized,
    this.onMapCreated,
    this.onCameraMoveStarted,
    this.onCameraIdle,
    this.onCameraMove
  });

  final bool
    showZoomControls,
    showMyLocationButton;

  final Set<Circle> circles;
  final Set<Marker> markers;

  final List<Widget> extraButtons;

  final Function(LatLng position)? onLocationInitialized;
  final Function(GoogleMapController)? onMapCreated;
  final Function()? onCameraMoveStarted;
  final Function()? onCameraIdle;
  final Function(CameraPosition)? onCameraMove;

  @override
  State<StatefulWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with MapWidgetMixin {
  bool 
    _isInitializing = true,
    _isLoading = true;
  late CameraPosition _currentCameraPosition;
  GoogleMapController? _mapController;

  final List<Widget> _enabledBaseButtons = [];

  @override
  void initState() {
    super.initState();

    // Get the current location and initialize camera position
    getCurrentLocation(onLocationInitialized: widget.onLocationInitialized)
      .then((location) {
        _currentCameraPosition = CameraPosition(
          target: location,
          zoom: 15,
        );
        moveCameraToLatestPosition();
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    _enabledBaseButtons.clear();
    // Configure enabled buttons
    if (widget.showZoomControls) {
      _enabledBaseButtons.addAll(
        [
          IconButton.filled(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              setState(() => _currentCameraPosition = CameraPosition(target: _currentCameraPosition.target, zoom: _currentCameraPosition.zoom+1));
              moveCameraToLatestPosition();
            } 
          ),
          IconButton.filled(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              setState(() => _currentCameraPosition = CameraPosition(target: _currentCameraPosition.target, zoom: _currentCameraPosition.zoom-1));
              moveCameraToLatestPosition();
            } 
          ),
        ]
      );
    } 
    if (widget.showMyLocationButton) {
      _enabledBaseButtons.add(
        IconButton.filled(
          icon: _isLoading ? const SizedBox(width:24, height:24, child: CircularProgressIndicator(strokeWidth:2.5)) : const Icon(Icons.my_location),
          onPressed: _isLoading 
            ? null 
            : () => getCurrentLocation()
              .then((location) {
                setState(() {
                  _currentCameraPosition = CameraPosition(
                    target: location,
                    zoom: _currentCameraPosition.zoom,
                  );
                });
              })
              .whenComplete(() => 
                moveCameraToLatestPosition()
              ),
        )
      );
    }
    return Stack(
      children: [
        // Loading indicator or Google Map
        _isInitializing
          ? const Row(
            children: [
              Expanded(child: Center(child: CircularProgressIndicator())),
            ])
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentCameraPosition.target,
                zoom: _currentCameraPosition.zoom,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                widget.onMapCreated?.call(controller);
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onCameraMoveStarted: () {
                widget.onCameraMoveStarted?.call();
              },
              onCameraMove: (position) {
                _currentCameraPosition = position; 
                widget.onCameraMove?.call(position);
              },
              onCameraIdle: () {
                widget.onCameraIdle?.call();
              },
              circles: widget.circles,
              markers: widget.markers,
            ),
        // Buttons on top of the map
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if(widget.extraButtons.isNotEmpty) 
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: widget.extraButtons.reversed.toList(),
              ),
            if(_enabledBaseButtons.isNotEmpty) 
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: _enabledBaseButtons,
              ),
          ],
        ),
      ],
    );
  }
  
  // Mixin getters and setters
  @override
  CameraPosition get currentCameraPosition => _currentCameraPosition;
  @override
  set currentCameraPosition(CameraPosition value) => _currentCameraPosition = value;

  @override
  bool get isInitializing => _isInitializing;
  @override
  set isInitializing(bool value) => _isInitializing = value;

  @override
  bool get isLoading => _isLoading;
  @override
  set isLoading(bool value) => _isLoading = value;

  @override
  GoogleMapController? get mapController => _mapController;
  @override
  set mapController(GoogleMapController? value) => _mapController = value;
}