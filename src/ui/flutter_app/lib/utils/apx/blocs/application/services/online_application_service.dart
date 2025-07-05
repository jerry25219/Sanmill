import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../../constants.dart';
import '../../../model/check_version_parameter.dart';
import '../../../model/check_version_response.dart';
import '../../../model/register_data.dart';
import '../../../model/register_result.dart';
import '../../../services/http_request.dart';
import '../../../utilities/crypto_utils.dart';
import '../../../utilities/debug_print_output.dart';
import '../../../utilities/platform_utilities.dart';
import 'application_service.dart';


class OnlineApplicationService implements ApplicationService {
  final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, dateTimeFormat: DateTimeFormat.dateAndTime),
    output: DebugPrintOutput(),
    level: Level.all,
  );

  @override
  Future<CheckVersionResponse?> checkVersion({required String deviceId}) async {
    try {
      final parameters = CheckVersionParameter(
        appId: await PlatformUtilities().getAppPackageName(),
        deviceType: await PlatformUtilities().getDeviceType(),
        deviceOs: await PlatformUtilities().getDeviceOsVersion(),
        appVersion: await PlatformUtilities().getAppVersion(),
        appBuildNumber: await PlatformUtilities().getAppBuildNumber(),
      );

      final crypto = CryptoUtils();
      final aesKey = crypto.generateAesKey();

      debugPrint('''
        OnlineApplicationService.checkVersion:
        {
          'webAPIAddress': ${Constants.webAPIAddress},
          'appId': ${parameters.appId},
          'deviceType': ${parameters.deviceType},
          'deviceOs': ${parameters.deviceOs},
          'appVersion': ${parameters.appVersion},
          'appBuildNumber': ${parameters.appBuildNumber},
          'deviceId': $deviceId,
        }''');

      final response = await HttpRequest().post(
        Constants.webAPIAddress,
        endpoint: 'api/v1/auth/app/check/version',
        data: crypto.encryptWithAes(jsonEncode(parameters.toJson()), aesKey),
        headers: {'encrypt-key': crypto.encrypt(aesKey.base64), 'deviceId': deviceId},
      );

      if (response != null) {
        debugPrint('CheckVersion response received successfully');
        return CheckVersionResponse.fromJson(response as Map<String, dynamic>);
      } else {
        debugPrint('CheckVersion response is null');
      }
    } catch (e, stackTrace) {
      debugPrint('Error checking version: $e\n$stackTrace');
      debugPrint('Error checking version: $e');
    }
    return null;
  }

  @override
  Future<RegisterResult?> register({required String apiUrl, String? deviceId, String? code}) async {
    final parameters = RegisterData(
      invitationCode: code,
      deviceId: deviceId,
      // deviceId: await PlatformUtilities().getDeviceId(),
      // deviceType: await PlatformUtilities().getDeviceType(),
      // deviceOs: await PlatformUtilities().getDeviceOsVersion(),
      // appVersion: await PlatformUtilities().getAppVersion(),
      // appBuildNumber: await PlatformUtilities().getAppBuildNumber(),
    );

    debugPrint('''
      OnlineApplicationService.register:
      {
        'apiUrl': $apiUrl,
        'code': $code,
        'deviceId': $deviceId,
      }''');

    // post data to server
    try {
      final data = await HttpRequest().get(apiUrl, headers: {...parameters.toJson().cast()});
      if (data == null) {
        debugPrint('Error: No data received from server');
        debugPrint('Error: No data received from server');
        return null;
      } else {
        debugPrint('Register response received successfully');
        return RegisterResult.fromJson(data as Map<String, dynamic>);
      }
    } catch (e, stackTrace) {
      debugPrint('Error during registration: $e\n$stackTrace');
      debugPrint('Error during registration: $e');
      return null;
    }
  }
}
