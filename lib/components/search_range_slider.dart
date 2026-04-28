
import 'package:flutter/material.dart';

class SearchRangeSlider extends StatelessWidget {
  const SearchRangeSlider({
    super.key,
    required this.listenable,
    required this.sliderValue,
    required this.onSliderChanged,
    this.onSliderChangeEnd,
    required this.searchRadiusText,
  });

  /// A Listenable (e.g. ValueNotifier, BaseController) that triggers a rebuild of the slider when its value changes. This is used to update the slider position and displayed range text when the search range is changed from other parts of the UI (e.g. map interactions).
  final Listenable listenable;

  /// Callback instead of direct double value to ensure the latest value is always used when the slider is built
  final double Function() sliderValue;

  /// Callback instead of direct String value to ensure the latest value is always used when the slider is built
  final String Function() searchRadiusText;

  final Function(double) onSliderChanged;
  final Function(double)? onSliderChangeEnd;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) => Column(
        children: [
          // If range is 0, show "Exact Location", else show range in km or m
          Text('Search Radius: ${searchRadiusText()}'),
          Slider(
            value: sliderValue(),
            min: 0.08,
            max: 1,
            onChanged: onSliderChanged,
            onChangeEnd: onSliderChangeEnd,
          ),
        ],
      ),
    );
  }
}