import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/components/map/map_widget.dart';
import 'package:w2b_flutter/components/widget_with_button.dart';
import 'package:w2b_flutter/components/pin_animation/pin_animation_widget.dart';
import 'package:w2b_flutter/core/network_results.dart';
import 'package:w2b_flutter/models/answer_model.dart';
import 'package:w2b_flutter/models/inquiry_model.dart';
import 'package:dio/dio.dart';
import 'package:w2b_flutter/util/api_util.dart';

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
  late ExpansionTileController _mapExpansionTileController = ExpansionTileController();

  late LatLng _currentLatLng;
  String _storeName = '';

  bool _isSubmitting = false; // Track whether the form is currently being submitted to prevent multiple submissions

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Expand after the first frame is rendered to let users know that there is a collapsible map section
      _mapExpansionTileController.expand();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Respond'),
      ),
      body: BaseLayout(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Visibility(
                  visible: false, // temporarily hide the image until we implement the functionality
                  child: InkWell(
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
              title: const Text('Location'),
              maintainState: true,
              children: [
                SizedBox(
                  height: 300,
                  child: PinAnimationWidget(
                    onControllerInitialized: (pinAnimationController) => _pinAnimationController = pinAnimationController,
                    child: MapWidget(
                      showMyLocationIndicator: true,
                      showZoomControls: true,
                      onLocationInitialized: (position) => _currentLatLng = position,
                      onMapCreated: (mapController) => _mapController = mapController,
                      onCameraMoveStarted: () => _pinAnimationController.forward(),
                      onCameraIdle: () => _pinAnimationController.reverse(),
                      onCameraMove: (position) => _currentLatLng = position.target,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column (
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
                                  // Navigator.pop(context, answer); // Pass the created answer back to the previous page
                                }
                              case Failure(errorMessage: var errorMessage):
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(errorMessage)),
                                  );
                                }
                            }

                            setState(() {
                              _isSubmitting = false;
                            });
                          } 
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}