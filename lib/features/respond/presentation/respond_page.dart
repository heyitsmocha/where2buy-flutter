import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:w2b_flutter/base_controller.dart';
import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/components/search/base_search_bar.dart';
import 'package:w2b_flutter/features/respond/presentation/respond_page_filter_drawer.dart';
import 'package:w2b_flutter/models/inquiry_model.dart';
import 'package:w2b_flutter/models/response_model.dart';
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

class _RespondPageState extends State<RespondPage> {
  final GlobalKey<ScaffoldState> _respondScaffoldKey = GlobalKey<ScaffoldState>();

  List<NearbyInquiry> _nearbyInquiries = [];
  bool _isLoading = true;

  late RespondPageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RespondPageController(widget.dio);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _refresh();
    });
  }

  void _refresh() async {
    ApiUtil.safeApiCall(
      onTry: () async {
        setState(() {
          _isLoading = true;
        });

        Position userLocation = await LocationUtil.getLastKnownLocation();
        ApiResponse<List<NearbyInquiry>> response = await InquiryApiService(widget.dio).getNearbyInquiries(userLocation.latitude, userLocation.longitude);
        
        setState(() {
          _nearbyInquiries = response.data ?? [];
          _isLoading = false;
        });

      }, 
      onError: (error) {

      }, 
      onDioError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load nearby inquiries: ${error.response?.data['message'] ?? error.message}')),
          );
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _respondScaffoldKey,
      endDrawer: const RespondPageFilterDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _refresh,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
      body: BaseLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Search bar
          BaseSearchBar(
            controller: _controller, 
            hintText: 'Search for requests...',
            onChanged: (value) {
              // Handle search input change
            },
            onSubmitted: (value) {
              // Handle search submission
            },
            trailing: [
              IconButton(
                onPressed: () => _respondScaffoldKey.currentState?.openEndDrawer(), 
                icon: const Icon(Icons.filter_alt_outlined), 
                tooltip: "Filter requests",
              ),
            ],
          ),
          // List of nearby requests
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  itemCount: _nearbyInquiries.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final inquiry = _nearbyInquiries[index];
                    return ListTile(
                      title: Text(inquiry.itemName),
                      subtitle: Text(inquiry.itemDescription ?? ''),
                      onTap: () => Navigator.of(context).pushNamed('/respond/add', arguments: inquiry),
                    );
                  },
                ),
          ),
        ],
      ),
    ),
    );
  }
}