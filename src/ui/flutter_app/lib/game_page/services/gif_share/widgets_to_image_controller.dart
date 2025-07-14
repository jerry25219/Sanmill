




import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../shared/database/database.dart';
import '../../../shared/services/logger.dart';

class WidgetsToImageController {
  GlobalKey containerKey = GlobalKey();


  Future<Uint8List?> capture() async {
    try {

      final RenderRepaintBoundary? boundary = containerKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      final double ratio =
          DB().generalSettings.gameScreenRecorderPixelRatio / 100;


      final ui.Image image = await boundary!.toImage(
        pixelRatio: ratio,
      );


      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List? pngBytes = byteData?.buffer.asUint8List();
      return pngBytes;
    } catch (e) {
      logger.e(e);
      return null;
    }
  }
}
