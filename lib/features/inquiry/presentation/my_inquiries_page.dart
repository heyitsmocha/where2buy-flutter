import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:w2b_flutter/base_state.dart';
import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/components/search/base_search_bar.dart';
import 'package:w2b_flutter/features/inquiry/logic/my_inquiries_page_controller.dart';

class MyInquiriesPage extends StatefulWidget {
  const MyInquiriesPage(this.dio, {super.key});
  final Dio dio;

  @override
  State<MyInquiriesPage> createState() => _MyInquiriesPageState();
}

class _MyInquiriesPageState extends BaseState<MyInquiriesPage, MyInquiriesPageController, MyInquiriesPageUiEvent> {
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

  @override
  void initState() {
    super.initState();
    controller.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) =>
       BaseLayout(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            BaseSearchBar(
              listenable: controller,
              hintText: 'Search Requests...',
              trailing: [
                controller.isLoading 
                  ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())
                  : IconButton(onPressed: () => controller.refresh(), icon: const Icon(Icons.refresh))     
              ],
              onChanged: (value) {},
              onSubmitted: (value) {},  
            ),
            const SizedBox(height: 16),
            controller.isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator())) 
              : Expanded(
                  child: controller.inquiries.isEmpty
                  ? const Text('You have not made any requests yet.')
                  : ListView.separated(
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
                        onTap: () {
                          Navigator.of(context).pushNamed('/inquiry/responses', arguments: inquiry);
                        }
                      );
                    },
                  ),
                ),
          ],
        )
      ),
    );
  }
}