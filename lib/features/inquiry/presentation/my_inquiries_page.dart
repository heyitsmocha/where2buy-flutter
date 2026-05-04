import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w2b_flutter/auth_state.dart';
import 'package:w2b_flutter/base_state.dart';
import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/components/choose_widget.dart';
import 'package:w2b_flutter/components/search/base_search_bar.dart';
import 'package:w2b_flutter/features/inquiry/logic/my_inquiries_page_controller.dart';

class MyInquiriesPage extends StatefulWidget {
  const MyInquiriesPage(this.dio, {super.key});
  final Dio dio;

  @override
  State<MyInquiriesPage> createState() => _MyInquiriesPageState();
}

class _MyInquiriesPageState extends BaseState<MyInquiriesPage, MyInquiriesPageController, MyInquiriesPageUiEvent> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  MyInquiriesPageController initController() => MyInquiriesPageController(widget.dio);

  @override
  void handleUIEvent(MyInquiriesPageUiEvent event) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    switch (event) {
      case MyInquiriesPageUiEvent.showNetworkErrorSnackbar:
        messenger.showSnackBar(
          const SnackBar(content: Text('A network error occurred. Please try again later.')),
        );
        break;
      case MyInquiriesPageUiEvent.showUnexpectedErrorSnackbar:
        messenger.showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred. Please try again later.')),
        );
        break;
    }
  }

  // For use outside of build()
  late final AuthState _authSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authSubscription = Provider.of<AuthState>(context, listen: false);
      _authSubscription.addListener(_refresh);

      _refresh();
    });
  }

  void _refresh() {
    bool isLoggedIn = context.read<AuthState>().isLoggedIn;
    controller.refresh(isLoggedIn);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // For AutomaticKeepAliveClientMixin to work

    bool isLoggedIn = context.watch<AuthState>().isLoggedIn;

    return BaseLayout(
      child: SingleChildScrollView(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, child) => Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              BaseSearchBar(
                listenable: controller,
                hintText: 'Search Requests...',
                trailing: [
                  IconButton(onPressed: isLoggedIn && !controller.isLoading ? _refresh : null, icon: const Icon(Icons.refresh))     
                ],
                onChanged: (value) {},
                onSubmitted: (value) {},  
              ),
              const SizedBox(height: 16),
              Choose(
                condition: controller.isLoading,
                ifTrue: (context) => const Center(child: CircularProgressIndicator()) ,
                ifFalse: (context) => Choose(
                  condition: isLoggedIn,
                  ifFalse: (context) => const Card(child: ListTile(title: Text('Please log in to view your requests.'))),
                  ifTrue: (context) => Choose(
                    condition: controller.inquiries.isEmpty,
                    ifTrue: (context) => const Text('You have not made any requests yet.'),
                    ifFalse: (context) => Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), // To prevent SingleChildScrollView from competing with ListView for scroll gestures
                        itemCount: controller.inquiries.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final inquiry = controller.inquiries[index];
                          return ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(inquiry.itemName ?? 'No item name'),
                                // Display the date the inquiry was created if available
                                Text(inquiry.createdAt != null ? ' - ${inquiry.createdAt!.toLocal().toString().split(' ')[0]}' : '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            subtitle: Text(inquiry.itemDescription ?? ''),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).pushNamed('/inquiry/responses', arguments: inquiry);
                            }
                          );
                        },
                      ),
                    ),
                  ),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authSubscription.removeListener(_refresh);
    super.dispose();
  }
}