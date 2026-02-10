import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/components/base_search_bar.dart';
import 'package:w2b_flutter/features/answer/presentation/answers_filter_drawer.dart';

class AnswersPage extends StatefulWidget {
  const AnswersPage(this.dio, {super.key});

  final Dio dio;

  @override
  State<AnswersPage> createState() => _AnswersPageState();
}

class _AnswersPageState extends State<AnswersPage> {
  final GlobalKey<ScaffoldState> _answersScaffoldKey = GlobalKey<ScaffoldState>();

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
          const Expanded(
            child: Center(
              child: Text('List of nearby requests will be shown here.'),
            ),
          ),
        ],
      ),
    ),
    );
  }
}