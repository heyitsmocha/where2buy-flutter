import 'package:flutter/material.dart';

class NewInquiryForm extends StatelessWidget {
  final String? itemName, description;
  final Function(String value) onItemNameChanged, onDescriptionChanged;
  final Function()? onSubmit;
  
  const NewInquiryForm({
    super.key, 
    this.itemName, 
    this.description, 
    required this.onItemNameChanged, 
    required this.onDescriptionChanged,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        // Bottom padding based on viewInsets.bottom to raise the sheet when keyboard is open
        padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: MediaQuery.of(context).viewInsets.bottom + 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Item Request', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: itemName,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
              onChanged: onItemNameChanged,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: description,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: onDescriptionChanged,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onSubmit, 
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}