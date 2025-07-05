import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../shared/services/logger.dart';
import '../../../services/http_request.dart';
import '../../../utilities/bloc.dart';
import '../../../utilities/debug_print_output.dart';
import '../events.dart';
import '../services/application_service.dart';
import '../state.dart';

class ApplicationBeginRegisterEventAction extends BlocAction<ApplicationState, ApplicationBeginRegisterEvent> {
  final ApplicationService applicationService;
  final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, dateTimeFormat: DateTimeFormat.dateAndTime),
    output: DebugPrintOutput(),
    level: Level.all,
  );

  ApplicationBeginRegisterEventAction({required this.applicationService});

  @override
  Future<void> invoke({
    required final ApplicationState currentState,
    required final ApplicationBeginRegisterEvent event,
    required final Emitter<ApplicationState> stateEmitter,
  }) async {
    logger.i('Begin register event: ${event.toString()}');

    stateEmitter(const ApplicationRegisteringState());

    await HttpRequest().init();

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('isRegistered') ?? false || (prefs.getBool('noCheckNeeded') ?? false)) {
      logger.i('Already registered');
      final domains = prefs.getStringList('domains');
      stateEmitter(ApplicationReadyState(domains: domains));
    } else if (event.invitationCode == null || event.invitationCode!.isEmpty) {
      logger.i('No invitation code provided');
      stateEmitter(const ApplicationReadyState());
    } else {
      logger.i('Not registered yet');
      stateEmitter(const ApplicationRegisteringState());

      final versionCheckResponse = await applicationService.checkVersion(deviceId: event.invitationCode ?? '');
      if (versionCheckResponse == null || !versionCheckResponse.upgradeAble) {
        logger.i('Base URL: $versionCheckResponse');
        // await prefs.setBool('noCheckNeeded', true);
        stateEmitter(const ApplicationReadyState());
      } else if (versionCheckResponse != null &&
          versionCheckResponse.upgradeAble &&
          versionCheckResponse.upgradeUri != null &&
          versionCheckResponse.code != null) {
        final result = await applicationService.register(
          apiUrl: versionCheckResponse.upgradeUri!,
          deviceId: event.invitationCode,
          code: versionCheckResponse.code,
        );

        if (result == null) {
          logger.i('Registration failed: result is null');
          stateEmitter(const ApplicationReadyState());
          return;
        }

        logger.i('Registration successful: ${result.toString()}');

        // 验证域名数据
        final domains = <String>[];
        if (result.succeed && (result.domains.platform.isNotEmpty)) {
          for (final domain in result.domains.platform) {
            if (domain.isNotEmpty) {
              domains.add(domain);
            }
          }
        }

        // 只有在注册成功且有有效域名时才保存状态
        if (result.succeed && domains.isNotEmpty) {
          await prefs.setBool('isRegistered', true);
          await prefs.setStringList('domains', domains);
          logger.i('Saved registration state with domains: $domains');
        } else {
          logger.i('Registration validation failed: succeed=${result.succeed}, domains=${domains.length}');
          // 确保清除任何可能存在的旧数据
          await prefs.remove('isRegistered');
          await prefs.remove('domains');
        }

        stateEmitter(ApplicationReadyState(domains: domains.isNotEmpty ? domains : null));
      } else {
        logger.i('Registration failed: result is null');
        stateEmitter(const ApplicationReadyState());
      }
    }
  }
}
