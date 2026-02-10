import 'dart:async';

import 'package:flutter/material.dart';

abstract class BaseController<T> extends ChangeNotifier {
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  final _eventController = StreamController<T>.broadcast();
  Stream<T> get eventStream => _eventController.stream;

  void emitEvent(T event) {
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