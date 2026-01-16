import 'package:flutter/material.dart';

class BaseSearchBar extends StatefulWidget {
  final String hintText;
  final List<Widget>? trailing;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final GlobalKey<ScaffoldState> mainScaffoldKey;

  const BaseSearchBar({
    super.key,
    required this.mainScaffoldKey,
    required this.hintText,
    this.trailing,
    this.onChanged,
    this.onSubmitted
  });

  @override
  State<BaseSearchBar> createState() => _BaseSearchBarState();
}

class _BaseSearchBarState extends State<BaseSearchBar> {
  // Default trailing widget
  final List<Widget>_trailing = [
    const Padding(
      padding:  EdgeInsets.all(8.0),
      child: Icon(Icons.search),
  )];

  @override
  void initState() {
    super.initState();

    // Add trailing widgets if provided
    if (widget.trailing != null) {
      _trailing.add(const VerticalDivider());
      _trailing.addAll(widget.trailing!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: SearchBar(
        hintText: widget.hintText,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => widget.mainScaffoldKey.currentState?.openDrawer(),
        ),
        trailing: _trailing,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
      ),
    );
  }
}