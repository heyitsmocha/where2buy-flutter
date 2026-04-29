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

class _SearchPageState extends BaseState<SearchPage, SearchPageController, SearchPageUiEvent> with SingleTickerProviderStateMixin{
  final TextEditingController searchBarController = TextEditingController();
  
  @override
  SearchPageController initController() => SearchPageController(widget.dio, searchBarController);

  double get mapWidth => MediaQuery.of(context).size.width - 16;

  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

    _shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: -5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: 0.0), weight: 1),
    ]).animate(_animationController);

    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(tween: ColorTween(begin: Colors.white, end: Colors.redAccent), weight: 1),
      TweenSequenceItem(tween: ColorTween(begin: Colors.redAccent, end: Colors.white), weight: 1),
    ]).animate(_animationController);
  }

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
          _animationController.forward(from: 0.0);
          break;
    }
  }

  void _showNewRequestForm() {
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.5 + MediaQuery.of(context).viewInsets.bottom + 16,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: NewInquiryForm(
            itemName: controller.searchBarSubLogic.searchText,
            // description: controller.searchBarSubLogic.description,
            onItemNameChanged: (value) => controller.searchBarSubLogic.searchText = value,
            onDescriptionChanged: (value) {},
            onSubmit: () => controller.searchBarSubLogic.handleSendNewRequest(),
          
            listenable: controller,
            sliderValue: () => controller.state.currentSliderValue,
            onSliderChanged: (value) => controller.handleRangeSliderChanged(value, mapWidth),
            searchRadiusText: () => controller.searchRadiusText,
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout( 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) => Stack(
              alignment: Alignment.centerLeft,
              children: [
                BaseSearchBar(
                  onTap: controller.searchBarSubLogic.handleSearchBarTapped,
                  searchController: searchBarController,
                  useSearchViewForSuggestions: true,
                  listenable: controller,
                  hintText: controller.state.hasSelectedSearchResult ? '' :  'Search for items...',
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
                  onSuggestionSelected: (index) => controller.searchBarSubLogic.handleSearchSuggestionSelected(index),
                ),
                // Selected search result chip
                // TODO: confirm if chip works as intended when the search result name is long, maybe set a max width and use ellipsis if it exceeds that
                Visibility(
                  visible: controller.state.hasSelectedSearchResult,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 64.0),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, _) => Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: Chip(
                          backgroundColor: _colorAnimation.value,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(32.0)),
                          ),
                          label: Text(controller.searchBarSubLogic.selectedSuggestion!.modelName),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: controller.searchBarSubLogic.handleClearSelectedSuggestion,
                        ),
                      ),
                    ),
                  ),
                ),
              ]
            ),
          ),
          // Google Map
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) => Stack(
                  children: [
                      MapWidget(
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
                      onCameraIdle: controller.mapSubLogic.handleCameraIdle,
                      // Pass circle if search area is locked, otherwise pass empty set to hide it
                      circles: controller.state.lockSearchArea ? { controller.searchRangeCircle } : {},
                      markers: controller.state.markers.toSet(),
                    ),
                    Visibility(
                      visible: !controller.state.lockSearchArea,
                      child: IgnorePointer(
                        child: Center(
                          child: ValueListenableBuilder(
                            valueListenable: controller.searchRadiusPixelsNotifier,
                            builder: (context, searchRadiusPixels, child) => Container(
                              width: searchRadiusPixels * 2, // Diameter is twice the radius
                              height: searchRadiusPixels * 2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blueAccent.withOpacity(0.1),
                                border: Border.all(color: Colors.blueAccent, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),  
                    Visibility(
                      visible: controller.state.hasSelectedSearchResult,
                      child: Positioned(
                        child: Chip(
                          backgroundColor: _colorAnimation.value,
                          label: Text("Search result: ${controller.searchBarSubLogic.isSearchingForAnswers ? 'Searching...' : '${controller.state.markers.length} found'}" ),
                        )
                      ),
                    )
                  ]
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
                onSliderChangeEnd: (value) => controller.handleRangeSliderChangeEnd(value),
                searchRadiusText: () => controller.searchRadiusText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}