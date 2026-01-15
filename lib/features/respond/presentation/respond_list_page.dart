import 'package:flutter/material.dart';
import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/components/base_search_bar.dart';
import 'package:w2b_flutter/features/respond/presentation/respond_list_filter_drawer.dart';

class RespondListPage extends StatefulWidget {
  const RespondListPage({super.key, required this.mainScaffoldKey});

  final GlobalKey<ScaffoldState> mainScaffoldKey;

  @override
  State<RespondListPage> createState() => _RespondListPageState();
}

class _RespondListPageState extends State<RespondListPage> {
  final GlobalKey<ScaffoldState> _respondScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _respondScaffoldKey,
      endDrawer: const RespondFilterDrawer(),
      body: BaseLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Search bar
          BaseSearchBar(
            mainScaffoldKey: widget.mainScaffoldKey,
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
                  // TODO: temporary: go to respond page
                  // Navigator.pushNamed(context, '/respond');
          
                  _respondScaffoldKey.currentState?.openEndDrawer();
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