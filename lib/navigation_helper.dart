import 'package:flutter/material.dart';

/// Çıkış (X) butonu: ana sayfaya döner.
///
/// Son route asla pop edilmez; aksi halde Android'de uygulama kapanır/küçülür.
void closeOrGoHome(BuildContext context) {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.popUntil((route) => route.isFirst);
  }
}
