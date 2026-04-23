import 'package:flutter/material.dart';
import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/models/inquiry_model.dart';

class InquiryResponsesPage extends StatelessWidget {
  final Inquiry inquiry;

  const InquiryResponsesPage({super.key, required this.inquiry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inquiry Responses'),
      ),
      body: BaseLayout(
        child: Column(
          children: [
            Text('Display responses for inquiry ID: ${inquiry.id}'),
            const Placeholder(fallbackHeight: 300, fallbackWidth: double.infinity), // Map
            const SizedBox(height: 16),
            const Expanded(
              child: SingleChildScrollView( // List of responses
                child: Placeholder(fallbackHeight: 400, fallbackWidth: double.infinity)
              )
            ), 
          ],
        ),
      ),
    );
  }
}