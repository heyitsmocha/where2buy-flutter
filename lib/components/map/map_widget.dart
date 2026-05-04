import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:w2b_flutter/components/choose_widget.dart';
import 'package:w2b_flutter/components/map/map_secondary_button.dart';
import 'package:w2b_flutter/components/map/map_widget_mixin.dart';
import 'package:w2b_flutter/components/show_when.dart';

class MapWidget extends StatefulWidget{
  const MapWidget(
    {super.key, 
    this.showZoomControls = false, 
    this.showMyLocationButton = true, 
    this.showMyLocationIndicator = false,
    this.extraButtons = const [],
    this.circles = const {},
    this.markers = const {},
    this.onLocationInitialized,
    this.onLocationRetrieved,
    this.onMapCreated,
    this.onCameraMoveStarted,
    this.onCameraIdle,
    this.onCameraMove,
    this.mapOverlayLayer,
  });

  final bool
    showZoomControls,
    showMyLocationButton,
    showMyLocationIndicator;

  /// An optional widget that will be displayed on top of the map but below the buttons. This can be used to display things like a search radius circle or other map overlays. 
  final Widget? mapOverlayLayer;

  final Set<Circle> circles;
  final Set<Marker> markers;

  /// List of extra buttons that'll be displayed in a column horizontally next to the base buttons.
  final List<MapSecondaryButton> extraButtons;

  /// Callback for when the user's location is first initialized. This will only be called once when the location is first retrieved, and will not be called again if the location is updated later. This is useful for setting the initial camera position of the map to the user's location.
  final void Function(LatLng position)? onLocationInitialized;
  /// Callback for when the user's location is retrieved. This will be called every time the location is updated.
  final void Function(LatLng position)? onLocationRetrieved;
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
    return Card( // For the shadow
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ClipRRect( // To round the borders, since Container with BoxDecoration doesn't work with GoogleMap for some reason
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          children: [
            // Loading indicator or Google Map
            Choose(
              condition: isInitializing, 
              ifTrue: (context) => const Center(child: CircularProgressIndicator()), 
              ifFalse: (context) => GoogleMap(
                mapToolbarEnabled: false, // Disable the default Google Maps toolbar that appears when tapping on a marker. 
                myLocationEnabled: widget.showMyLocationIndicator,
                initialCameraPosition: CameraPosition(
                  target: currentCameraPosition.target,
                  zoom: currentCameraPosition.zoom,
                ),
                onMapCreated: handleMapCreated,
                myLocationButtonEnabled: false, // Disable the default My Location button since we have a custom one
                zoomControlsEnabled: false, // Disable default zoom controls since we have custom ones
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
            ),
            ShowWhen(
              condition: widget.mapOverlayLayer != null, 
              ifTrue: (context) => widget.mapOverlayLayer!
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
        ),
      ),
    );
  }
}