import 'dart:io';

import 'package:logger/logger.dart';

import 'debug_print_output.dart';

class NetworkUtils {
  final _logger = Logger(printer: PrettyPrinter(methodCount: 0, dateTimeFormat: DateTimeFormat.dateAndTime), output: DebugPrintOutput(), level: Level.all);

  static final NetworkUtils _instance = NetworkUtils._internal();
  factory NetworkUtils() {
    return _instance;
  }
  NetworkUtils._internal();



  Future<String> getIPAddress() async {
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);


      if (interfaces.isEmpty) {
        _logger.w('No network interfaces found, using default IP');
        return '0.0.0.0';
      }

      for (var interface in interfaces) {
        for (var addr in interface.addresses) {

          if (!addr.address.startsWith('127.') && !addr.address.startsWith('169.254')) {
            _logger.i('Using local IP address: ${addr.address}');
            return addr.address;
          }
        }
      }

      _logger.w('No valid IP address found in network interfaces, using default IP');
      return '0.0.0.0';
    } catch (e) {
      _logger.e('Error getting IP address: $e');
      _logger.e('Error getting IP address: $e');
      return '0.0.0.0';
    }
  }
}
