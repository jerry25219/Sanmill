import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';


import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void logExceptionDetial(final Exception e, final StackTrace s) {
  developer.log('Exception occured, details:\n $e \nStack trace:\n $s\n');
}

List<T> mergeListData<T>({
  final Iterable<T>? from,
  final Iterable<T>? to,
  bool insertFromHead = false,
  final bool Function(T element, List<T> collection)? filter,
}) {
  var result = to == null ? <T>[] : List<T>.from(to);
  if (from != null) {
    result = List.from(result);
    if (insertFromHead) {
      result.insertAll(0, filter == null ? from : from.where((final element) => filter(element, result)));
    } else {
      result.addAll(filter == null ? from : from.where((final element) => filter(element, result)));
    }
  }
  return result;
}

List<T> replaceListData<T>({
  final Iterable<T>? from,
  final Iterable<T>? to,
  required final int Function(T element, List<T> items) indexFinder,
}) {
  if (to == null) {
    return [];
  }

  final data = List<T>.from(to);
  if (from != null) {
    for (final item in from) {
      if (data.isEmpty) {
        data.add(item);
      } else {
        final index = indexFinder(item, data);
        if (index != -1) {
          data[index] = item;


        }
      }
    }
  }
  return data;
}

List<T> deleteListData<T, T1>({
  required final Iterable<T> from,
  required final Iterable<T1> values,
  required final int Function(T1 element, List<T> items) indexFinder,
}) {
  final data = List<T>.from(from);
  for (final item in values) {
    final index = indexFinder(item, data);
    if (index != -1) {
      data.removeAt(index);
    }
  }

  return data;
}

Future<Map<String, dynamic>?> getPostData({
  required final String url,
  final Map<String, dynamic>? parameters,
}) async {


  final prefs = await SharedPreferences.getInstance();
  try {
    final response = await http.post(Uri.http(url), body: parameters, headers: {'token': prefs.getString('token') ?? ''});

    if (response.statusCode != 200) {
      developer.log('Error response calling to $url, return data is: $response');
      return null;
    }

    final jsonData = json.decode(
      response.body,
    ) as Map<String, dynamic>;
    if (!(jsonData['isSuccessful'] as bool)) {
      developer.log('Error response calling to $url, return data is: $response');
      return null;
    }

    return jsonData;
  } on Exception catch (e, s) {
    logExceptionDetial(e, s);
    return null;
  }
}

Future<Map<String, dynamic>?> getHttpResult({
  required final String baseUrl,
  required final String path,
  final Map<String, dynamic>? parameters,
}) async {
  final prefs = await SharedPreferences.getInstance();
  try {
    final uri = Uri.http(baseUrl, path, parameters);
    final response = await http.get(uri, headers: {'token': prefs.getString('token') ?? ''});
    if (response.statusCode != 200) {
      return null;
    } else {
      final jsonData = json.decode(
        response.body,
      ) as Map<String, dynamic>;
      if (!(jsonData['isSuccessful'] as bool)) {
        developer.log('Error response calling to $uri, return data is: $response');
        return null;
      }

      return jsonData;
    }
  } on Exception catch (e, s) {
    logExceptionDetial(e, s);
    return null;
  }
}

String formatCount(final int value) {
  if (value < 1000) {
    return value.toString();
  } else if (value < 1000000) {
    final result = value / 1000;
    return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 2)} K';
  } else if (value < 1000 * 1000 * 1000) {
    final result = value / (1000 * 1000);
    return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 2)} M';
  } else {
    final result = value / (1000 * 1000 * 1000);
    return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 2)} G';
  }
}

Future<bool> isCachedFileExist(final String path) async {
  final cacheDir = await getTemporaryDirectory();
  return Directory('$cacheDir/$path').existsSync();
}

Future<File> getLocalFile(final String path) async {
  final cacheDir = (await getTemporaryDirectory()).path;
  return File('$cacheDir/$path');
}

T enumFromString<T>({required final List<T> enumValues, required final String value}) {
  for (final enumItem in enumValues) {
    if (enumItem.toString().split('.')[1].toLowerCase() == value.toLowerCase()) {
      return enumItem;
    }
  }
  return enumValues[0];
}


bool isNumeric(final String? s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}

bool isInt(final String? s) {
  if (s == null) {
    return false;
  }
  return int.tryParse(s) != null;
}
