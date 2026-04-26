import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:w2b_flutter/base_state.dart';

import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/components/search_range_slider.dart';
import 'package:w2b_flutter/components/search/base_search_bar.dart';
import 'package:w2b_flutter/components/map/map_secondary_button.dart';
import 'package:w2b_flutter/components/map/map_widget.dart';
import 'package:w2b_flutter/core/network_results.dart';
import 'package:w2b_flutter/features/search/logic/search_page_controller.dart';
import 'package:w2b_flutter/features/search/presentation/new_inquiry_form.dart';
import 'package:w2b_flutter/util/auth_util.dart';

class SearchPage extends StatefulWidget {
  const SearchPage(this.dio, {super.key});

  final Dio dio;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

  final TextEditingController searchBarController = TextEditingController();
  
  @override
  SearchPageController initController() => SearchPageController(widget.dio, searchBarController);

  double get mapWidth => MediaQuery.of(context).size.width - 16;

  @override
  void handleUIEvent(SearchPageUiEvent event) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    switch (event) {
      case SearchPageUiEvent.showSnackbar:
        // Handle showing snackbar
        break;
      case SearchPageUiEvent.showLoginSnackbar:
        // Handle showing login snackbar
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Please log in to post a new item request.'),
            action: SnackBarAction(label: 'Log In', onPressed: () async {
              // Show login form
              final Result result = await AuthUtil.showAuthForm(
                context, 
                widget.dio, 
              );

              if (result is Success) {
                _showNewRequestForm();
              }
            }),
          )
        );
        break;
      case SearchPageUiEvent.showNewRequestConfirmationDialog:
        // Handle showing new request confirmation dialog
        _showNewRequestForm();
        break;
      case SearchPageUiEvent.newRequestPosted:
        messenger.showSnackBar(
          const SnackBar(content: Text('New item request posted successfully!')),
        );
        // Close the new request form if it's still open
        Navigator.of(context).pop();
        break;
      case SearchPageUiEvent.newRequestFailed:
        messenger.showSnackBar(
          const SnackBar(content: Text('Failed to post new item request. Please try again.')),
        );
        break;
      case SearchPageUiEvent.showNoNearbyResultsSnackbar:
        messenger.showSnackBar(
          const SnackBar(
            content: Text("No nearby results found. Expand the search area or post a new request with your search area."),
          ),
        );
        break;
        case SearchPageUiEvent.searchResultSelected:
          // Dismiss the search suggestions dialog if it's still open
          Navigator.of(context).pop();
          break;
        case SearchPageUiEvent.searchLockedWarning:
          break;
    }
  }

  void _showNewRequestForm() {
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      builder: (context) => NewInquiryForm(
        itemName: controller.searchBarSubLogic.searchText,
        description: controller.searchBarSubLogic.description,
        onItemNameChanged: (value) => controller.searchBarSubLogic.searchText = value,
        onDescriptionChanged: (value) => controller.searchBarSubLogic.description = value,
        onSubmit: () => controller.searchBarSubLogic.handleSendNewRequest(),

        listenable: controller,
        sliderValue: () =>controller.state.currentSliderValue,
        onSliderChanged: (value) => controller.handleRangeSliderChanged(value, mapWidth),
        searchRangeText: () => controller.searchRangeText,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout( 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          BaseSearchBar(
            useSearchViewForSuggestions: true,
            controller: controller,
            hintText: 'Search for items...',
            trailing: [
              IconButton(
                onPressed: controller.searchBarSubLogic.handleNewRequestButtonPressed, 
                icon: const Icon(Icons.post_add), 
                tooltip: "Request new item",
              ),
            ],
            suggestions: controller.searchBarSubLogic.searchSuggestions,
            onChanged: (value) async => await controller.searchBarSubLogic.handleSearchInputChanged(value),
            onSubmitted: (value) => controller.searchBarSubLogic.handleSearchSubmitted(value),
          ),
          // Google Map
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) => MapWidget(
                  showMyLocationButton: true,
                  showZoomControls: true,
                  extraButtons: [
                    MapSecondaryButton(
                      icon: Icon(controller.state.lockSearchArea ? Icons.lock : Icons.lock_open),
                      onPressed: controller.secondaryButtonsSubLogic.handleSearchAreaLockToggle,
                      tooltip: controller.state.lockSearchArea ? 'Unlock Search Area' : 'Lock Search Area',
                    ),
                    MapSecondaryButton(
                      onPressed: !controller.state.lockSearchArea ? null : controller.secondaryButtonsSubLogic.handleMoveSearchAreaToCameraButtonPressed,
                      icon: const Icon(Icons.pin_drop_outlined),
                      tooltip: 'Move search area to current location',
                    ),
                    MapSecondaryButton(
                      onPressed: !controller.state.lockSearchArea ? null : () => controller.moveCameraToSearchLocation(mapWidth, animate: true),
                      icon: const Icon(Icons.center_focus_strong_outlined),
                      tooltip: 'Move Map to Search Area',  
                    ),
                  ],
                  onLocationInitialized: (position) => controller.mapSubLogic.handleOnLocationInitialized(position, mapWidth),
                  onMapCreated: controller.mapSubLogic.handleMapCreated,
                  onCameraMove: controller.mapSubLogic.handleCameraMove,
                  circles: {controller.searchRangeCircle},
                ),
              ),
            ),
          ),
          // Maximum Range Slider
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchRangeSlider(
                listenable: controller,
                sliderValue: () => controller.state.currentSliderValue,
                onSliderChanged: (value) => controller.handleRangeSliderChanged(value, mapWidth),
                searchRangeText: () => controller.searchRangeText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}