import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:w2b_flutter/base_state.dart';

import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/components/base_search_bar.dart';
import 'package:w2b_flutter/components/map/map_secondary_button.dart';
import 'package:w2b_flutter/components/map/map_widget.dart';
import 'package:w2b_flutter/features/search/logic/search_page_controller.dart';

class SearchPage extends StatefulWidget {
  const SearchPage(this.dio, {super.key});

  final Dio dio;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends BaseState<SearchPage, SearchPageController, SearchPageUiEvent> with SingleTickerProviderStateMixin {
  @override
  SearchPageController initController() => SearchPageController();
    
  // Animation variables
  late AnimationController _pinAnimationController;
  get pinAnimationController => _pinAnimationController;
  late Animation<double> 
    _xAnimation,
    _yAnimation,
    _rotationAnimation,
    _shadowOpacity,
    _shadowScale;

    Matrix4 get pinTransform {
    return Matrix4
    .identity()
      ..translate(_xAnimation.value, _yAnimation.value)
      ..rotateZ(_rotationAnimation.value);
  }


  @override
  void initState() {
    super.initState();

    _initializeAnimations();
  }

  @override
  void handleUIEvent(SearchPageUiEvent event) {
    if (!mounted) return;
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
          action: SnackBarAction(label: 'Log In', onPressed: () {
            // Navigate to login page
            messenger.showSnackBar(
              const SnackBar(content: Text('Navigating to Login Page...')),
            );
          }
        ),
      ));
        break;
      case SearchPageUiEvent.showNewRequestConfirmationDialog:
        // Handle showing new request confirmation dialog
        messenger.showSnackBar(
          SnackBar(content: Text('Navigating to Request New Item Page with text: ${controller.searchBarSubLogic.searchText}...')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double mapWidth = MediaQuery.of(context).size.width - 16;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) => BaseLayout( 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              BaseSearchBar(
                hintText: 'Search for items...',
                trailing: [
                  IconButton(
                    onPressed: controller.searchBarSubLogic.handleNewRequestButtonPressed, 
                    icon: const Icon(Icons.post_add), 
                    tooltip: "Request new item",
                  ),
                ],
                onChanged: controller.searchBarSubLogic.handleSearchInputChanged,
                onSubmitted: controller.searchBarSubLogic.handleSearchSubmitted,
              ),
              // Google Map
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: AnimatedBuilder(
                    animation: pinAnimationController,
                    builder: pinAnimationBuilder,
                    child: MapWidget(
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
                      onCameraMoveStarted: () { if(mounted) pinAnimationController.forward(); },
                      onCameraIdle: () { if(mounted) pinAnimationController.reverse(); },
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
                  child: Column(
                    children: [
                      // If range is 0, show "Exact Location", else show range in km or m
                      Text('Search Range: ${controller.searchRangeKm == 0 ? 'Exact Location': controller.searchRangeKm >= 1 ? '${controller.searchRangeKm.round()} km' : '${(controller.searchRangeKm * 1000).round()} m'}'),
                      Slider(
                        value: controller.state.currentSliderValue,
                        min: 0.08,
                        max: 1,
                        onChanged: (value) => controller.handleRangeSliderChanged(value, mapWidth),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  @override
  void dispose() {
    pinAnimationController.dispose();
    super.dispose();
  }

  /// Initialise the animation controller and the animations for the pin drop effect.
  void _initializeAnimations() {
    _pinAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Moves the pin up by 20 pixels
    _yAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(
        parent: _pinAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // Moves the pin right by 10 pixels
    _xAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _pinAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // Rotates the pin by 15 degrees
    _rotationAnimation = Tween<double>(begin: 0, end: 0.26).animate(
      CurvedAnimation(
        parent: _pinAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _shadowOpacity = Tween<double>(begin: 0.0, end: 0.4).animate(
      CurvedAnimation(
        parent: _pinAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _shadowScale = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _pinAnimationController,
        curve: Curves.easeOut,
      ),
    );
  }

  Widget pinAnimationBuilder(BuildContext context, Widget? child) {
    return Stack(
      children: [
        child!,
        // Pin Icon
        Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Center(
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: pinTransform,
              child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
            ),
          ),
        ),
        // Pin Shadow
        Transform.translate(
          offset: const Offset(0, 4),
          child: Opacity(
            opacity: _shadowOpacity.value,
            child: Center(
              child: Transform.scale(
                scale: _shadowScale.value,
                child: Container(
                  width: 20,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: const BorderRadius.all(Radius.elliptical(12, 4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      )
                    ]
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}