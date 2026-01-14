import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:w2b_flutter/components/widget_with_button.dart';

class RespondPage extends StatefulWidget {
  const RespondPage({super.key});

  @override
  State<RespondPage> createState() => _RespondPageState();
}

class _RespondPageState extends State<RespondPage> {
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Item:'),
                      Text('Item name here'),
                    ],
                  ),
                ],
              ),
              const Divider(),
              WidgetWithButton(
                onPressed: () {
                  // TODO: Tell google maps to move the map to the user's current location

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Move map to current location')),
                  );
                }, buttonIcon: const Icon(Icons.my_location),
                child: const Placeholder(fallbackHeight: 300, fallbackWidth: double.infinity), 
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