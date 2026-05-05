import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/components/choose_widget.dart';
import 'package:w2b_flutter/components/map/map_widget.dart';
import 'package:w2b_flutter/components/show_when.dart';
import 'package:w2b_flutter/components/widget_with_button.dart';
import 'package:w2b_flutter/components/pin_animation/pin_animation_widget.dart';
import 'package:w2b_flutter/core/network_results.dart';
import 'package:w2b_flutter/models/answer_model.dart';
import 'package:w2b_flutter/models/inquiry_model.dart';
import 'package:dio/dio.dart';
import 'package:w2b_flutter/util/api_util.dart';
import 'package:w2b_flutter/util/location_util.dart';

class AddResponsePage extends StatefulWidget {
  final NearbyInquiry inquiry;
  final Dio dio;

  const AddResponsePage(this.dio, {super.key, required this.inquiry});

  @override
  State<AddResponsePage> createState() => _AddResponsePageState();
}

class _AddResponsePageState extends State<AddResponsePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _pinAnimationController;
  late GoogleMapController _mapController;

  late final ExpansionTileController _mapExpansionTileController = ExpansionTileController();

  late LatLng _currentLatLng, _userLatLng;
  String _storeName = '';

  bool _isSubmitting = false; // Track whether the form is currently being submitted to prevent multiple submissions
  bool _isLoading = true;

  late final Inquiry _inquiry; // Store the inquiry details retrieved from the API, which may include additional information not included in the nearby inquiries response, such as the item name.

  late CameraPosition _cameraPosition;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Expand after the first frame is rendered to let users know that there is a collapsible map section
      _mapExpansionTileController.expand();
      
      final location = await LocationUtil.getCurrentLocation(maxMinutes: 0);
      _userLatLng = LatLng(location.latitude, location.longitude);

      await ApiUtil.safeApiCall(
        onTry: () async => await InquiryApiService(widget.dio).getInquiryById(widget.inquiry.id),
        onSuccess: (inquiry) {
          if (mounted) {
            setState(() => _inquiry = inquiry);
          }
        },
        onError: (e) {
          Navigator.pop(context); // Pop the page if there was an error retrieving the inquiry details, since we need that information to display the page properly
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error retrieving inquiry details: $e')),
          );
        },
        onDioError: (e) {
          Navigator.pop(context); // Pop the page if there was an error retrieving the inquiry details, since we need that information to display the page properly
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error retrieving inquiry details: ${e.message}')),
          );
        },
        onFinally: () {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        },
      );
      
    });
  }

  LatLngBounds _createBounds(LatLng center, double radiusMeters) {
    final double latDelta = radiusMeters / 111320; // Roughly convert meters to degrees latitude
    final double lngDelta = radiusMeters / (111320 * cos(center.latitude * pi / 180)); // Adjust longitude delta based on latitude

    return LatLngBounds(
      southwest: LatLng(center.latitude - latDelta, center.longitude - lngDelta),
      northeast: LatLng(center.latitude + latDelta, center.longitude + lngDelta),
    );
  } 

  /// Check if the current camera position is within the bounds of the inquiry's search radius, and if not, move it back to the center of the inquiry location. This is to prevent users from moving the camera too far away from the inquiry location and submitting a response with an inaccurate location.
  void _checkBounds(CameraPosition position) {
    LatLng currentTarget = position.target;

    LatLngBounds searchRadiusBounds = _createBounds(LatLng(_inquiry.latitude!, _inquiry.longitude!), _inquiry.searchRadiusMeters!.toDouble());
    if (!searchRadiusBounds.contains(currentTarget)) {
      // If the user moves the camera outside of the search radius bounds, move it back to the user's current location
      _mapController.animateCamera(CameraUpdate.newLatLng(_userLatLng));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Respond'),
      ),
      backgroundColor: Colors.grey[100],
      body: BaseLayout(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ShowWhen(
                    condition: false, // temporarily hide the image until we implement the functionality
                    ifTrue: (context) => InkWell(
                      onTap: () {
                        // TODO: Expand image to full screen view
                          
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Expand image to full screen view')),
                        );
                      },
                      child: Ink(
                        child: const Placeholder(fallbackHeight: 100, fallbackWidth: 100),
                      ),
                    ),
                  ),
                  const VerticalDivider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Item: ${widget.inquiry.itemName}'),
                    ],
                  ),
                ],
              ),
              const Divider(),
              ExpansionTile(
                controller: _mapExpansionTileController,
                expansionAnimationStyle: AnimationStyle(curve: Curves.fastEaseInToSlowEaseOut, duration: const Duration(milliseconds: 400)),
                collapsedBackgroundColor: Colors.purple[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: Colors.purple[200]!, width: 1),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: Colors.purple[200]!, width: 1),
                ),
                title: const Text('Location'),
                maintainState: true,
                children: [
                  SizedBox(
                    height: 300,
                    child: Choose(
                      condition: _isLoading,
                      ifTrue: (context) => const Center(child: CircularProgressIndicator()),
                      ifFalse: (context) => PinAnimationWidget(
                        onControllerInitialized: (pinAnimationController) => _pinAnimationController = pinAnimationController,
                        child: MapWidget(
                          showMyLocationIndicator: true,
                          showZoomControls: true,
                          onLocationInitialized: (position) {
                            _cameraPosition = CameraPosition(target: position, zoom: 14);
                            _userLatLng = position;
                            _currentLatLng = position;
                          },
                          onLocationRetrieved: (position) => _userLatLng = position,
                          onMapCreated: (mapController) => _mapController = mapController,
                          onCameraMoveStarted: () => _pinAnimationController.forward(),
                          onCameraMove: (position) {
                            _currentLatLng = position.target;
                            _cameraPosition = position;
                          },
                          onCameraIdle: () {
                            _pinAnimationController.reverse();
                            _checkBounds(_cameraPosition);
                          },
                          // Set bounds to 1500m from the user's current location
                          cameraTargetBounds: CameraTargetBounds(LatLngBounds(
                            southwest: LatLng(_userLatLng.latitude - 0.015, _userLatLng.longitude - 0.015),
                            northeast: LatLng(_userLatLng.latitude + 0.015, _userLatLng.longitude + 0.015),
                          )),
                          circles: {
                            Circle(
                              circleId: const CircleId('search_radius'),
                              center: LatLng(_inquiry.latitude!, _inquiry.longitude!),
                              radius: _inquiry.searchRadiusMeters!.toDouble(),
                              fillColor: Colors.purple.withOpacity(0.2),
                              strokeColor: Colors.purple.withOpacity(0.5),
                              strokeWidth: 2,
                            ),
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column (
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Visibility(
                      visible: false, // temporarily hide the add photo button until we implement the functionality
                      child: WidgetWithButton(
                        onPressed: () {
                          // TODO: Implement add photo functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Launch camera')),
                          );
                        }, 
                        buttonIcon: const Icon(Icons.add_a_photo),
                        child: const Placeholder(fallbackHeight: 200, fallbackWidth: 200),
                      ),
                    ),
                    TextFormField(
                      onChanged: (value) => _storeName = value,
                      decoration: const InputDecoration(
                        labelText: 'Store Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a store name' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isSubmitting = true;
                          });
                        
                          CreateAnswerRequest request = CreateAnswerRequest(
                            inquiryId: widget.inquiry.id,
                            storeName: _storeName,
                            latitude: _currentLatLng.latitude,
                            longitude: _currentLatLng.longitude,
                          );
                          
                          final result = await ApiUtil.safeApiCall(
                            onTry: () async => await AnswerApiService(widget.dio).createAnswer(data: await request.toFormData())
                          );
                        
                          switch (result) {
                            case Success(value: var answer):
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Response submitted successfully')),
                                );
                                setState(() {
                                  _isSubmitting = false;
                                  _storeName = '';
                                });
                                _mapController.animateCamera(CameraUpdate.newLatLng(_userLatLng)); // Move the map back to the user's current location after submission
                                // Navigator.pop(context, answer); // Pass the created answer back to the previous page
                              }
                            case Failure(errorMessage: var errorMessage):
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(errorMessage)),
                                );
                                setState(() {
                                  _isSubmitting = false;
                                });
                              }
                          }
                        } 
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}