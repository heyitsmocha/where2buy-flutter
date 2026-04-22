import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:w2b_flutter/components/map/map_widget.dart';
import 'package:w2b_flutter/components/widget_with_button.dart';
import 'package:w2b_flutter/components/pin_animation/pin_animation_widget.dart';
import 'package:w2b_flutter/models/inquiry_model.dart';

class AddResponsePage extends StatefulWidget {
  final NearbyInquiry inquiry;

  const AddResponsePage({super.key, required this.inquiry});

  @override
  State<AddResponsePage> createState() => _AddResponsePageState();
}

class _AddResponsePageState extends State<AddResponsePage> {
  late AnimationController _pinAnimationController;
  late GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Respond'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
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
                  const VerticalDivider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Item:'),
                      Text(widget.inquiry.itemName),
                    ],
                  ),
                ],
              ),
              const Divider(),
              SizedBox(
                height: 300,
                child: PinAnimationWidget(
                  onControllerInitialized: (pinAnimationController) => _pinAnimationController = pinAnimationController,
                  child: MapWidget(
                    onMapCreated: (mapController) => _mapController = mapController,
                    onCameraMoveStarted: () => _pinAnimationController.forward(),
                    onCameraIdle: () => _pinAnimationController.reverse(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              WidgetWithButton(
                onPressed: () {
                  // TODO: Implement add photo functionality


                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Launch camera')),
                  );
                }, 
                buttonIcon: const Icon(Icons.add_a_photo),
                child: const Placeholder(fallbackHeight: 200, fallbackWidth: 200),
              ),
              const Text('Respond Page'),
              const Text('Respond Page'),
              const Text('Respond Page'),
            ],
          ),
        ),
      ),
    );
  }
}