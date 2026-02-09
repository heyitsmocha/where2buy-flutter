import 'package:flutter/material.dart';
import 'package:w2b_flutter/features/search/logic/search_page_controller.dart';

class SearchBarSubLogic {
  final SearchPageController _parent;
  final SearchPageState state;
  SearchBarSubLogic(this._parent, this.state);

  String _searchText = '';
  /// Prompts the user to log in if not authenticated, else navigates to the new request page.
  void handleNewRequestButtonPressed () {
    if (state.isLoggedIn) {
      // Navigate to request new item page
      ScaffoldMessenger.of(_parent.context).showSnackBar(
        SnackBar(content: Text('Navigating to Request New Item Page with text: $_searchText...')),
      );
    } else {
      // Prompt user to log in
      ScaffoldMessenger.of(_parent.context).showSnackBar(
        SnackBar(
          content: const Text('Please log in to post a new item request.'),
          action: SnackBarAction(label: 'Log In', onPressed: () {
            // Navigate to login page
            ScaffoldMessenger.of(_parent.context).showSnackBar(
              const SnackBar(content: Text('Navigating to Login Page...')),
            );
          }
        ),
      ));
    }
  }

  /// Provides search suggestions as the user types.
  void handleSearchInputChanged(String value) {
    _searchText = value;
    if (_searchText.length < 3) return; // only suggest for 3+ characters
    // TODO: Fetch and display search suggestions
    ScaffoldMessenger.of(_parent.context).showSnackBar(
      SnackBar(
        content: Text('Display suggestions for: $_searchText'),
        //dismiss
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {},
        ),
        duration: const Duration(milliseconds: 50),
      )
    );
  }

  void handleSearchSubmitted(String value) {
    // TODO: Execute search with the submitted value
    ScaffoldMessenger.of(_parent.context).showSnackBar(
      SnackBar(content: Text('Searching for: $_searchText')),
    );
  }
}