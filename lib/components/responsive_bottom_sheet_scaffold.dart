import 'package:flutter/material.dart';
import 'package:w2b_flutter/components/base_layout.dart';

class ResponsiveBottomSheetScaffold extends StatelessWidget {
  final Widget child;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  /// A widget to pass as the leading widget in the appbar. Ignored if [showAppBar] is false.
  final Widget? appBarLeading;
  /// The title to be displayed in the appbar. Ignored if [showAppBar] is false.
  final String appBarTitle;

  /// Flag to show the appbar with the given title and a close button. Can be set to false if the child widget already contains an appbar or if no appbar is desired. Defaults to true.
  final bool showAppBar;

  /// The fraction of the screen height that the bottom sheet should take when the keyboard is not visible. The actual height will be this fraction plus the keyboard height when the keyboard is visible.<br><br>
  /// The value must be between 0 (exclusive) and 1 (inclusive). (e.g. 0.6 to take 60% of the screen height)
  /// If not provided, defaults to 0.5 (50% of the screen height)
  final double screenHeightFactor;

  /// A widget that wraps its child in a Scaffold with an AppBar, and adjusts its height to accommodate the keyboard when it appears.<br><br>
  /// The tree structure is: Scaffold > BaseLayout > child. 
  const ResponsiveBottomSheetScaffold({super.key, required this.child, this.scaffoldKey, this.showAppBar = true, this.appBarLeading, this.appBarTitle = '', this.screenHeightFactor = 0.5});

  @override
  Widget build(BuildContext context) {
    if (screenHeightFactor <= 0 || screenHeightFactor > 1) {
      throw ArgumentError('screenHeightFactor must be between 0 (exclusive) and 1 (inclusive)');
    }

    return SizedBox(
        height: (MediaQuery.of(context).size.height * screenHeightFactor) + (MediaQuery.of(context).viewInsets.bottom / 2) + 16,
        child: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomInset: true, // important to allow the child to scroll since they're usually wrapped in a SingleChildScrollView
          appBar: showAppBar 
            ? AppBar(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              leading: appBarLeading,
              centerTitle: true,
              title: Text(
                appBarTitle, 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              actions: [IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              )],
            ) 
            : null,
          backgroundColor: Colors.transparent,
          body: BaseLayout(
            topPadding: false,
            child: child,
          ),
        ),
      );
  }
}