import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/components/base_search_bar.dart';
import 'package:w2b_flutter/features/answer/presentation/answers_filter_drawer.dart';
import 'package:w2b_flutter/models/inquiry_model.dart';
import 'package:w2b_flutter/util/api_util.dart';
import 'package:w2b_flutter/util/location_util.dart';

class AnswersPage extends StatefulWidget {
  const AnswersPage(this.dio, {super.key});

  final Dio dio;

  @override
  State<AnswersPage> createState() => _AnswersPageState();
}

class _AnswersPageState extends State<AnswersPage> {
  final GlobalKey<ScaffoldState> _answersScaffoldKey = GlobalKey<ScaffoldState>();

  late List<NearbyInquiry> _nearbyInquiries;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Position userLocation = await LocationUtil.getCurrentLocation();

      _nearbyInquiries = await InquiryApiService(widget.dio).getNearbyInquiries(userLocation.latitude, userLocation.longitude);
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _answersScaffoldKey,
      endDrawer: const AnswerFilterDrawer(),
      body: BaseLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Search bar
          BaseSearchBar(
            hintText: 'Search for requests...',
            onChanged: (value) {
              // Handle search input change
            },
            onSubmitted: (value) {
              // Handle search submission
            },
            trailing: [
              IconButton(
                onPressed: () {
                  // TODO: temporary: go to answer page
                  // Navigator.pushNamed(context, '/respond');
          
                  _answersScaffoldKey.currentState?.openEndDrawer();
                }, 
                icon: const Icon(Icons.filter_alt_outlined), 
                tooltip: "Filter requests",
              ),
            ],
          ),
          // List of nearby requests
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _nearbyInquiries.length,
                  itemBuilder: (context, index) {
                    final inquiry = _nearbyInquiries[index];
                    return ListTile(
                      title: Text(inquiry.itemName),
                      subtitle: Text(inquiry.itemDescription ?? ''),

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