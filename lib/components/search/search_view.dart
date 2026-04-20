import 'package:flutter/material.dart';
import 'package:w2b_flutter/components/search/base_search_bar.dart';
import 'package:w2b_flutter/features/search/logic/search_page_controller.dart';

class SearchResultType {
  final int id;
  final String name;

  SearchResultType({required this.id, required this.name});
}

class SearchView extends StatefulWidget {
  final BaseSearchBar searchBar;
  final SearchPageController controller;

  const SearchView({super.key, required this.searchBar, required this.controller});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _controller = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    widget.controller.searchBarSubLogic.searchText = '';
  }

  @override
  void dispose() {
    _controller.dispose();
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
              hintText: widget.searchBar.hintText,
              trailing: widget.searchBar.trailing,
              onChanged: widget.searchBar.onChanged,
              onSubmitted: widget.searchBar.onSubmitted,
            ),
            ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) => Expanded(
                child: ListView.builder(
                  itemCount: widget.controller.searchBarSubLogic.searchSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = widget.controller.searchBarSubLogic.searchSuggestions[index];
                    return ListTile(
                      textColor: suggestion.id == -1 ? Colors.grey : null, // Show error messages in gray
                      title: Text(suggestion.name),
                      onTap: () => widget.searchBar.onSubmitted?.call(suggestion.id.toString()),
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
