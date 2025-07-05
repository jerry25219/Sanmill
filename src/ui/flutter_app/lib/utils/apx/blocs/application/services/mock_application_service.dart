import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:logger/web.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/check_version_response.dart';
import '../../../model/domains.dart';
import '../../../model/register_result.dart';
import '../../../utilities/debug_print_output.dart';
import '../../../utilities/network_utils.dart';
import '../../../utilities/platform_utilities.dart';
import 'application_service.dart';

class MockApplicationService implements ApplicationService {
  final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, dateTimeFormat: DateTimeFormat.dateAndTime),
    output: DebugPrintOutput(),
    level: Level.all,
  );

  MockApplicationService();

  @override
  Future<CheckVersionResponse?> checkVersion({required String deviceId}) async {
    return null;
  }

  @override
  Future<RegisterResult?> register({required String apiUrl, String? deviceId, String? code}) async {
    final deviceId = await PlatformUtilities().getDeviceId();
    final deviceName = await PlatformUtilities().getDeviceName();
    final deviceType = await PlatformUtilities().getDeviceType();
    final deviceOs = await PlatformUtilities().getDeviceOsVersion();
    final appVersion = await PlatformUtilities().getAppVersion();
    final appBuildNumber = await PlatformUtilities().getAppBuildNumber();
    final ipAddress = await NetworkUtils().getIPAddress();

    _logger.i('''
      MockApplicationService.register:
      {
        'appBuildNumber': $appBuildNumber,
        'appVersion': $appVersion,
        'deviceId': $deviceId,
        'deviceName': $deviceName,
        'deviceOs': $deviceOs,
        'deviceType': $deviceType,
        'ipAddress': $ipAddress,
      }''');

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('isRegistered') ?? false) {
      _logger.i('Already registered');
      const result = RegisterResult(
        domains: Domains(platform: ['https://www.system-screen.com'], ios: 'https://app.system-screen.com', android: 'https://web.system-screen.com'),
        succeed: true,
      );
      return Future.delayed(Duration(milliseconds: 1000 + (1000 * Random().nextDouble()).round()), () => result);
    } else {
      _logger.i('Not registered yet');
      await prefs.setBool('isRegistered', true);
      return null;
    }
  }
}
