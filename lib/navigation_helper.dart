import 'package:flutter/material.dart';

void closeOrGoHome(BuildContext context) {
  final navigator = Navigator.of(context);

  // Avoid popping the last route, which can close/minimize the app on Android.
  if (navigator.canPop()) {
    navigator.pop();
    return;
  }

  navigator.pushNamedAndRemoveUntil('/', (route) => false);
}

