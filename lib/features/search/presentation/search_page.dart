import 'package:flutter/material.dart';
import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/components/base_search_bar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.mainScaffoldKey});

  final GlobalKey<ScaffoldState> mainScaffoldKey;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  double _currentSliderValue = 20;
  bool _isLoggedIn = false; // Placeholder for user authentication status

  @override
  Widget build(BuildContext context) {
    return BaseLayout( 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          BaseSearchBar(
            mainScaffoldKey: widget.mainScaffoldKey,
            hintText: 'Search for items...',
            trailing: [
              IconButton(
                onPressed: () {
                  if (_isLoggedIn) {
                    // Navigate to request new item page
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Navigating to Request New Item Page...')),
                    );
                  } else {
                    // Prompt user to log in
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please log in to post a new item request.')),
                    );
                  }
                }, 
                icon: const Icon(Icons.post_add), 
                tooltip: "Request new item",
                ),
            ],
            onChanged: (value) {
              // Handle search input change
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Display suggestions for: $value'),
                  //dismiss
                  action: SnackBarAction(
                    label: 'Dismiss',
                    onPressed: () {},
                  ),
                  duration: const Duration(milliseconds: 50),
              ));
            },
            onSubmitted: (value) {
              // Handle search submission
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Searching for: $value')),
              );
            },
          ),
          // Google Map here
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Placeholder(fallbackHeight: 200, fallbackWidth: double.infinity),
            ),
          ),
          // Maximum Range Slider here
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text('Select Search Range (km): ${_currentSliderValue.round()}'),
                  Slider(
                    value: _currentSliderValue,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}