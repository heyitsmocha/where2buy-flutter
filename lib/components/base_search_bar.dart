import 'package:flutter/material.dart';
import 'package:w2b_flutter/core/app_keys.dart';

class BaseSearchBar extends StatefulWidget {
  final String hintText;
  final List<Widget>? trailing;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const BaseSearchBar({
    super.key,
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

    return IntrinsicHeight(
      child: SearchBar(
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
}