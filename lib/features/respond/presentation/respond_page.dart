import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:w2b_flutter/auth_state.dart';
import 'package:w2b_flutter/base_controller.dart';
import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/components/choose_widget.dart';
import 'package:w2b_flutter/components/search/base_search_bar.dart';
import 'package:w2b_flutter/core/network_results.dart';
import 'package:w2b_flutter/features/respond/presentation/respond_page_filter_drawer.dart';
import 'package:w2b_flutter/models/inquiry_model.dart';
import 'package:w2b_flutter/util/api_util.dart';
import 'package:w2b_flutter/util/location_util.dart';

class RespondPageController extends BaseController {
  final Dio dio;

  RespondPageController(this.dio);
}

class RespondPage extends StatefulWidget {
  const RespondPage(this.dio, {super.key});

  final Dio dio;

  @override
  State<RespondPage> createState() => _RespondPageState();
}

class _RespondPageState extends State<RespondPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final GlobalKey<ScaffoldState> _respondScaffoldKey = GlobalKey<ScaffoldState>();

  List<NearbyInquiry> _nearbyInquiries = [];
  bool _isLoading = true;

  late RespondPageController _controller;

  TextEditingController searchController = TextEditingController();

  late Position _userPosition;

  // For use in initState and dispose to listen for changes in AuthState
  late final AuthState _authSubscription;

  @override
  void initState() {
    super.initState();
    _controller = RespondPageController(widget.dio);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Listen for changes in the AuthState and update the list of nearby inquiries accordingly
      _authSubscription = context.read<AuthState>();
      _authSubscription.addListener(_updateList);

      // Get the user's current location and fetch nearby inquiries
      _userPosition = await LocationUtil.getCurrentLocation(maxMinutes: 1);
      _updateList();
    });
  }

  void _updateList() {
    bool isLoggedIn = context.read<AuthState>().isLoggedIn;
    if (isLoggedIn) {
      _refresh();
    } else {
      setState(() {
        _nearbyInquiries.clear();
        _isLoading = false;
      });
    }
  }

  void _refresh() async {
    setState(() {
      _isLoading = true;
    });
    
    // lower the maxMinutes in case the user is on the move while on the RespondPage, so that we can get a more accurate location and nearby inquiries.
    Position fetchLocation = await LocationUtil.getCurrentLocation(maxMinutes: 1);
    double distanceMeters = Geolocator.distanceBetween(
        _userPosition.latitude, 
        _userPosition.longitude, 
        fetchLocation.latitude, 
        fetchLocation.longitude
    );

    // Only refresh if the user has moved a significant distance
    if (distanceMeters > 5 || _nearbyInquiries.isEmpty) {
      _userPosition = fetchLocation;

      final result = await ApiUtil.safeApiCall(
        onTry: () async => await InquiryApiService(widget.dio).getNearbyInquiries(_userPosition.latitude, _userPosition.longitude)
      );

      switch (result) {
        case Success(value: final data):
          if (mounted) {
            setState(() {
              _nearbyInquiries = data;
              _isLoading = false;
            });
          }
          break;
        case Failure(errorMessage: final message):
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load nearby inquiries: $message')),
            );
          }
          break;
      }
    } else {
      // If the user hasn't moved significantly, just stop the loading indicator without making an API call
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // For AutomaticKeepAliveClientMixin to work

    bool isLoggedIn = context.watch<AuthState>().isLoggedIn;
    return Scaffold(
      key: _respondScaffoldKey,
      endDrawer: const RespondPageFilterDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading || !isLoggedIn ? null : _refresh,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
      body: BaseLayout(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              BaseSearchBar(
                listenable: _controller, 
                hintText: 'Search for requests...',
                onChanged: (value) {
                  // Handle search input change
                  if (!isLoggedIn) {
                    searchController.text = '';
                  }
                },
                onSubmitted: (value) {
                  // Handle search submission
                },
                // trailing: [
                //   IconButton(
                //     onPressed: () => _respondScaffoldKey.currentState?.openEndDrawer(), 
                //     icon: const Icon(Icons.filter_alt_outlined), 
                //     tooltip: "Filter requests",
                //   ),
                // ],
              ),
              const SizedBox(height: 16),
              // List of nearby requests
              Choose(
                condition: isLoggedIn,
                ifFalse: (context) => const Card(child: ListTile(title: Text('Please log in to see nearby requests.'))),
                ifTrue: (context) => Choose(
                  condition: _isLoading,
                  ifTrue: (context) => const Center(child: CircularProgressIndicator()),
                  ifFalse: (context) => Card(
                    child: Choose(
                      condition: _nearbyInquiries.isEmpty,
                      ifTrue: (context) => const ListTile(title: Text('No nearby requests found.')),
                      ifFalse: (context) => ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), // To prevent SingleChildScrollView from competing with ListView for scroll gestures
                        itemCount: _nearbyInquiries.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final inquiry = _nearbyInquiries[index];
                          return ListTile(
                            title: Text(inquiry.itemName),
                            subtitle: Text(inquiry.itemDescription ?? ''),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.of(context).pushNamed('/respond/add', arguments: inquiry),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authSubscription.removeListener(_updateList);
    super.dispose();
  }
}