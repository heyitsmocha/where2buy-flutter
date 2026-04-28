import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:w2b_flutter/components/map/map_secondary_button.dart';
import 'package:w2b_flutter/components/map/map_widget_mixin.dart';

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

  /// List of extra buttons that'll be displayed in a column horizontally next to the base buttons.
  final List<MapSecondaryButton> extraButtons;

  /// Callback for when the user's location is first initialized. This will only be called once when the location is first retrieved, and will not be called again if the location is updated later. This is useful for setting the initial camera position of the map to the user's location.
  final void Function(LatLng position)? onLocationInitialized;
  final void Function(GoogleMapController)? onMapCreated;
  final void Function()? onCameraMoveStarted;
  final void Function()? onCameraIdle;
  final void Function(CameraPosition)? onCameraMove;

  @override
  State<StatefulWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with MapWidgetMixin {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Loading indicator or Google Map
        isInitializing
          ? const Row(
            children: [
              Expanded(child: Center(child: CircularProgressIndicator())),
            ])
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentCameraPosition.target,
                zoom: currentCameraPosition.zoom,
              ),
              onMapCreated: handleMapCreated,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onCameraMoveStarted: () {
                widget.onCameraMoveStarted?.call();
              },
              onCameraMove: handleCameraMove,
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
            if(enabledBaseButtons.isNotEmpty) 
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: enabledBaseButtons,
              ),
          ],
        ),
      ],
    );
  }
}