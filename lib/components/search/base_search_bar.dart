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

  /// Callback to do extra actions when tapping the search bar. <br><br>
  /// 
  /// If provided, the return value will determine whether to open the SearchView (if [useSearchViewForSuggestions] is true). <br>
  /// Otherwise, default to opening the SearchView when the search bar is tapped.
  final bool Function()? onTap;
  // final FutureOr<Iterable<Widget>> Function(BuildContext, SearchController)? suggestionsBuilder;
  final List<SearchResultType>? suggestions;
  
  final Function(int index)? onSuggestionSelected;

  /// A BaseController instance for access to the notifyListeners() method
  final C listenable;

  final TextEditingController? searchController;

  /// Whether to use the [SearchView] dialog to show search suggestions when the search bar is tapped. <br>
  final bool useSearchViewForSuggestions;

  /// The search bar used across the app, where the leading menu button opens the main drawer and the trailing widgets can be customized as needed. <br>
  /// Also supports search suggestions via the [suggestions] list.
  const BaseSearchBar({
    super.key,
    required this.hintText,
    this.searchController,
    this.trailing,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.suggestions,
    required this.listenable,
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
      controller: widget.searchController,
      focusNode: _focusNode,
      onTap: 
        widget.useSearchViewForSuggestions 
          ? () {
            _focusNode.unfocus();
            // If onTap callback is provided, call it and use its return value to determine whether to open the SearchView. If not provided, default to opening the SearchView.
            bool shouldOpen = widget.onTap?.call() ?? true; 
            print('Should open SearchView: $shouldOpen');
            if(widget.useSearchViewForSuggestions) {
              if (shouldOpen) {
                // If the SearchView should be opened, call _openSearchView with the current search text
                _openSearchView(widget.searchController?.text ?? '');
              }
            }   
          }
          : null,
      hintText: widget.hintText,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => AppKeys.mainScaffoldKey.currentState?.openDrawer(),
      ),
      trailing: _trailing,
      onChanged: widget.useSearchViewForSuggestions ? null : widget.onChanged,
      onSubmitted: widget.useSearchViewForSuggestions ? null : widget.onSubmitted,
    );

    // Intrinsic height to ensure the vertical divider takes full height
    return IntrinsicHeight(
      child: ExcludeFocus(
        excluding: widget.useSearchViewForSuggestions, // Exclude the search bar from the focus tree to prevent it from opening the keyboard, let the SearchView's search bar handle the focus instead
        child: searchBar,
      ),
    );
  }

  Future<void> _openSearchView(String initialSearchText) async {
    // final SearchResultType? result = 
    await showDialog<SearchResultType>(
      context: context,
      builder: (BuildContext context) {
        return SearchView(
          searchBar: widget,
          listenable: widget.listenable,
          suggestions: widget.suggestions ?? [],
          onSuggestionSelected: widget.onSuggestionSelected,
          initialSearchText: initialSearchText,
        );
      },
    );

    // if (result != null && mounted) {
    //   // Handle the selected search result
    //   // Navigator.of(context).pop(result);
    //   // widget.onSubmitted?.call();
    //   print('Selected search result: ${result.name} (ID: ${result.id})');
    //   widget.onSuggestionSelected?.call(result.id);
    // }
  }
}