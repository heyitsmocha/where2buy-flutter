import 'package:w2b_flutter/features/search/logic/search_page_controller.dart';

class SearchBarSubLogic {
  final SearchPageController _parent;
  final SearchPageState state;
  SearchBarSubLogic(this._parent, this.state);

  String searchText = '';
  /// Prompts the user to log in if not authenticated, else navigates to the new request page.
  void handleNewRequestButtonPressed () {
    if (state.isLoggedIn) {
      // Navigate to request new item page
      _parent.emitEvent(SearchPageUiEvent.showNewRequestConfirmationDialog);
    } else {
      // Prompt user to log in
      _parent.emitEvent(SearchPageUiEvent.showLoginSnackbar);
    }
  }

  /// Provides search suggestions as the user types.
  void handleSearchInputChanged(String value) {
    searchText = value;
    if (searchText.length < 3) return; // only suggest for 3+ characters
    // TODO: Fetch and display search suggestions
    // _parent.scaffoldMessengerKey.currentState?.showSnackBar(
    //   SnackBar(
    //     content: Text('Display suggestions for: $searchText'),
    //     //dismiss
    //     action: SnackBarAction(
    //       label: 'Dismiss',
    //       onPressed: () {},
    //     ),
    //     duration: const Duration(milliseconds: 50),
    //   )
    // );
  }

  void handleSearchSubmitted(String value) {
    // TODO: Execute search with the submitted value
    // _parent.scaffoldMessengerKey.currentState?.showSnackBar(
    //   SnackBar(content: Text('Searching for: $searchText')),
    // );
  }
}