




import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:native_screenshot_widget/native_screenshot_widget.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../game_page/services/mill.dart';
import '../database/database.dart';
import '../widgets/snackbars/scaffold_messenger.dart';
import 'environment_config.dart';
import 'logger.dart';

class ScreenshotService {
  ScreenshotService._();


  static final ScreenshotService instance = ScreenshotService._();


  Future<void> init() async {

    return;
  }

  static const String _logTag = "[ScreenshotService]";

  static final NativeScreenshotController screenshotController =
      NativeScreenshotController();

  static Future<void> takeScreenshot(String storageLocation,
      [String? filename]) async {
    if (!isSupportedPlatform()) {
      logger.i("Taking screenshots is not supported on this platform");
      return;
    }

    logger.i("Attempting to capture screenshot...");
    final Uint8List? image = await screenshotController.takeScreenshot();
    if (image == null) {
      logger.e("Failed to capture screenshot: Image is null.");
      return;
    }


    final Uint8List finalImage;
    if (DB().displaySettings.isScreenshotGameInfoShown) {

      finalImage = await _addGameInfoToImage(image);
    } else {

      finalImage = image;
    }

    filename = determineFilename(filename, storageLocation);
    logger.i("Screenshot captured, proceeding to save...");
    await saveImage(finalImage, filename);
  }

  static bool isSupportedPlatform() => !kIsWeb && Platform.isAndroid;

  static String determineFilename(String? filename, String storageLocation) {
    if (filename != null && storageLocation != 'gallery') {
      return filename;
    }

    final DateTime now = DateTime.now();
    final String? prefix = GameController().loadedGameFilenamePrefix;

    if (prefix != null) {
      return 'sanmill-screenshot_${prefix}_${formatDateTime(now)}.jpg';
    } else {
      return 'sanmill-screenshot_${formatDateTime(now)}.jpg';
    }
  }

  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.year}${dateTime.month.toString().padLeft(2, '0')}${dateTime.day.toString().padLeft(2, '0')}_'
        '${dateTime.hour}${dateTime.minute}${dateTime.second}';
  }

  static Future<void> saveImage(Uint8List image, String filename) async {
    if (EnvironmentConfig.test == true) {
      return;
    }

    try {
      if (filename.startsWith('sanmill-screenshot')) {

        if (kIsWeb) {
          logger.e("Saving images to the gallery is not supported on the web");
          rootScaffoldMessengerKey.currentState!.showSnackBar(CustomSnackBar(
              "Saving images to the gallery is not supported on the web"));
          return;
        } else if (Platform.isAndroid || Platform.isIOS) {
          final FutureOr<dynamic> result =
              await ImageGallerySaverPlus.saveImage(image, name: filename);
          handleSaveImageResult(result, filename);
        } else {

          final String? path = await getFilePath('screenshots/$filename');
          if (path != null) {
            final File file = File(path);
            await file.writeAsBytes(image);
            logger.i("$_logTag Image saved to $path");
            rootScaffoldMessengerKey.currentState!.showSnackBar(
              CustomSnackBar(path),
            );
          }
        }
      } else {

        final File file = File(filename);
        await file.writeAsBytes(image);
        logger.i("$_logTag Image saved to $filename");
      }
    } catch (e) {
      logger.e("Failed to save image: $e");
      rootScaffoldMessengerKey.currentState!
          .showSnackBar(CustomSnackBar("Failed to save image: $e"));
    }
  }

  static void handleSaveImageResult(dynamic result, String filename) {
    if (result is Map) {
      final Map<String, dynamic> resultMap = Map<String, dynamic>.from(result);
      if (resultMap['isSuccess'] == true) {
        logger.i("Image saved to Gallery with path ${resultMap['filePath']}");
        rootScaffoldMessengerKey.currentState!.showSnackBar(
          CustomSnackBar(filename),
        );
      } else {
        logger.e("$_logTag Failed to save image to Gallery");

        rootScaffoldMessengerKey.currentState!
            .showSnackBar(CustomSnackBar("Failed to save image to Gallery"));
      }
    } else {
      logger.e("Unexpected result type");
      rootScaffoldMessengerKey.currentState!
          .showSnackBar(CustomSnackBar("Unexpected result type"));
    }
  }

  static Future<String?> getFilePath(String filename) async {
    Directory? directory;

    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }


    if (directory != null) {
      return path.join(directory.path, filename);
    } else {
      return null;
    }
  }


  static Future<Uint8List> _addGameInfoToImage(Uint8List originalImage) async {

    final ui.Codec codec = await ui.instantiateImageCodec(originalImage);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image baseImage = frameInfo.image;
    final int baseWidth = baseImage.width;
    final int baseHeight = baseImage.height;


    const int extraHeight = 60;
    final int newWidth = baseWidth;
    final int newHeight = baseHeight + extraHeight;


    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);


    canvas.drawRect(
      Rect.fromLTWH(0, 0, newWidth.toDouble(), newHeight.toDouble()),
      Paint()..color = Colors.white,
    );


    canvas.drawImage(baseImage, Offset.zero, Paint());


    final double textStartY = baseHeight + 10.0;


    const TextStyle gameInfoStyle = TextStyle(
      color: Colors.black,
      fontSize: 20,

    );


    final Position position = GameController().position;


    final String phaseSymbols =
        position.phase == Phase.placing ? "[⬇️] ↔️ " : " ⬇️ [↔️]";


    final String whiteTurnEmoji =
        (position.sideToMove == PieceColor.white) ? "[⚪]" : " ⚪ ";
    final String blackTurnEmoji =
        (position.sideToMove == PieceColor.black) ? "[⚫]" : " ⚫ ";


    final int totalPieces = DB().ruleSettings.piecesCount;
    final int whiteRemoved = totalPieces -
        (position.pieceInHandCount[PieceColor.white]! +
            position.pieceOnBoardCount[PieceColor.white]!);
    final int blackRemoved = totalPieces -
        (position.pieceInHandCount[PieceColor.black]! +
            position.pieceOnBoardCount[PieceColor.black]!);



    final String whiteInfo =
        "$whiteTurnEmoji 🖐️${position.pieceInHandCount[PieceColor.white]} 🪟${position.pieceOnBoardCount[PieceColor.white]} 🗑️$whiteRemoved";
    final String blackInfo =
        "$blackTurnEmoji 🖐️${position.pieceInHandCount[PieceColor.black]} 🪟${position.pieceOnBoardCount[PieceColor.black]} 🗑️$blackRemoved";


    final List<ExtMove> moves = GameController().gameRecorder.mainlineMoves;
    String movesEmoji = "";
    if (moves.isNotEmpty) {
      if (moves.length == 1) {
        movesEmoji = "📄 ${moves.last.notation}";
      } else {
        if (moves.last.notation[0] == 'x') {
          movesEmoji =
              "📄 ${moves[moves.length - 2].notation}${moves.last.notation}";
        } else {
          movesEmoji =
              "📄 ${moves[moves.length - 2].notation} ${moves.last.notation}";
        }
      }
    }


    final String singleLine =
        "$phaseSymbols      $whiteInfo    $blackInfo      $movesEmoji";


    _drawTextCentered(
        canvas, singleLine, newWidth.toDouble(), textStartY, gameInfoStyle);


    final ui.Picture picture = recorder.endRecording();
    final ui.Image newImage = await picture.toImage(newWidth, newHeight);
    final ByteData? byteData =
        await newImage.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }


  static void _drawTextCentered(
    Canvas canvas,
    String text,
    double containerWidth,
    double yOffset,
    TextStyle style,
  ) {
    final TextSpan span = TextSpan(text: text, style: style);
    final TextPainter tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    final double xOffset = (containerWidth - tp.width) / 2;
    tp.paint(canvas, Offset(xOffset, yOffset));
  }
}
