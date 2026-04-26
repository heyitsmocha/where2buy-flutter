import 'dart:async';

import 'package:dio/dio.dart';
import 'package:w2b_flutter/components/search/search_view.dart';
import 'package:w2b_flutter/core/network_results.dart';
import 'package:w2b_flutter/features/search/logic/search_page_controller.dart';
import 'package:w2b_flutter/models/inquiry_model.dart';
import 'package:w2b_flutter/models/item_model.dart';
import 'package:w2b_flutter/models/response_model.dart';
import 'package:w2b_flutter/util/api_util.dart';
import 'package:w2b_flutter/util/auth_util.dart';

class SearchBarSubLogic {
  final SearchPageController _parent;
  final SearchPageState state;
  SearchBarSubLogic(this._parent, this.state);

  String searchText = '';

  bool _isSearchingForAnswers = false;
  bool get isSearchingForAnswers => _isSearchingForAnswers;

  final List<SearchResultType> _searchSuggestions = [];
  List<SearchResultType> get searchSuggestions => _searchSuggestions;

  SearchResultType? _selectedSuggestion;
  SearchResultType? get selectedSuggestion => _selectedSuggestion;

  /// Prompts the user to log in if not authenticated, else show the new request form.
  void handleNewRequestButtonPressed() async {
    final bool loggedIn = await AuthUtil.isLoggedIn();
    _parent.emitEvent(loggedIn ? SearchPageUiEvent.showNewRequestConfirmationDialog : SearchPageUiEvent.showLoginSnackbar);
  }

  Future<void> handleSendNewRequest() async {
    final CreateInquiryRequest inquiry = CreateInquiryRequest(
      name: _selectedSuggestion?.modelName ?? '',
      description: description,
      latitude: _parent.state.searchLatLng.latitude,
      longitude: _parent.state.searchLatLng.longitude,
      searchRadiusMeters: (_parent.searchRangeKm * 1000).toInt(),
      // sameCountryOnly: true,
      // anywhere: true,
    );
    // ApiService(_parent.dio).createInquiry(file: File('path/to/file'), inquiry: inquiry);

    try {
      await InquiryApiService(_parent.dio).createInquiry(
        data: await inquiry.toFormData(),
      );

      _parent.emitEvent(SearchPageUiEvent.newRequestPosted);
    } on DioException catch (e) {
      print('Error creating inquiry: ' + e.toString());
      _parent.emitEvent(SearchPageUiEvent.newRequestFailed);
      return;
    }
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
      _searchSuggestions.clear();
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
    _searchSuggestions.clear();

    // Cancel any ongoing search suggestions request before starting a new one
    _searchSuggestionsCancelToken?.cancel("New search started");

    // Create a new cancel token for the new request
    _searchSuggestionsCancelToken = CancelToken();
    
    try {
      ApiResponse<List<ItemSearchSuggestion>> result = await ApiService(_parent.dio).getSearchSuggestions(input: value, cancelToken: _searchSuggestionsCancelToken!);
      if (searchText.isNotEmpty && result.data != null && result.data!.isEmpty) {
        _searchSuggestions.add(SearchResultType(modelId: -1, modelName: 'No suggestions found'));
      } else {
        if (value == searchText) { // Ensure the input hasn't changed since the API call was made
          for (ItemSearchSuggestion element in result.data!) {
            _searchSuggestions.add(SearchResultType(modelId: element.itemId, modelName: element.itemName));
          }
        }
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        // print('Search suggestions fetch cancelled');
      } else {
        // print('Error fetching search suggestions: $e');
        _searchSuggestions.add(SearchResultType(modelId: -1, modelName: 'Error fetching suggestions'));
      }
    } finally {
      print('Api call completed, searchSuggestions length: ${_searchSuggestions.length}');

      // Update the UI with the new suggestions
      _parent.notifyListeners();
    }
  }

  Future<void> performSearchForAnswers() async {
    _isSearchingForAnswers = true;
    _parent.notifyListeners();

    // Fetch the answers for the selected suggestions
    final result = await ApiUtil.safeApiCall(
      onTry: () async => await ApiService(_parent.dio).getNearbyAnswers(
        item: _selectedSuggestion!.modelId,
        latitude: _parent.state.searchLatLng.latitude,
        longitude: _parent.state.searchLatLng.longitude,
        range: _parent.searchRangeKm * 1000,
      )
    );

    switch (result) {
      case Success(value: final data):
        // Update the map markers
        _parent.state.markers.clear();
        _searchSuggestions.clear();

        // if (data.isEmpty) {
        //   _parent.emitEvent(SearchPageUiEvent.showNoNearbyResultsSnackbar);
        //   break;
        // }
        for (Answer answer in data) {
          _parent.state.markers.add(
            Marker(
              markerId: MarkerId(answer.id.toString()),
              position: LatLng(answer.latitude, answer.longitude),
            ),
          );
        }
        break;
      case Failure(errorMessage: final message):
        // _parent.emitEvent(SearchPageUiEvent.showSearchResultsFetchErrorSnackbar);
        break;
    }
    
    print('Notifying listeners after search suggestion selected');
    _isSearchingForAnswers = false;
    _parent.notifyListeners();
  }
}