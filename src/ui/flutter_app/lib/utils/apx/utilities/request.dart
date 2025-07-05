import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';


class HttpRequest {
  static final HttpRequest _instance = HttpRequest._internal();

  factory HttpRequest() {
    return _instance;
  }

  HttpRequest._internal();

  Future<http.Response> get(String api, {Map<String, String>? parameters}) async {
    var uri = Uri.parse(Constants.webAPIAddress + api);
    if (parameters != null) {
      uri = uri.replace(queryParameters: parameters);
    }
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 3));
      return response;
    } on TimeoutException catch (_) {
      return http.Response(jsonEncode({'error': 'timeOut'}), 408);
    } on Exception catch (e) {
      return http.Response(jsonEncode({'error': e.toString()}), 500);
    }
  }

  Future<http.Response> post(String api, {required Map<String, dynamic> data}) async {
    final response = await http.post(Uri.parse(api), headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
    return response;
  }
}
