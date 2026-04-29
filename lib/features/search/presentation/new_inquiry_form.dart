import 'package:flutter/material.dart';
import 'package:w2b_flutter/components/choose_widget.dart';
import 'package:w2b_flutter/components/search/search_view.dart';
import 'package:w2b_flutter/components/search_range_slider.dart';

class NewInquiryForm extends StatefulWidget {
  final SearchResultType? item;
  final String? itemName, description;
  final Function(String value)? onItemNameChanged, onDescriptionChanged;
  final Function()? onSubmit;

  final Listenable listenable;
  final double Function() sliderValue;
  final Function(double) onSliderChanged;
  final Function(double) onSliderChangeEnd;
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
    required this.onSliderChangeEnd,
    required this.searchRadiusText,
  });
  
  @override
  State<NewInquiryForm> createState() => _NewInquiryFormState();
}

class _NewInquiryFormState extends State<NewInquiryForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // const Text('New Item Request', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          // const SizedBox(height: 8),
          Choose(
            condition: widget.item == null,
            ifTrue: (context) => TextFormField(
              readOnly: widget.item != null, // Make read-only if an item is selected from suggestions
              style: widget.item != null ? const TextStyle(color: Colors.grey) : null, // Grey out text if read-only
              textInputAction: TextInputAction.next,
              initialValue: widget.item?.modelName ?? widget.itemName,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
              onChanged: widget.onItemNameChanged,
              validator: (value) => value == null || value.isEmpty ? 'Please enter an item name' : null,
            ),
            ifFalse: (context) => Text(widget.item!.modelName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 8),
          Visibility(
            visible: widget.item == null, // Only show description field if no item is selected (i.e. user is typing in a custom item rather than selecting a suggestion)
            child: TextFormField(
              textInputAction: TextInputAction.done,
              initialValue: widget.description,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: widget.onDescriptionChanged,
            ),
          ),
          const SizedBox(height: 8),
          SearchRangeSlider(
            listenable: widget.listenable,
            sliderValue: widget.sliderValue, 
            searchRadiusText: widget.searchRadiusText,
            onSliderChanged: widget.onSliderChanged,
            onSliderChangeEnd: widget.onSliderChangeEnd,
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
    );
  }
}