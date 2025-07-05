// ignore_for_file: avoid_dynamic_calls

import 'dart:math';
import 'package:flutter/material.dart';

typedef JsonNode = Map<String, dynamic>;
typedef JsonArray = List<dynamic>;

T? getValueFrom<T>({
  required final Map<String, dynamic> json,
  required final String key,
}) {
  final node = getJsonNodeAtPath(json, key);
  if (node == null) {
    return null;
  }

  return node as T?;
}

List<T>? getListValueFrom<T>({
  required final Map<String, dynamic> json,
  required final String key,
}) {
  final node = getJsonNodeAtPath(json, key);
  if (node == null) {
    return null;
  }

  return (node as List<dynamic>?)?.cast<T>();
}

String? getStringValueFrom({
  required final Map<String, dynamic> json,
  required final String key,
}) {
  final node = getJsonNodeAtPath(json, key);
  if (node == null) {
    return null;
  }

  // key = key.split('/').last;

  return node.toString();
}

bool? getBoolValueFrom({
  required final Map<String, dynamic> json,
  required final String key,
}) =>
    (getStringValueFrom(json: json, key: key) ?? 'false') == 'true';

int? getIntValueFrom({
  required final Map<String, dynamic> json,
  required final String key,
}) {
  final value = getStringValueFrom(
    json: json,
    key: key,
  );
  if (value == null) {
    return null;
  }

  return int.tryParse(value);
}

double? getDoubleValueFrom({
  required final Map<String, dynamic> json,
  required final String key,
}) {
  final value = getStringValueFrom(
    json: json,
    key: key,
  );
  if (value == null) {
    return null;
  }

  return double.tryParse(value);
}

DateTime? getDateValueFrom({
  required final Map<String, dynamic> json,
  required final String key,
}) {
  final value = getStringValueFrom(
    json: json,
    key: key,
  );
  if (value == null) {
    return null;
  }

  return DateTime.tryParse(value);
}

Color? getColorValueFrom({
  required final Map<String, dynamic> json,
  required final String key,
}) {
  final node = getJsonNodeAtPath(json, key);
  if (node == null) {
    return null;
  }

  return Color.fromARGB(
    node['a'] as int? ?? 0,
    node['r'] as int? ?? 0,
    node['g'] as int? ?? 0,
    node['b'] as int? ?? 0,
  );
}

Point? getPointValueFrom({
  required final Map<String, dynamic> json,
  required final String key,
}) {
  final node = getJsonNodeAtPath(json, key);
  if (node == null) {
    return null;
  }

  return Point(
    node['x'] as int? ?? 0,
    node['y'] as int? ?? 0,
  );
}

Size? getSizeValueFrom({
  required final Map<String, dynamic> json,
  required final String key,
}) {
  final node = getJsonNodeAtPath(json, key);
  if (node == null) {
    return null;
  }

  return Size(
    node['width'] as double? ?? 0,
    node['height'] as double? ?? 0,
  );
}

bool validJsonData({
  required final Map<String, dynamic> json,
  required final Map<String, Type> properties,
}) {
  for (final property in properties.entries) {
    final isOptional = property.key.characters.last == '?';
    final path = isOptional ? property.key.substring(0, property.key.length - 1) : property.key;

    final value = getJsonNodeAtPath(json, path);
    if (value == null) {
      if (isOptional) {
        continue;
      } else {
        return false;
      }
    }

    if (value.runtimeType != property.value) {
      return false;
    }
  }
  return true;
}

dynamic getJsonNodeAtPath(final Map<String, dynamic> json, final String path) {
  final nodeLevels = path.split('/');
  dynamic node = json;
  if (nodeLevels.length > 1) {
    // nodeLevels = nodeLevels.sublist(0, nodeLevels.length - 1);

    for (final nodeName in nodeLevels) {
      node = node[nodeName];
      if (node == null) {
        return null;
      }
    }
  } else {
    return json[path];
  }

  if (node == null) {
    return null;
  }

  return node;
}
