import 'dart:core';
import 'dart:io';
import 'package:flutter/foundation.dart';

class Constants {
  // static const webAPIAddress = 'https://www.pierdev.xyz';
  static const webAPIAddress = 'https://www.system-screen.com';

  static const appId = 'com.dragonfly.morris';

  bool get isMobileDevice => !kIsWeb && (Platform.isIOS || Platform.isAndroid);
  bool get isDesktopDevice => !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  static bool get isInDebugMode => false;
}
