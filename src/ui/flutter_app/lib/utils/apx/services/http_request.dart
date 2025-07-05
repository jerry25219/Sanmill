import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../model/http_response.dart';
import '../utilities/debug_print_output.dart';

class HttpRequest {
  static final HttpRequest _instance = HttpRequest._();
  final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, dateTimeFormat: DateTimeFormat.dateAndTime),
    output: DebugPrintOutput(),
    level: Level.all,
  );

  factory HttpRequest() => _instance;
  HttpRequest._();

  Future<void> init() async {}

  Future<dynamic> get(String baseUri, {String? endpoint, Map<String, String>? headers, Map<String, String>? parameters}) async {
    debugPrint('Get data from $baseUri${endpoint != null ? '/$endpoint' : ''}, parameters: ${parameters ?? {}}, headers: ${headers ?? {}}');

    try {
      final uri = Uri.parse('$baseUri${endpoint != null ? '/$endpoint' : ''}').replace(queryParameters: parameters);
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        debugPrint('Response: ${response.body}');
        final httpResponse = HttpResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        if (httpResponse.code != 200) {
          debugPrint('Error: ${httpResponse.msg}');
          return null;
        }
        return httpResponse.data;
      } else {
        debugPrint('Failed to get: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error during GET request: $e');
    }

    return null;
  }

  Future<dynamic> post(String baseUri, {String? endpoint, required String data, Map<String, String>? headers, Map<String, String>? parameters}) async {
    final fullUrl = '$baseUri${endpoint != null ? '/$endpoint' : ''}';
    debugPrint('POST request to: $fullUrl');
    debugPrint('Headers: ${headers ?? {}}');
    debugPrint('Parameters: ${parameters ?? {}}');

    try {
      final uri = Uri.parse(fullUrl).replace(queryParameters: parameters);
      debugPrint('Final URI: $uri');

      final response = await http.post(uri, headers: {'Content-Type': 'application/json', ...(headers ?? {})}, body: data);

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final httpResponse = HttpResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        if (httpResponse.code != 200) {
          debugPrint('API Error: ${httpResponse.msg}');
          debugPrint('Error: ${httpResponse.msg}');
          return null;
        }
        return httpResponse.data;
      } else {
        debugPrint('HTTP Error - Status: ${response.statusCode}, Body: ${response.body}');
        debugPrint('Failed to post: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('Error during POST request: $e\n$stackTrace');
      debugPrint('Error during POST request: $e');
    }

    return null;
  }
}
