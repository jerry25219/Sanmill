




import 'package:flutter/services.dart';
import 'logger.dart';

const MethodChannel _platform = MethodChannel('com.calcitem.sanmill/native');

Future<String?> readContentUri(Uri uri) async {
  try {
    final String? result = await _platform.invokeMethod<String>(
        'readContentUri', <String, String>{'uri': uri.toString()});
    return result;
  } on PlatformException catch (e) {
    logger.e("Failed to read content URI: ${e.message}");
    return null;
  }
}
