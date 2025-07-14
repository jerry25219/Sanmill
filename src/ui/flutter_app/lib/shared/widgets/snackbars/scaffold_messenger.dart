




import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

extension ScaffoldMessengerExtension on ScaffoldMessengerState {
  void showSnackBarClear(String message) {

    clearSnackBars();

    showSnackBar(CustomSnackBar(message));
  }
}

class CustomSnackBar extends SnackBar {
  CustomSnackBar(String message, {super.key, super.duration})
      : super(content: Text(message));
}
