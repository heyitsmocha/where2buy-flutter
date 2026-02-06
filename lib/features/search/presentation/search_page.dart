import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/components/base_search_bar.dart';
import 'package:w2b_flutter/components/map/map_widget.dart';
import 'package:w2b_flutter/features/search/logic/search_page_base_mixin.dart';
import 'package:w2b_flutter/features/search/logic/search_page_map_mixin.dart';
import 'package:w2b_flutter/features/search/logic/search_page_search_bar_mixin.dart';
import 'package:w2b_flutter/features/search/logic/search_page_secondary_buttons_mixin.dart';

class SearchPage extends StatefulWidget {
  const SearchPage(this.dio, {super.key, required this.mainScaffoldKey});

  final GlobalKey<ScaffoldState> mainScaffoldKey;
  final Dio dio;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with 
  SingleTickerProviderStateMixin, 
  SearchPageBaseMixin, 
  SearchPageSearchBarMixin, 
  SearchPageSecondaryButtonsMixin,
  SearchPageMapMixin {
  @override
  void initState() {
    super.initState();

    initializeAnimations();
  }

  ButtonStyle _secondaryButtonStyle(BuildContext context, {bool translucentOnUnlock = true}) {
    // Secondary buttons are disabled when the search area is unlocked
    return !lockSearchArea && translucentOnUnlock
    ? ButtonStyle(
        // Semi-transparent background color
        backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onInverseSurface.withOpacity(0.8)),
        iconColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onSurface.withOpacity(0.38))
      )
    : ButtonStyle(
      // Solid background color
      backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.inversePrimary),
      iconColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary)
      ); 
  }

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
                onPressed: handleNewRequestButtonPressed, 
                icon: const Icon(Icons.post_add), 
                tooltip: "Request new item",
              ),
            ],
            onChanged: handleSearchInputChanged,
            onSubmitted: handleSearchSubmitted,
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
                    IconButton.filled(
                      style: _secondaryButtonStyle(context, translucentOnUnlock: false),
                      icon: Icon(lockSearchArea ? Icons.lock : Icons.lock_open),
                      onPressed: handleSearchAreaLockToggle,
                      tooltip: lockSearchArea ? 'Unlock Search Area' : 'Lock Search Area',
                    ),
                    IconButton.filled(
                      style: _secondaryButtonStyle(context),
                      onPressed: !lockSearchArea ? null : handleMoveSearchAreaToCameraButtonPressed,
                      icon: const Icon(Icons.pin_drop_outlined),
                      tooltip: 'Move search area to current location',
                    ),
                    IconButton.filled(
                      style: _secondaryButtonStyle(context),
                      onPressed: !lockSearchArea ? null : () => moveCameraToSearchLocation(animate: true),
                      icon: const Icon(Icons.center_focus_strong_outlined),
                      tooltip: 'Move Map to Search Area',  
                    ),
                  ],
                  onLocationInitialized: handleOnLocationInitialized,
                  onMapCreated: handleMapCreated,
                  onCameraMoveStarted: () => pinAnimationController.forward(),
                  onCameraIdle: () => pinAnimationController.reverse(),
                  onCameraMove: handleCameraMove,
                  circles: {searchRangeCircle},
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
                  Text('Search Range: ${searchRangeKm == 0 ? 'Exact Location': searchRangeKm >= 1 ? '${searchRangeKm.round()} km' : '${(searchRangeKm * 1000).round()} m'}'),
                  Slider(
                    value: currentSliderValue,
                    min: 0.08,
                    max: 1,
                    onChanged: handleRangeSliderChanged,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    pinAnimationController.dispose();
    super.dispose();
  }
}