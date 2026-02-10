import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/components/base_search_bar.dart';
import 'package:w2b_flutter/features/inquiry/logic/inquiries_page_mixin.dart';

class InquiriesPage extends StatefulWidget {
  const InquiriesPage(this.dio, {super.key});
  final Dio dio;

  @override
  State<InquiriesPage> createState() => _InquiriesPageState();
}

class _InquiriesPageState extends State<InquiriesPage> with InquiriesPageMixin {
  late List<Inquiry> _inquiries = [];

  @override
  void initState() {
    super.initState();

    refresh();
  }

  
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          BaseSearchBar(
            mainScaffoldKey: widget.mainScaffoldKey,
            hintText: 'Search Requests...',
            trailing: [
              IconButton(onPressed: () => refresh(), icon: const Icon(Icons.refresh))
            ],
            onChanged: (value) {},
            onSubmitted: (value) {},  
          ),
          Text(
            _loading ? 'Loading...' : _inquiries.isEmpty ? 'No Requests Found' :'Request List Page',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      )
    );
  }

  // Mixin states
  @override
  Dio get dio => widget.dio;

  bool _loading = false;
  @override
  bool get loading => _loading;
  @override
  set loading(bool value) {
    _loading = value;
  }
  
  @override
  List<Inquiry> get inquiries => _inquiries;
  @override
  set inquiries(List<Inquiry> value) {
    _inquiries = value;
  }
}