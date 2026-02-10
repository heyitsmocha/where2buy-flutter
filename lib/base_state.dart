import 'dart:async';

import 'package:flutter/material.dart';
import 'package:w2b_flutter/base_controller.dart';

/// Generic state class for StatefulWidgets that integrates with a `BaseController`
/// to handle UI events and state management.
abstract class BaseState<W extends StatefulWidget, C extends BaseController<E>, E extends UIEvent> extends State<W> {
  late final C _controller;
  C get controller => _controller;

  /// Subclasses must implement this method to provide their specific controller instance.<br><br>
  /// Example: `XYZController initController() => XYZController();`
  C initController();

  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _controller = initController();
    _subscription = _controller.eventStream.listen((event) {
      _onUIEvent(event);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Subclasses must implement this method to handle UI events emitted by the controller.<br><br>
  /// BaseState will check if the widget is still mounted before calling this method.<br><br>
  /// Example:<br>
  /// ```dart
  /// @override
  /// void handleUIEvent(MyUiEvent event) {
  ///   switch (event) {
  ///     case MyUiEvent.showErrorSnackbar:
  ///       // Do stuff here
  ///       break;
  ///   }
  /// }
  void handleUIEvent(E event);

  void _onUIEvent(E event) {
    if (!mounted) return;
    handleUIEvent(event);
  }
}