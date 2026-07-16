import 'package:flutter/material.dart';

class ShowSnackBar {
  static void _show(
    BuildContext context,
    String message,
    SnackBarAction? action, 
    { Color? backgroundColor }
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        backgroundColor: backgroundColor,
      ),
    );
  }

  static void success(BuildContext context, String message, {SnackBarAction? action}) {
    _show(context, message, action, backgroundColor: Colors.green);
  }
  
  static void error(BuildContext context, String message, {SnackBarAction? action}) {
    _show(context, message, action, backgroundColor: Colors.red);
  }

  static void info(BuildContext context, String message, {SnackBarAction? action}) {
    _show(context, message, action);
  }
}