import 'package:flutter/material.dart';
import 'package:w2b_flutter/components/search_range_slider.dart';
import 'package:w2b_flutter/models/item_model.dart';

class NewInquiryForm extends StatefulWidget {
  final ItemSearchSuggestion? item;
  final String? itemName, description;
  final Function(String value)? onItemNameChanged, onDescriptionChanged;
  final Function()? onSubmit;

  final Listenable listenable;
  final double Function() sliderValue;
  final Function(double) onSliderChanged;
  final String Function() searchRadiusText;

  
  const NewInquiryForm({
    super.key, 
    this.item,
    this.itemName, 
    this.description, 
    this.onItemNameChanged, 
    this.onDescriptionChanged,
    this.onSubmit,

    // Search range slider parameters
    required this.listenable,
    required this.sliderValue,
    required this.onSliderChanged,
    required this.searchRadiusText,
  });
  
  @override
  State<NewInquiryForm> createState() => _NewInquiryFormState();
}

class _NewInquiryFormState extends State<NewInquiryForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        // Bottom padding based on viewInsets.bottom to raise the sheet when keyboard is open
        padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: MediaQuery.of(context).viewInsets.bottom + 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('New Item Request', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                textInputAction: TextInputAction.next,
                initialValue: widget.itemName,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: widget.onItemNameChanged,
                validator: (value) => value == null || value.isEmpty ? 'Please enter an item name' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                textInputAction: TextInputAction.done,
                initialValue: widget.description,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: widget.onDescriptionChanged,
              ),
              const SizedBox(height: 8),
              SearchRangeSlider(
                listenable: widget.listenable,
                sliderValue: widget.sliderValue, 
                searchRadiusText: widget.searchRadiusText,
                onSliderChanged: widget.onSliderChanged 
              ),
              // Image upload button
              // Center(
              //   child: ElevatedButton.icon(
              //     onPressed: () {
                    
              //     }, 
              //     icon: const Icon(Icons.upload), label: const Text('Upload Image (Optional)'),
              //   ),
              // ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    widget.onSubmit?.call();
                  }
                },
                child: const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}