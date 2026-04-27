import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/components/map/map_widget.dart';
import 'package:w2b_flutter/core/network_results.dart';
import 'package:w2b_flutter/models/answer_model.dart';
import 'package:w2b_flutter/models/inquiry_model.dart';
import 'package:dio/dio.dart';
import 'package:w2b_flutter/util/api_util.dart';

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
      Result<List<Answer>> response = await ApiUtil.safeApiCall(onTry: () async => await InquiryApiService(widget.dio).getAnswersForInquiry(widget.inquiry.id));

      switch (response) {
        case Success():

          setState(() {
            // Update the answers list with the data from the API response
            answers = response.value;
            
            // For each answer, add a marker to the map at the location of the store
            answers.map((answer) => Marker(
              markerId: MarkerId(answer.id.toString()),
              position: LatLng(answer.latitude, answer.longitude),
              infoWindow: InfoWindow(title: answer.storeName, snippet: answer.storeAddress ?? ''),
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
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inquiry Responses'),
      ),
      body: BaseLayout(
        child: Column(
          children: [
            Text('Display responses for inquiry ID: ${widget.inquiry.id}'),
            SizedBox(
              height: 300,
              child: MapWidget(
                markers: markers,
                circles: circles,
                onMapCreated: (mapController) => _mapController = mapController,
                showZoomControls: true,
              ),
            ), // Map
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: answers.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final answer = answers[index];
                  return ListTile(
                    title: Text(answer.storeName),
                    onTap: () => _mapController.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(answer.latitude, answer.longitude),
                          15,
                        ),
                      ),
                  );
                },
              ),
            ), 
          ],
        ),
      ),
    );
  }
}