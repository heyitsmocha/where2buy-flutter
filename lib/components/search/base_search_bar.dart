import 'dart:async';

import 'package:flutter/material.dart';
import 'package:w2b_flutter/components/search/search_view.dart';
import 'package:w2b_flutter/core/app_keys.dart';
import 'package:w2b_flutter/features/search/logic/search_page_controller.dart';

class BaseSearchBar extends StatefulWidget {
  final String hintText;
  final List<Widget>? trailing;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  // final FutureOr<Iterable<Widget>> Function(BuildContext, SearchController)? suggestionsBuilder;
  final List<SearchResultType>? suggestions;
  
  final Function(int id)? onSuggestionSelected;

  /// The controller that has the search logic and state, used to provide search suggestions and handle search input. <br>
  final SearchPageController controller;

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

class _BaseSearchBarState extends State<BaseSearchBar> {
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

    // Intrinsic height to ensure the vertical divider takes full height
    return IntrinsicHeight(
      child: SearchBar(
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
      ),
    );
  }

  Future<void> _openSearchView() async {
    final SearchResultType? result = await showDialog<SearchResultType>(
      context: context,
      builder: (BuildContext context) {
        return SearchView(
          searchBar: widget,
          controller: widget.controller,
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