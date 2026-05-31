import 'package:flutter/services.dart';

class ScreenshotBlocker {
  static const platform = MethodChannel('lyrapay/screenshot');
  Future<void> block() async {
    try { await platform.invokeMethod('block'); } catch (_) {}
  }
}
