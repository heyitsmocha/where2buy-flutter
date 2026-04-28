import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/components/map/map_secondary_button.dart';
import 'package:w2b_flutter/components/map/map_widget.dart';
import 'package:w2b_flutter/core/network_results.dart';
import 'package:w2b_flutter/models/answer_model.dart';
import 'package:w2b_flutter/models/inquiry_model.dart';
import 'package:dio/dio.dart';
import 'package:w2b_flutter/util/api_util.dart';
import 'package:w2b_flutter/util/location_util.dart';

class InquiryResponsesPage extends StatefulWidget {
  final Inquiry inquiry;
  final Dio dio;

  const InquiryResponsesPage(this.dio, {super.key, required this.inquiry});

  @override
  State<InquiryResponsesPage> createState() => _InquiryResponsesPageState();
}

class _InquiryResponsesPageState extends State<InquiryResponsesPage> {
  List<Answer> answers = [];
  Set<Circle> circles = {};
  Set<Marker> markers = {};

  late GoogleMapController _mapController;

  bool _isLoading = true;

  bool _isCameraMovedProgrammatically = false; // Flag to track whether the camera is being moved programmatically
  int? _currentlyViewingStoreIndex;
  
  @override
  void initState() {
    // Add a circle to the map to represent the search radius of the inquiry
    circles.add(
      Circle(
        circleId: CircleId(widget.inquiry.id.toString()),
        center: LatLng(widget.inquiry.latitude!, widget.inquiry.longitude!),
        radius: widget.inquiry.searchRadiusMeters!.toDouble(),
        fillColor: Colors.blue.withOpacity(0.2),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ),
    );


    WidgetsBinding.instance.addPostFrameCallback((_) async { 
      await refresh();
    });

    super.initState();
  }

  Future<void> refresh() async {
    Result<List<Answer>> response = await ApiUtil.safeApiCall(
      onTry: () async {
        if (mounted) {
          setState(() {
            _isLoading = true;
          });
        }

        return await InquiryApiService(widget.dio).getAnswersForInquiry(widget.inquiry.id);
      },
      onFinally: () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
    
    switch (response) {
      case Success():
        setState(() {
          // Update the answers list with the data from the API response
          answers = response.value;
          
          // For each answer, add a marker to the map at the location of the store
          answers.map((answer) => Marker(
            markerId: MarkerId(answer.id.toString()),
            position: LatLng(answer.latitude, answer.longitude),
            infoWindow: InfoWindow(title: answer.storeName, snippet: answer.storeAddress),
            onTap: () {
              // When a marker is tapped, find the corresponding answer in the list and set the currently viewing store index to show the eye icon in the ListTile
              int index = answers.indexOf(answer);
              _centerCameraToMarker(index, answer);
            }
          )).forEach((marker) => markers.add(marker));
        });
        break;
      case Failure():
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load responses. Please try again later.')),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inquiry Responses'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : refresh,
        child: const Icon(Icons.refresh),
      ),
      body: BaseLayout(
        child: Column(
          children: [
            Text('Display responses for inquiry ID: ${widget.inquiry.id}'),
            SizedBox(
              height: 300,
              child: MapWidget(
                showMyLocationIndicator: true,
                showZoomControls: true,
                markers: markers,
                circles: circles,
                extraButtons: [
                  MapSecondaryButton(
                    tooltip: 'Center on Inquiry Location',
                    icon: const Icon(Icons.center_focus_strong_outlined),
                    onPressed: () {
                      _mapController.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(widget.inquiry.latitude!, widget.inquiry.longitude!),
                          LocationUtil.getZoomLevelForRadius(
                            widget.inquiry.searchRadiusMeters!.toDouble(), 
                            LatLng(widget.inquiry.latitude!, widget.inquiry.longitude!),
                            MediaQuery.of(context).size.width,
                          )
                        ),
                      );
                    },
                  ),
                ],
                onMapCreated: (mapController) {
                  _mapController = mapController;

                  // Move camera to the location of the inquiry
                  _mapController.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(widget.inquiry.latitude!, widget.inquiry.longitude!),
                      LocationUtil.getZoomLevelForRadius(
                        widget.inquiry.searchRadiusMeters!.toDouble(), 
                        LatLng(widget.inquiry.latitude!, widget.inquiry.longitude!),
                        MediaQuery.of(context).size.width,
                      )
                    ),
                  );
                },
                onCameraMoveStarted: () {
                  // If the camera move was not triggered by tapping on an answer in the list, reset the index to remove the eye icon in the ListTile
                  if (!_isCameraMovedProgrammatically && _currentlyViewingStoreIndex != null) {
                    setState(() {
                      _currentlyViewingStoreIndex = null;
                    });
                  }
                },
                onCameraIdle: () => _isCameraMovedProgrammatically = false, // Reset the flag when the camera stops moving
              ),
            ), // Map
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : answers.isEmpty 
                  ? const Text('No responses have been made.',)
                  : ListView.separated(
                      itemCount: answers.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final answer = answers[index];
                        return ListTile(
                          title: Text(answer.storeName),
                          trailing: _currentlyViewingStoreIndex == index ? const Icon(Icons.visibility) : null,
                          onTap: () => _centerCameraToMarker(index, answer),
                        );
                      },
                    ),
            ), 
          ],
        ),
      ),
    );
  }

  void _centerCameraToMarker(int index, Answer answer) {
    setState(() {
      _currentlyViewingStoreIndex = index;
      _isCameraMovedProgrammatically = true;
    });
    _mapController.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(answer.latitude, answer.longitude),
      ),
    );
  }
}