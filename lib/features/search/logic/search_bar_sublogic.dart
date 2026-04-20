import 'dart:async';

import 'package:dio/dio.dart';
import 'package:w2b_flutter/components/search/search_view.dart';
import 'package:w2b_flutter/features/search/logic/search_page_controller.dart';
import 'package:w2b_flutter/models/item_model.dart';
import 'package:w2b_flutter/util/api_util.dart';
import 'package:w2b_flutter/util/auth_util.dart';

class SearchBarSubLogic {
  final SearchPageController _parent;
  final SearchPageState state;
  SearchBarSubLogic(this._parent, this.state);

  String searchText = '';
  String description = '';

  List<SearchResultType> searchSuggestions = [];

  /// Prompts the user to log in if not authenticated, else show the new request form.
  void handleNewRequestButtonPressed() async {
    final bool loggedIn = await AuthUtil.isLoggedIn();
    _parent.emitEvent(loggedIn ? SearchPageUiEvent.showNewRequestConfirmationDialog : SearchPageUiEvent.showLoginSnackbar);
  }

  Future<void> handleSendNewRequest() async {
  }

  CancelToken? _searchSuggestionsCancelToken;
  Timer? _debounceTimer;

  /// Provides search suggestions as the user types. <br> <br>
  /// If the input is less than 3 characters, it clears suggestions and does not make an API call. <br>
  /// If the input is 3 or more characters, it fetches suggestions from the server
  Future<void> handleSearchInputChanged(String value) async {
    if (value.length < 3) {
      // Debounce to avoid flooding the server with requests on every keystroke
      _debounceTimer?.cancel();
      
      // Cancel any ongoing search suggestions request before starting a new one
      _searchSuggestionsCancelToken?.cancel("Input changed to less than 3 characters");

      searchText = value;
      searchSuggestions.clear();
      _parent.notifyListeners();
      return; 
    }

    // Start a new debounce timer for the API call
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async => await handleSearchSubmitted(value));
  }

  /// Performs the search action when the user submits the search input. <br> <br>
  /// Unlike [handleSearchInputChanged], this does not check the length of the input and always attempts to fetch suggestions, allowing for searching with short inputs if desired.
  Future<void> handleSearchSubmitted(String value) async {    
    searchText = value;

    // Clear current suggestions to prevent duplicate entries
    searchSuggestions.clear();

    // Cancel any ongoing search suggestions request before starting a new one
    _searchSuggestionsCancelToken?.cancel("New search started");

    // Create a new cancel token for the new request
    _searchSuggestionsCancelToken = CancelToken();
    
    try {
      List<ItemSearchSuggestion> result = await ApiService(_parent.dio).getSearchSuggestions(input: value, cancelToken: _searchSuggestionsCancelToken!);
      if (searchText.isNotEmpty && result.isEmpty) {
        searchSuggestions.add(SearchResultType(id: -1, name: 'No suggestions found'));
      } else {
        if (value == searchText) { // Ensure the input hasn't changed since the API call was made
          for (ItemSearchSuggestion element in result) {
            searchSuggestions.add(SearchResultType(id: element.id, name: element.name));
          }
        }
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        // print('Search suggestions fetch cancelled');
      } else {
        // print('Error fetching search suggestions: $e');
        searchSuggestions.add(SearchResultType(id: -1, name: 'Error fetching suggestions'));
      }
    } finally {
      print('Api call completed, searchSuggestions length: ${searchSuggestions.length}');

      // Update the UI with the new suggestions
      _parent.notifyListeners();
    }
  }
}