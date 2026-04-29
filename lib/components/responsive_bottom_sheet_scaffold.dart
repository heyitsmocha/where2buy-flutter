import 'package:flutter/material.dart';
import 'package:w2b_flutter/components/base_layout.dart';

/// A widget that wraps its child in a Scaffold with an AppBar, and adjusts its height to accommodate the keyboard when it appears.
class ResponsiveBottomSheetScaffold extends StatelessWidget {
  final Widget child;
  final Widget? leading;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final String title;

  /// The fraction of the screen height that the bottom sheet should take when the keyboard is not visible. The actual height will be this fraction plus the keyboard height when the keyboard is visible.<br><br>
  /// The value must be between 0 (exclusive) and 1 (inclusive). (e.g. 0.6 to take 60% of the screen height)
  /// If not provided, defaults to 0.5 (50% of the screen height)
  final double screenHeightFactor;

  const ResponsiveBottomSheetScaffold({super.key, required this.child, this.scaffoldKey, this.leading, this.title = '', this.screenHeightFactor = 0.5});

  @override
  Widget build(BuildContext context) {
    if (screenHeightFactor <= 0 || screenHeightFactor > 1) {
      throw ArgumentError('screenHeightFactor must be between 0 (exclusive) and 1 (inclusive)');
    }

    return SizedBox(
        height: (MediaQuery.of(context).size.height * screenHeightFactor) + (MediaQuery.of(context).viewInsets.bottom / 2) + 16,
        child: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            leading: leading,
            centerTitle: true,
            title: Text(
              title, 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            actions: [IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            )],
          ),
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: BaseLayout(
              topPadding: false,
              child: child
            ),
          ),
        ),
      );
  }
}