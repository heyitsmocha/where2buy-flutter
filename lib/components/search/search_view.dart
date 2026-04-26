import 'package:flutter/material.dart';
import 'package:w2b_flutter/base_controller.dart';
import 'package:w2b_flutter/components/search/base_search_bar.dart';

class SearchResultType {
  final int modelId;
  final String modelName;

  SearchResultType({required this.modelId, required this.modelName});
}

class SearchView<C extends BaseController> extends StatefulWidget {
  final BaseSearchBar<C> searchBar;
  final C listenable;
  final List<SearchResultType> suggestions;
  final Function(int index)? onSuggestionSelected;
  final String? initialSearchText;

  const SearchView({super.key, required this.searchBar, required this.listenable, required this.suggestions, this.onSuggestionSelected, this.initialSearchText});

  @override
  State<SearchView> createState() => _SearchViewState<C>();
}

class _SearchViewState<C extends BaseController> extends State<SearchView<C>> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // widget.controller.searchBarSubLogic.searchText = '';
    // Focus the search field when the view is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // TODO: Only request focus if there's no item that's already selected (i.e. user is just opening the search view to browse suggestions rather than typing in a search query)
      FocusScope.of(context).requestFocus(_focusNode);
      
      widget.searchBar.searchController?.text = widget.initialSearchText ?? '';
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5, // Set a fixed height for the search view
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SearchBar(
              controller: widget.searchBar.searchController,
              focusNode: _focusNode,
              autoFocus: true,
              hintText: widget.searchBar.hintText,
              // trailing: widget.searchBar.trailing,
              onChanged: widget.searchBar.onChanged,
              onSubmitted: widget.searchBar.onSubmitted,
            ),
            ListenableBuilder(
              listenable: widget.listenable,
              builder: (context, _) => Expanded(
                child: ListView.separated(
                  itemCount: widget.suggestions.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final suggestion = widget.suggestions[index];
                    bool isNotSelectable = suggestion.modelId == -1; // modelId of -1 indicates an error message or non-selectable item (i.e. "No results found")
                    return ListTile(
                      textColor: isNotSelectable ? Colors.grey : null, // Show error messages in gray
                      title: Text(suggestion.modelName),
                      onTap: isNotSelectable ? null : () => widget.onSuggestionSelected?.call(index),
                      trailing: isNotSelectable ? null : const Icon(Icons.chevron_right),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
