import 'package:flutter/material.dart';
import 'package:w2b_flutter/features/search/logic/search_page_base_mixin.dart';

mixin SearchPageSearchBarMixin on SearchPageBaseMixin {
  void handleNewRequestButtonPressed () {
    if (isLoggedIn) {
      // Navigate to request new item page
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Navigating to Request New Item Page...')),
      );
    } else {
      // Prompt user to log in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please log in to post a new item request.'),
          action: SnackBarAction(label: 'Log In', onPressed: () {
            // Navigate to login page
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Navigating to Login Page...')),
            );
          }
        ),
      ));
    }
  }

  void handleSearchInputChanged(String value) {
    if (value.length < 3) return; // only suggest for 3+ characters
    // TODO: Fetch and display search suggestions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Display suggestions for: $value'),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for: $value')),
    );
  }
}