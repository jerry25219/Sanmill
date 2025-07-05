import 'package:device_info_plus/device_info_plus.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'debug_print_output.dart';

final class PlatformUtilities {
  final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, dateTimeFormat: DateTimeFormat.dateAndTime),
    output: DebugPrintOutput(),
    level: Level.all,
  );

  static final PlatformUtilities _instance = PlatformUtilities._internal();
  factory PlatformUtilities() {
    return _instance;
  }
  PlatformUtilities._internal();

  Future<String> getDeviceName() async {
    try {
      final deviceInfo = await DeviceInfoPlugin().deviceInfo;
      if (deviceInfo is AndroidDeviceInfo) {
        return deviceInfo.model;
      } else if (deviceInfo is IosDeviceInfo) {
        return deviceInfo.name;
      } else if (deviceInfo is WebBrowserInfo) {
        return '${deviceInfo.browserName} on ${deviceInfo.platform}';
      }
      return 'Unknown device';
    } catch (e) {
      _logger.e('Error getting device name: $e');
      return 'Unknown device';
    }
  }

  Future<String> getDeviceType() async {
    try {
      final deviceInfo = await DeviceInfoPlugin().deviceInfo;
      if (deviceInfo is AndroidDeviceInfo) {
        return 'Android';
      } else if (deviceInfo is IosDeviceInfo) {
        return 'iOS';
      } else if (deviceInfo is WebBrowserInfo) {
        return 'Web';
      } else if (deviceInfo is WindowsDeviceInfo) {
        return 'Windows';
      } else if (deviceInfo is MacOsDeviceInfo) {
        return 'macOS';
      } else if (deviceInfo is LinuxDeviceInfo) {
        return 'Linux';
      }
      return 'Unknown';
    } catch (e) {
      _logger.e('Error getting device type: $e');
      return 'Unknown';
    }
  }

  Future<String> getDeviceOsVersion() async {
    try {
      final deviceInfo = await DeviceInfoPlugin().deviceInfo;
      if (deviceInfo is AndroidDeviceInfo) {
        return 'Android ${deviceInfo.version.release}';
      } else if (deviceInfo is IosDeviceInfo) {
        return 'iOS ${deviceInfo.systemVersion}';
      } else if (deviceInfo is WebBrowserInfo) {
        final version = deviceInfo.userAgent?.split(' ').lastWhere((e) => e.contains('/'), orElse: () => 'Unknown') ?? 'Unknown';
        return '${deviceInfo.platform ?? "Web"} $version';
      } else if (deviceInfo is WindowsDeviceInfo) {
        return 'Windows ${deviceInfo.displayVersion}';
      } else if (deviceInfo is MacOsDeviceInfo) {
        return 'macOS ${deviceInfo.osRelease}';
      } else if (deviceInfo is LinuxDeviceInfo) {
        return 'Linux ${deviceInfo.version ?? "Unknown"}';
      }
      return 'Unknown OS';
    } catch (e) {
      _logger.e('Error getting device OS version: $e');
      return 'Unknown OS';
    }
  }

  Future<String> getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      _logger.e('Error getting app version: $e');
      return 'Unknown';
    }
  }

  Future<String> getAppBuildNumber() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.buildNumber;
    } catch (e) {
      _logger.e('Error getting app build number: $e');
      return 'Unknown';
    }
  }

  Future<String> getAppName() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.appName;
    } catch (e) {
      _logger.e('Error getting app name: $e');
      return 'Unknown';
    }
  }

  Future<String> getAppPackageName() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.packageName;
    } catch (e) {
      _logger.e('Error getting app package name: $e');
      return 'Unknown';
    }
  }

  Future<String> getDeviceId() async {
    try {
      final deviceInfo = await DeviceInfoPlugin().deviceInfo;
      if (deviceInfo is AndroidDeviceInfo) {
        return deviceInfo.id;
      } else if (deviceInfo is IosDeviceInfo) {
        return deviceInfo.identifierForVendor ?? 'Unknown';
      } else if (deviceInfo is WebBrowserInfo) {
        return deviceInfo.userAgent ?? 'Unknown';
      } else if (deviceInfo is MacOsDeviceInfo) {
        return deviceInfo.systemGUID ?? 'Unknown';
      }
      return 'Unknown';
    } catch (e) {
      _logger.e('Error getting device ID: $e');
      return 'Unknown';
    }
  }

  Future<String> getDeviceModel() async {
    try {
      final deviceInfo = await DeviceInfoPlugin().deviceInfo;
      if (deviceInfo is AndroidDeviceInfo) {
        return deviceInfo.model;
      } else if (deviceInfo is IosDeviceInfo) {
        return deviceInfo.utsname.machine;
      } else if (deviceInfo is WebBrowserInfo) {
        return deviceInfo.userAgent ?? 'Unknown';
      } else if (deviceInfo is MacOsDeviceInfo) {
        return deviceInfo.model;
      }
      return 'Unknown';
    } catch (e) {
      _logger.e('Error getting device model: $e');
      return 'Unknown';
    }
  }
}
