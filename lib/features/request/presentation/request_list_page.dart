import 'package:flutter/material.dart';
import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/components/base_search_bar.dart';

class RequestListPage extends StatefulWidget {
  const RequestListPage({super.key, required this.mainScaffoldKey});

  final GlobalKey<ScaffoldState> mainScaffoldKey;

  @override
  State<RequestListPage> createState() => _RequestListPageState();
}

class _RequestListPageState extends State<RequestListPage> {
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          BaseSearchBar(
            mainScaffoldKey: widget.mainScaffoldKey,
            hintText: 'Search Requests...',
            onChanged: (value) {},
            onSubmitted: (value) {},  
          ),
          Text(
            'Request List Page',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      )
    );
  }
}