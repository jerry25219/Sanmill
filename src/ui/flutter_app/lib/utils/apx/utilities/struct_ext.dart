import 'dart:math';

import 'package:flutter/material.dart';

import 'json_helper.dart';


extension ColorParsing on Color {
  static Color fromJson(final Map<String, dynamic> json) => Color.fromARGB(
    getIntValueFrom(json: json, key: 'a') ?? 0,
    getIntValueFrom(json: json, key: 'r') ?? 0,
    getIntValueFrom(json: json, key: 'g') ?? 0,
    getIntValueFrom(json: json, key: 'b') ?? 0,
  );

  Map<String, dynamic> toJson() => {'a': alpha, 'r': red, 'g': green, 'b': blue};
}

extension PointParsing on Point {
  static Point fromJson(final Map<String, dynamic> json) => Point(getIntValueFrom(json: json, key: 'x') ?? 0, getIntValueFrom(json: json, key: 'y') ?? 0);

  Map<String, dynamic> toJson() => {'x': x, 'y': y};
}

extension SizeParsing on Size {
  static Size fromJson(final Map<String, dynamic> json) =>
      Size(getDoubleValueFrom(json: json, key: 'width') ?? 0, getDoubleValueFrom(json: json, key: 'height') ?? 0);

  Map<String, dynamic> toJson() => {'width': width, 'height': height};
}
