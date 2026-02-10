import 'dart:async';

import 'package:flutter/material.dart';

abstract class UIEvent{}

abstract class BaseController<E extends UIEvent> extends ChangeNotifier {
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  final _eventController = StreamController<E>.broadcast();
  Stream<E> get eventStream => _eventController.stream;

  void emitEvent(E event) {
    if (!_isDisposed) {
      if (!_eventController.isClosed) {
        _eventController.add(event);
      }
    }
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _eventController.close();
    _isDisposed = true;
    super.dispose();
  }
}