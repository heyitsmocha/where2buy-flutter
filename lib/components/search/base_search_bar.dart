import 'dart:async';

import 'package:flutter/material.dart';
import 'package:w2b_flutter/base_controller.dart';
import 'package:w2b_flutter/components/search/search_view.dart';
import 'package:w2b_flutter/core/app_keys.dart';

class BaseSearchBar<C extends BaseController> extends StatefulWidget {
  final String hintText;
  final List<Widget>? trailing;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  // final FutureOr<Iterable<Widget>> Function(BuildContext, SearchController)? suggestionsBuilder;
  final List<SearchResultType>? suggestions;
  
  final Function(int id)? onSuggestionSelected;

  /// A BaseController instance for access to the notifyListeners() method
  final C controller;

  /// Whether to use the [SearchView] dialog to show search suggestions when the search bar is tapped. <br>
  final bool useSearchViewForSuggestions;

  /// The search bar used across the app, where the leading menu button opens the main drawer and the trailing widgets can be customized as needed. <br>
  /// Also supports search suggestions via the [suggestions] list.
  const BaseSearchBar({
    super.key,
    required this.hintText,
    this.trailing,
    this.onChanged,
    this.onSubmitted,
    this.suggestions,
    required this.controller,
    this.useSearchViewForSuggestions = false,
    this.onSuggestionSelected,
  });

  @override
  State<BaseSearchBar> createState() => _BaseSearchBarState();
}

class _BaseSearchBarState<C extends BaseController> extends State<BaseSearchBar<C>> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // Default trailing widget
  final Widget _defaultTrailing = const Padding(
    padding:  EdgeInsets.all(8.0),
    child: Icon(Icons.search),
  );

  final List<Widget>_trailing = [];

  @override
  Widget build(BuildContext context) {
    // Add trailing widgets if provided
    // Done in build() instead of initState() in case the passed trailing widget changes based on state
    if (widget.trailing != null) {
      _trailing.clear();
      _trailing.addAll([
        _defaultTrailing,
        const VerticalDivider(),
        ...widget.trailing!,
      ]);
    }

    // If useSearchViewForSuggestions is true, tapping the search bar will open the SearchView dialog to show suggestions. Otherwise, the search bar behaves like a normal SearchBar without suggestions.
    SearchBar searchBar = SearchBar(
      focusNode: _focusNode,
      onTap: widget.useSearchViewForSuggestions ? _openSearchView : null,
      hintText: widget.hintText,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => AppKeys.mainScaffoldKey.currentState?.openDrawer(),
      ),
      trailing: _trailing,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );

    // Intrinsic height to ensure the vertical divider takes full height
    return IntrinsicHeight(
      child: widget.useSearchViewForSuggestions 
        ? ExcludeFocus(child: searchBar) // Exclude the search bar from the focus tree to prevent it from stealing focus when the SearchView is opened
        : searchBar,
    );
  }

  Future<void> _openSearchView() async {
    final SearchResultType? result = await showDialog<SearchResultType>(
      context: context,
      builder: (BuildContext context) {
        return SearchView(
          searchBar: widget,
          controller: widget.controller,
          suggestions: widget.suggestions ?? [],
        );
      },
    );

    if (result != null && mounted) {
      // Handle the selected search result
      // Navigator.of(context).pop(result);
      // widget.onSubmitted?.call();
      print('Selected search result: ${result.name} (ID: ${result.id})');
      widget.onSuggestionSelected?.call(result.id);
    }
  }
}