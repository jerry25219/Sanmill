




import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'logger.dart';


class StoragePermissionService {

  factory StoragePermissionService() => _instance;


  StoragePermissionService._();


  static final StoragePermissionService _instance =
      StoragePermissionService._();


  Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid || kIsWeb) {
      return true;
    }

    try {

      final PermissionStatus status = await Permission.storage.request();


      logger.i('Storage permission status: $status');

      if (status.isGranted) {
        await _prepareDirectories();
        return true;
      } else {
        logger.e('Storage permission denied');
        return false;
      }
    } catch (e) {
      logger.e('Error requesting storage permission: $e');
      return false;
    }
  }


  Future<String?> getScreenshotDirectory() async {
    if (!Platform.isAndroid || kIsWeb) {
      return null;
    }

    try {



      final Directory? extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        final Directory picturesDir = Directory('${extDir.path}/Pictures');
        if (!picturesDir.existsSync()) {

          picturesDir.createSync(recursive: true);
        }
        return picturesDir.path;
      }


      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory appPicturesDir = Directory('${appDocDir.path}/Pictures');
      if (!appPicturesDir.existsSync()) {

        appPicturesDir.createSync(recursive: true);
      }
      return appPicturesDir.path;
    } catch (e) {
      logger.e('Error getting screenshot directory: $e');
      return null;
    }
  }


  Future<void> _prepareDirectories() async {
    try {

      const List<String> standardDirs = <String>[
        '/sdcard/Pictures',
        '/storage/emulated/0/Pictures',
      ];


      for (final String path in standardDirs) {
        final Directory dir = Directory(path);
        if (!dir.existsSync()) {

          try {
            dir.createSync(recursive: true);
            logger.i('Created directory: $path');
          } catch (e) {
            logger.w('Could not create directory: $path - $e');
          }
        } else {
          logger.i('Directory exists: $path');
        }
      }


      final String? appDir = await getScreenshotDirectory();
      logger.i('App screenshot directory: $appDir');
    } catch (e) {
      logger.e('Error preparing directories: $e');
    }
  }




  static Future<bool> requestPermission() async {
    return StoragePermissionService().requestStoragePermission();
  }


  static Future<String?> getDirectory() async {
    return StoragePermissionService().getScreenshotDirectory();
  }
}
