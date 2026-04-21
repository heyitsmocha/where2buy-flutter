import 'package:flutter/material.dart';
import 'package:w2b_flutter/base_controller.dart';
import 'package:w2b_flutter/components/search/base_search_bar.dart';

class SearchResultType {
  final int id;
  final String name;

  SearchResultType({required this.id, required this.name});
}

class SearchView<C extends BaseController> extends StatefulWidget {
  final BaseSearchBar<C> searchBar;
  final C controller;
  final List<dynamic> suggestions;

  const SearchView({super.key, required this.searchBar, required this.controller, required this.suggestions});

  @override
  State<SearchView> createState() => _SearchViewState<C>();
}

class _SearchViewState<C extends BaseController> extends State<SearchView<C>> {
  final _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // widget.controller.searchBarSubLogic.searchText = '';
    // Focus the search field when the view is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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
              focusNode: _focusNode,
              autoFocus: true,
              hintText: widget.searchBar.hintText,
              // trailing: widget.searchBar.trailing,
              onChanged: widget.searchBar.onChanged,
              onSubmitted: widget.searchBar.onSubmitted,
            ),
            ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) => Expanded(
                child: ListView.builder(
                  itemCount: widget.suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = widget.suggestions[index];
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
