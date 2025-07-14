






import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import '../../shared/database/database.dart';
import '../../shared/services/logger.dart';
import 'mill.dart';


class BoardRecognitionDebugInfo {
  BoardRecognitionDebugInfo({
    this.originalImage,
    this.processedImage,
    this.boardRect,
    this.boardColor,
    this.characteristics,
    this.colorProfile,
    this.boardMask,
    this.boardPoints = const <BoardPoint>[],
    this.linesDetectionImage,
  });


  final img.Image? originalImage;


  final img.Image? processedImage;


  final math.Rectangle<int>? boardRect;


  final Rgb? boardColor;


  final ImageCharacteristics? characteristics;


  final ColorProfile? colorProfile;


  final List<List<bool>>? boardMask;


  final List<BoardPoint> boardPoints;


  final img.Image? linesDetectionImage;


  BoardRecognitionDebugInfo copyWith({
    img.Image? originalImage,
    img.Image? processedImage,
    math.Rectangle<int>? boardRect,
    Rgb? boardColor,
    ImageCharacteristics? characteristics,
    ColorProfile? colorProfile,
    List<List<bool>>? boardMask,
    List<BoardPoint>? boardPoints,
    img.Image? linesDetectionImage,
  }) {
    return BoardRecognitionDebugInfo(
      originalImage: originalImage ?? this.originalImage,
      processedImage: processedImage ?? this.processedImage,
      boardRect: boardRect ?? this.boardRect,
      boardColor: boardColor ?? this.boardColor,
      characteristics: characteristics ?? this.characteristics,
      colorProfile: colorProfile ?? this.colorProfile,
      boardMask: boardMask ?? this.boardMask,
      boardPoints: boardPoints ?? this.boardPoints,
      linesDetectionImage: linesDetectionImage ?? this.linesDetectionImage,
    );
  }


  static Uint8List? imageToBytes(img.Image? image) {
    if (image == null) {
      return null;
    }
    return Uint8List.fromList(img.encodeJpg(image));
  }
}


class _Point {
  _Point(this.x, this.y);

  final int x, y;
}







class BoardImageRecognitionService {

  static const int _processingWidth =
      800;
  static const double _pieceThreshold =
      0.25;
  static const double _contrastEnhancementFactor =
      1.8;
  static const double _boardColorDistanceThreshold =
      28.0;
  static const double _pieceColorMatchThreshold =
      30.0;


  static List<BoardPoint> _lastDetectedPoints = <BoardPoint>[];
  static int _processedImageWidth = 0;
  static int _processedImageHeight = 0;


  static BoardRecognitionDebugInfo _lastDebugInfo = BoardRecognitionDebugInfo();



  static double contrastEnhancementFactor = _contrastEnhancementFactor;


  static double pieceThreshold = _pieceThreshold;


  static double boardColorDistanceThreshold = _boardColorDistanceThreshold;


  static double pieceColorMatchThreshold = _pieceColorMatchThreshold;


  static int whiteBrightnessThreshold = _whiteBrightnessThresholdBase;


  static int blackBrightnessThreshold = _blackBrightnessThresholdBase;


  static double blackSaturationThreshold = _blackSaturationThreshold;


  static int blackColorVarianceThreshold = _blackColorVarianceThreshold;




  static void updateParameters({
    double? contrastEnhancementFactor,
    double? pieceThreshold,
    double? boardColorDistanceThreshold,
    double? pieceColorMatchThreshold,
    int? whiteBrightnessThreshold,
    int? blackBrightnessThreshold,
    double? blackSaturationThreshold,
    int? blackColorVarianceThreshold,
  }) {
    if (contrastEnhancementFactor != null) {
      BoardImageRecognitionService.contrastEnhancementFactor =
          contrastEnhancementFactor;
    }
    if (pieceThreshold != null) {
      BoardImageRecognitionService.pieceThreshold = pieceThreshold;
    }
    if (boardColorDistanceThreshold != null) {
      BoardImageRecognitionService.boardColorDistanceThreshold =
          boardColorDistanceThreshold;
    }
    if (pieceColorMatchThreshold != null) {
      BoardImageRecognitionService.pieceColorMatchThreshold =
          pieceColorMatchThreshold;
    }
    if (whiteBrightnessThreshold != null) {
      BoardImageRecognitionService.whiteBrightnessThreshold =
          whiteBrightnessThreshold;
    }
    if (blackBrightnessThreshold != null) {
      BoardImageRecognitionService.blackBrightnessThreshold =
          blackBrightnessThreshold;
    }
    if (blackSaturationThreshold != null) {
      BoardImageRecognitionService.blackSaturationThreshold =
          blackSaturationThreshold;
    }
    if (blackColorVarianceThreshold != null) {
      BoardImageRecognitionService.blackColorVarianceThreshold =
          blackColorVarianceThreshold;
    }

    logger.i("Recognition parameters updated");
  }



  static List<BoardPoint> get lastDetectedPoints => _lastDetectedPoints;


  static int get processedImageWidth => _processedImageWidth;

  static int get processedImageHeight => _processedImageHeight;



  static BoardRecognitionDebugInfo get lastDebugInfo => _lastDebugInfo;


  static const int _whiteBrightnessThresholdBase = 170;
  static const int _blackBrightnessThresholdBase = 135;









  static const double _blackSaturationThreshold =
      0.25;
  static const int _blackColorVarianceThreshold =
      40;








  static Future<Map<int, PieceColor>> recognizeBoardFromImage(
      Uint8List imageBytes) async {

    final Map<int, PieceColor> result = <int, PieceColor>{};
    for (int i = 0; i < 24; i++) {
      result[i] = PieceColor.none;
    }

    try {

      final img.Image? decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) {
        logger.e("Failed to decode image for board recognition");
        return result;
      }



      final img.Image originalImageCopy = img.copyResize(decodedImage,
          width: decodedImage.width, height: decodedImage.height);

      _lastDebugInfo = BoardRecognitionDebugInfo(
        originalImage: originalImageCopy,
      );


      img.Image processImage = _resizeForProcessing(decodedImage);


      final img.Image unprocessedImage = img.copyResize(processImage,
          width: processImage.width, height: processImage.height);


      _processedImageWidth = processImage.width;
      _processedImageHeight = processImage.height;


      final img.Image resizedImageCopy = img.copyResize(processImage,
          width: processImage.width, height: processImage.height);

      _lastDebugInfo = _lastDebugInfo.copyWith(
        processedImage: resizedImageCopy,
      );


      processImage = _enhanceImageForProcessing(
        processImage,
        contrastEnhancementFactor: contrastEnhancementFactor,
      );


      final img.Image enhancedImageCopy = img.copyResize(processImage,
          width: processImage.width, height: processImage.height);

      _lastDebugInfo = _lastDebugInfo.copyWith(
        processedImage: enhancedImageCopy,
      );


      final ImageCharacteristics characteristics = _analyzeImageCharacteristics(
        processImage,
        whiteBrightnessThresholdBase: whiteBrightnessThreshold,
        blackBrightnessThresholdBase: blackBrightnessThreshold,
        pieceThreshold: pieceThreshold,
      );
      logger.i(
          "Image analysis: brightness=${characteristics.averageBrightness.toStringAsFixed(1)}, "
          "isDark=${characteristics.isDarkBackground}, contrast=${characteristics.isHighContrast}");


      _lastDebugInfo = _lastDebugInfo.copyWith(
        characteristics: characteristics,
      );


      if (!characteristics.isHighContrast &&
          characteristics.contrastRatio < 1.5) {
        logger
            .i("Low contrast image detected, applying additional enhancement");

        processImage = _enhanceLowContrastImage(processImage);


        final img.Image enhancedContrastImageCopy = img.copyResize(processImage,
            width: processImage.width, height: processImage.height);

        _lastDebugInfo = _lastDebugInfo.copyWith(
          processedImage: enhancedContrastImageCopy,
        );
      }


      final math.Rectangle<int>? boardRect =
          _findBoardBoundingBox(processImage);


      math.Rectangle<int>? finalBoardRect = boardRect;
      if (finalBoardRect != null &&
          (finalBoardRect.width < 200 || finalBoardRect.height < 200)) {
        logger.w(
            "Detected board area (${finalBoardRect.width}x${finalBoardRect.height}) is smaller than 200x200. Discarding and using full image.");
        finalBoardRect = null;
      }


      if (finalBoardRect == null) {

        if (boardRect != null) {

        } else {
          logger.w(
              "Board detection failed using all methods. Falling back to using the entire image as the board area.");
        }


        final int squareSize =
            math.min(_processedImageWidth, _processedImageHeight);


        final int leftOffset = (_processedImageWidth - squareSize) ~/ 2;
        final int topOffset = (_processedImageHeight - squareSize) ~/ 2;

        finalBoardRect =
            math.Rectangle<int>(leftOffset, topOffset, squareSize, squareSize);


        _lastDebugInfo = _lastDebugInfo.copyWith(boardRect: finalBoardRect);
      } else {

        logger.i("Board bounding box found and validated: $finalBoardRect");

      }




      final List<BoardPoint> boardPoints = createRefinedBoardPoints(
          processImage, finalBoardRect);


      _lastDetectedPoints = boardPoints;


      _lastDebugInfo = _lastDebugInfo.copyWith(
        boardPoints: boardPoints,
      );


      final Rgb boardColor = _estimateBoardColor(
          unprocessedImage, finalBoardRect);


      _lastDebugInfo = _lastDebugInfo.copyWith(
        boardColor: boardColor,
      );



      final ColorProfile colorProfile =
          _buildColorProfile(unprocessedImage, boardPoints);
      logger.i(
          "Color profile: white=${colorProfile.whiteMean.toStringAsFixed(1)}, "
          "black=${colorProfile.blackMean.toStringAsFixed(1)}, empty=${colorProfile.emptyMean.toStringAsFixed(1)}");


      _lastDebugInfo = _lastDebugInfo.copyWith(
        colorProfile: colorProfile,
      );





      final Color configuredWhiteColor = DB().colorSettings.whitePieceColor;
      final Color configuredBlackColor = DB().colorSettings.blackPieceColor;
      final Rgb configuredWhiteRgb = _rgbFromColor(configuredWhiteColor);
      final Rgb configuredBlackRgb = _rgbFromColor(configuredBlackColor);

      for (int i = 0; i < 24 && i < boardPoints.length; i++) {
        final BoardPoint point = boardPoints[i];
        final PieceColor detectedColor = _detectPieceAtPoint(
            unprocessedImage,
            point,
            characteristics,
            colorProfile,
            boardColor,
            configuredWhiteRgb,
            configuredBlackRgb,
            pieceColorMatchThreshold: pieceColorMatchThreshold,
            boardColorDistanceThreshold: boardColorDistanceThreshold,
            blackSaturationThreshold: blackSaturationThreshold,
            blackColorVarianceThreshold: blackColorVarianceThreshold);
        result[i] = detectedColor;
      }


      final Map<int, PieceColor> enhancedResult =
          _applyConsistencyRules(result);


      int whiteCount = 0, blackCount = 0;
      for (final PieceColor color in enhancedResult.values) {
        if (color == PieceColor.white) {
          whiteCount++;
        }
        if (color == PieceColor.black) {
          blackCount++;
        }
      }
      logger.i("FINAL COUNT   white=$whiteCount, black=$blackCount   "
          "(detected from ${boardPoints.length} lattice points)");

      return enhancedResult;
    } catch (e, stacktrace) {
      logger.e("Error recognizing board: $e\n$stacktrace");
      return result;
    }
  }




  static img.Image _enhanceLowContrastImage(img.Image image) {
    logger.w(
        "_enhanceLowContrastImage is not implemented. Returning original image.");

    return img.adjustColor(image, contrast: 1.5);
  }


  static Rgb _estimateBoardColor(
      img.Image image, math.Rectangle<int>? boardRect) {
    logger.w("_estimateBoardColor is not implemented. Returning default grey.");
    if (boardRect == null) {
      return const Rgb(128, 128, 128);
    }


    int rSum = 0, gSum = 0, bSum = 0, count = 0;
    final int centerX = boardRect.left + boardRect.width ~/ 2;
    final int centerY = boardRect.top + boardRect.height ~/ 2;
    final int offset = boardRect.width ~/ 10;

    final List<math.Point<int>> samplePoints = <math.Point<int>>[
      math.Point<int>(centerX + offset, centerY + offset),
      math.Point<int>(centerX - offset, centerY + offset),
      math.Point<int>(centerX + offset, centerY - offset),
      math.Point<int>(centerX - offset, centerY - offset),
    ];

    for (final math.Point<int> p in samplePoints) {
      if (p.x >= 0 && p.x < image.width && p.y >= 0 && p.y < image.height) {
        final img.Pixel pixel = image.getPixel(p.x, p.y);
        rSum += pixel.r.toInt();
        gSum += pixel.g.toInt();
        bSum += pixel.b.toInt();
        count++;
      }
    }

    if (count > 0) {
      return Rgb(rSum ~/ count, gSum ~/ count, bSum ~/ count);
    } else {
      return const Rgb(128, 128, 128);
    }
  }


  static PieceColor _detectPieceAtPoint(
    img.Image image,
    BoardPoint point,
    ImageCharacteristics characteristics,
    ColorProfile colorProfile,
    Rgb boardColor,
    Rgb configuredWhiteRgb,
    Rgb configuredBlackRgb, {
    double? pieceColorMatchThreshold,
    double? boardColorDistanceThreshold,
    double? blackSaturationThreshold,
    int? blackColorVarianceThreshold,
  }) {

    final double pColorMatchThreshold = pieceColorMatchThreshold ??
        BoardImageRecognitionService.pieceColorMatchThreshold;
    final double bColorDistanceThreshold = boardColorDistanceThreshold ??
        BoardImageRecognitionService.boardColorDistanceThreshold;
    final double bSaturationThreshold = blackSaturationThreshold ??
        BoardImageRecognitionService.blackSaturationThreshold;
    final int bColorVarianceThreshold = blackColorVarianceThreshold ??
        BoardImageRecognitionService.blackColorVarianceThreshold;

    int brightnessSum = 0;
    int sampleCount = 0;
    final int sampleRadius =
        (point.radius * 0.6).round().clamp(1, 10);


    int rSum = 0, gSum = 0, bSum = 0;
    double saturationSum = 0;
    int colorVarianceSum = 0;

    for (int dy = -sampleRadius; dy <= sampleRadius; dy++) {
      for (int dx = -sampleRadius; dx <= sampleRadius; dx++) {
        if (dx * dx + dy * dy <= sampleRadius * sampleRadius) {
          final int sx = point.x + dx;
          final int sy = point.y + dy;
          if (sx >= 0 && sx < image.width && sy >= 0 && sy < image.height) {
            final img.Pixel pixel = image.getPixel(sx, sy);
            final int brightness = _calculateBrightness(pixel);
            brightnessSum += brightness;


            rSum += pixel.r.toInt();
            gSum += pixel.g.toInt();
            bSum += pixel.b.toInt();
            saturationSum += _calculateSaturation(pixel);
            colorVarianceSum += _calculateColorVariance(pixel);

            sampleCount++;
          }
        }
      }
    }

    if (sampleCount == 0) {
      return PieceColor.none;
    }

    final double avgBrightness = brightnessSum / sampleCount.toDouble();
    final Rgb avgRgb =
        Rgb(rSum ~/ sampleCount, gSum ~/ sampleCount, bSum ~/ sampleCount);
    final double avgSaturation = saturationSum / sampleCount.toDouble();
    final double avgColorVariance = colorVarianceSum / sampleCount.toDouble();



    final Color configuredBoardColor = DB().colorSettings.boardBackgroundColor;
    final Rgb configuredBoardRgb = _rgbFromColor(configuredBoardColor);


    final double distToBoard = avgRgb.distanceTo(configuredBoardRgb);
    final double distToWhitePiece = avgRgb.distanceTo(configuredWhiteRgb);
    final double distToBlackPiece = avgRgb.distanceTo(configuredBlackRgb);


    const double boardProximityThreshold =
        25.0;
    const double pieceDistanceThreshold =
        45.0;


    if (distToBoard < boardProximityThreshold &&
        distToWhitePiece > pieceDistanceThreshold &&
        distToBlackPiece > pieceDistanceThreshold) {
      logger.d(
          "Point at (${point.x}, ${point.y}): OVERRIDE to EMPTY. Color $avgRgb is very close to board bg $configuredBoardRgb (dist: ${distToBoard.toStringAsFixed(1)}) and far from pieces (W: ${distToWhitePiece.toStringAsFixed(1)}, B: ${distToBlackPiece.toStringAsFixed(1)}).");
      return PieceColor.none;
    }



    final double distToWhite = (avgBrightness - colorProfile.whiteMean).abs();
    final double distToBlack = (avgBrightness - colorProfile.blackMean).abs();
    final double distToEmpty = (avgBrightness - colorProfile.emptyMean).abs();


    final double whiteStd = math.max(1.0, colorProfile.whiteStd);
    final double blackStd = math.max(1.0, colorProfile.blackStd);
    final double emptyStd = math.max(1.0, colorProfile.emptyStd);


    final double normDistWhite = distToWhite / whiteStd;
    final double normDistBlack = distToBlack / blackStd;
    final double normDistEmpty = distToEmpty / emptyStd;



    double whiteScore = 1.0 / (normDistWhite + 0.1);
    double blackScore = 1.0 / (normDistBlack + 0.1);
    double emptyScore = 1.0 / (normDistEmpty + 0.1);





    final double distToConfigBlack = avgRgb.distanceTo(configuredBlackRgb);
    final bool configBlackMatch = distToConfigBlack < pColorMatchThreshold;


    if (avgBrightness <
            colorProfile.blackMean + blackStd * 1.5 && // Check brightness range
        avgSaturation <
            bSaturationThreshold * 255 && // Check saturation (scaled)
        avgColorVariance < bColorVarianceThreshold * 1.5) {

      blackScore *= 2.0;
      logger.d(
          "  Point (${point.x}, ${point.y}): Moderate evidence for BLACK based on color properties (sat: ${avgSaturation.toStringAsFixed(1)}, var: ${avgColorVariance.toStringAsFixed(1)})");

      if (configBlackMatch) {
        blackScore *= 2.0;
        logger.d(
            "  Point (${point.x}, ${point.y}): Strong boost for BLACK due to configured color match (dist: ${distToConfigBlack.toStringAsFixed(1)})");
      }
    }

    else if (configBlackMatch) {
      blackScore *= 2.0;
      logger.d(
          "  Point (${point.x}, ${point.y}): Strong boost for BLACK due to configured color match (dist: ${distToConfigBlack.toStringAsFixed(1)})");
    }



    final double distToConfigWhite = avgRgb.distanceTo(configuredWhiteRgb);
    final bool configWhiteMatch = distToConfigWhite < pColorMatchThreshold;


    if (avgBrightness > colorProfile.whiteMean - whiteStd * 0.5) {
      whiteScore *= 1.2;
    }

    if (configWhiteMatch) {
      whiteScore *= 2.5;
      logger.d(
          "  Point (${point.x}, ${point.y}): Strong boost for WHITE due to configured color match (dist: ${distToConfigWhite.toStringAsFixed(1)})");
    }



    final double distToBoardColor = avgRgb.distanceTo(boardColor);
    if (distToBoardColor < bColorDistanceThreshold * 0.75) {

      emptyScore *= 2.0;
      logger.d(
          "  Point (${point.x}, ${point.y}): Strong evidence for EMPTY based on board color proximity (dist: ${distToBoardColor.toStringAsFixed(1)})");
    }

    else if (normDistEmpty < 0.8) {

      emptyScore *= 1.2;
    }


    PieceColor result;
    if (whiteScore > blackScore && whiteScore > emptyScore) {
      result = PieceColor.white;
    } else if (blackScore > whiteScore && blackScore > emptyScore) {


      if (blackScore > emptyScore * 1.2 ||
          avgBrightness < colorProfile.emptyMean - emptyStd * 0.5) {
        result = PieceColor.black;
      } else {
        result = PieceColor
            .none;
        logger.d(
            "  Point (${point.x}, ${point.y}): Classified as EMPTY despite high black score due to marginal difference/brightness.");
      }
    } else {
      result = PieceColor.none;
    }


    logger.d(
        "Point at (${point.x}, ${point.y}): brightness=${avgBrightness.toStringAsFixed(1)}, "
        "rgb=$avgRgb, sat=${avgSaturation.toStringAsFixed(1)}, var=${avgColorVariance.toStringAsFixed(1)}, "
        "distBoard=${distToBoardColor.toStringAsFixed(1)} | "
        "distConf(W/B): ${distToConfigWhite.toStringAsFixed(1)}/${distToConfigBlack.toStringAsFixed(1)} | " // Added config distances
        "normDists(W/B/E): ${normDistWhite.toStringAsFixed(2)}/${normDistBlack.toStringAsFixed(2)}/${normDistEmpty.toStringAsFixed(2)} | "
        "scores(W/B/E): ${whiteScore.toStringAsFixed(2)}/${blackScore.toStringAsFixed(2)}/${emptyScore.toStringAsFixed(2)} => $result");

    return result;
  }


  static Map<int, PieceColor> _applyConsistencyRules(
      Map<int, PieceColor> detectedState) {
    logger.w(
        "_applyConsistencyRules is not implemented. Returning original state.");

    return detectedState;
  }


  static List<List<bool>> _dilate(List<List<bool>> mask, int radius) {
    logger.w("_dilate is not implemented. Returning original mask.");
    if (mask.isEmpty || mask[0].isEmpty) {
      return mask;
    }


    return mask;
  }


  static List<List<bool>> _erode(List<List<bool>> mask, int radius) {
    logger.w("_erode is not implemented. Returning original mask.");
    if (mask.isEmpty || mask[0].isEmpty) {
      return mask;
    }


    return mask;
  }




  static img.Image _resizeForProcessing(img.Image original) {
    if (original.width <= _processingWidth &&
        original.height <= _processingWidth) {
      return original;
    }


    int newWidth, newHeight;
    if (original.width > original.height) {
      newWidth = _processingWidth;
      newHeight = (_processingWidth * original.height / original.width).round();
    } else {
      newHeight = _processingWidth;
      newWidth = (_processingWidth * original.width / original.height).round();
    }


    return img.copyResize(original,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.average);
  }






  static img.Image _enhanceImageForProcessing(
    img.Image inputImage, {
    double? contrastEnhancementFactor,
  }) {

    final double usedFactor = contrastEnhancementFactor ??
        BoardImageRecognitionService.contrastEnhancementFactor;



    final img.Image enhancedImage = img.Image.from(inputImage);


    final img.Image denoised = img.gaussianBlur(enhancedImage, radius: 1);


    return img.adjustColor(
      denoised,
      contrast: usedFactor,
    );
  }








  static ImageCharacteristics _analyzeImageCharacteristics(
    img.Image image, {
    int? whiteBrightnessThresholdBase,
    int? blackBrightnessThresholdBase,
    double? pieceThreshold,
  }) {

    final int whiteThresholdBase = whiteBrightnessThresholdBase ??
        BoardImageRecognitionService.whiteBrightnessThreshold;
    final int blackThresholdBase = blackBrightnessThresholdBase ??
        BoardImageRecognitionService.blackBrightnessThreshold;
    final double pThreshold =
        pieceThreshold ?? BoardImageRecognitionService.pieceThreshold;

    int totalBrightness = 0;
    int pixelCount = 0;

    double minBrightness = 255;
    double maxBrightness = 0;


    const int step = 5;
    for (int y = 0; y < image.height; y += step) {
      for (int x = 0; x < image.width; x += step) {
        final img.Pixel pixel = image.getPixel(x, y);
        final int brightness = _calculateBrightness(pixel);

        totalBrightness += brightness;
        pixelCount++;
        minBrightness = math.min(minBrightness, brightness.toDouble());
        maxBrightness = math.max(maxBrightness, brightness.toDouble());
      }
    }


    final double avgBrightness =
        pixelCount > 0 ? totalBrightness / pixelCount : 128;




    final double contrastRatio = (maxBrightness - minBrightness) /
        (avgBrightness + 1);



    final bool isDarkBackground = avgBrightness < 110;
    final bool isHighContrast =
        (maxBrightness - minBrightness) > 100;


    final int whiteThreshold = isDarkBackground
        ? whiteThresholdBase - 15 // Less reduction for dark
        : whiteThresholdBase +
            (avgBrightness > 160 ? 20 : 0);

    final int blackThreshold = isDarkBackground
        ? blackThresholdBase - 15 // Less reduction for dark
        : blackThresholdBase +
            (avgBrightness < 130 ? -15 : 0);


    final int adjustedBlackThreshold =
        math.min(blackThreshold, whiteThreshold - 40);


    final double adjustedPieceThreshold =
        isHighContrast ? pThreshold - 0.05 : pThreshold;

    return ImageCharacteristics(
        averageBrightness: avgBrightness,
        isDarkBackground: isDarkBackground,
        isHighContrast: isHighContrast,
        whiteBrightnessThreshold: whiteThreshold,
        blackBrightnessThreshold: adjustedBlackThreshold,
        pieceDetectionThreshold: adjustedPieceThreshold,
        contrastRatio: contrastRatio // Use the calculated ratio
        );
  }


  static int _calculateBrightness(img.Pixel pixel) {

    return (0.299 * pixel.r.toInt() +
            0.587 * pixel.g.toInt() +
            0.114 * pixel.b.toInt())
        .round();
  }


  static double _calculateSaturation(img.Pixel pixel) {
    final int r = pixel.r.toInt();
    final int g = pixel.g.toInt();
    final int b = pixel.b.toInt();

    final int maxChannel = math.max(r, math.max(g, b));
    final int minChannel = math.min(r, math.min(g, b));
    final int delta = maxChannel - minChannel;


    if (delta == 0) {
      return 0.0;
    }


    final double lightness = (maxChannel + minChannel) / 2.0;


    if (lightness < 128) {

      return (delta * 255.0) /
          (maxChannel +
              minChannel);
    } else {

      return (delta * 255.0) /
          (510 - maxChannel - minChannel);
    }



  }


  static int _calculateColorVariance(img.Pixel pixel) {
    final int r = pixel.r.toInt();
    final int g = pixel.g.toInt();
    final int b = pixel.b.toInt();

    final int maxChannel = math.max(r, math.max(g, b));
    final int minChannel = math.min(r, math.min(g, b));


    return maxChannel - minChannel;
  }


  static List<int> _takePercentile(List<int> sorted, double from, double to) {
    if (sorted.isEmpty) {
      return <int>[];
    }

    int startIndex = (sorted.length * from.clamp(0.0, 1.0)).floor();
    int endIndex = (sorted.length * to.clamp(0.0, 1.0)).floor();


    startIndex = startIndex.clamp(0, sorted.length - 1);
    endIndex = endIndex.clamp(startIndex + 1, sorted.length);

    return sorted.sublist(startIndex, endIndex);
  }


  static ColorProfile _buildColorProfile(
      img.Image image, List<BoardPoint> points) {
    final List<int> whiteBrightness = <int>[];
    final List<int> blackBrightness = <int>[];
    final List<int> emptyBrightness = <int>[];
    final List<int> allBrightness = <int>[];





    logger.i("Building color profile from ${points.length} board points");


    final Map<int, int> pointIndexToBrightness = <int, int>{};
    final List<int> allAvgBrightness = <int>[];

    for (int i = 0; i < points.length; i++) {
      final BoardPoint point = points[i];

      int localBrightnessSum = 0;
      int sampleCount = 0;
      final List<int> pointColors = <int>[];

      final int sampleRadius = (point.radius * 0.7).round().clamp(2, 12);
      for (int dx = -sampleRadius; dx <= sampleRadius; dx += 1) {
        for (int dy = -sampleRadius; dy <= sampleRadius; dy += 1) {
          if (dx * dx + dy * dy <= sampleRadius * sampleRadius) {
            final int sx = point.x + dx;
            final int sy = point.y + dy;

            if (sx >= 0 && sx < image.width && sy >= 0 && sy < image.height) {
              final img.Pixel pixel = image.getPixel(sx, sy);
              final int brightness = _calculateBrightness(pixel);
              localBrightnessSum += brightness;
              sampleCount++;
              pointColors.add(brightness);
            }
          }
        }
      }

      if (sampleCount > 0) {
        final int avgBrightness = localBrightnessSum ~/ sampleCount;
        pointIndexToBrightness[i] = avgBrightness;
        allAvgBrightness.add(avgBrightness);
      }
    }

    if (allAvgBrightness.isEmpty) {
      logger.w(
          "No brightness samples collected for color profile. Returning default.");
      return ColorProfile(
          whiteMean: 200,
          blackMean: 50,
          emptyMean: 128,
          whiteStd: 30,
          blackStd: 30,
          emptyStd: 30);
    }


    allAvgBrightness.sort();



    final int q30Index = (allAvgBrightness.length * 0.30)
        .round()
        .clamp(0, allAvgBrightness.length - 1);
    final int q70Index = (allAvgBrightness.length * 0.70)
        .round()
        .clamp(0, allAvgBrightness.length - 1);
    final int blackThreshold = allAvgBrightness[q30Index];
    final int whiteThreshold = allAvgBrightness[q70Index];

    logger.i(
        "Initial classification thresholds based on distribution: Black <= $blackThreshold, White >= $whiteThreshold");


    for (final int pointIndex in pointIndexToBrightness.keys) {
      final int avgBrightness = pointIndexToBrightness[pointIndex]!;
      allBrightness.add(avgBrightness);

      if (avgBrightness >= whiteThreshold) {
        whiteBrightness.add(avgBrightness);
        logger.d(
            "  Point $pointIndex (brightness $avgBrightness) -> Initial WHITE");
      } else if (avgBrightness <= blackThreshold) {
        blackBrightness.add(avgBrightness);
        logger.d(
            "  Point $pointIndex (brightness $avgBrightness) -> Initial BLACK");
      } else {
        emptyBrightness.add(avgBrightness);
        logger.d(
            "  Point $pointIndex (brightness $avgBrightness) -> Initial EMPTY");
      }
    }



    allBrightness.sort();


    logger.i("All brightness values (sorted): ${allBrightness.join(', ')}");
    if (allBrightness.isNotEmpty) {
      final double min = allBrightness.first.toDouble();
      final double max = allBrightness.last.toDouble();
      final double median = allBrightness[allBrightness.length ~/ 2].toDouble();
      final double q1 = allBrightness[allBrightness.length ~/ 4].toDouble();
      final double q3 = allBrightness[3 * allBrightness.length ~/ 4].toDouble();
      logger.i(
          "Brightness distribution: min=$min, Q1=$q1, median=$median, Q3=$q3, max=$max");
    }



    if (blackBrightness.isEmpty && allBrightness.length > 5) {

      logger.w(
          "No black samples found for profile, using darkest 15% as fallback.");
      blackBrightness
          .addAll(_takePercentile(allBrightness, 0.0, 0.15));
    }
    if (whiteBrightness.isEmpty && allBrightness.length > 5) {

      logger.w(
          "No white samples found for profile, using brightest 15% as fallback.");
      whiteBrightness
          .addAll(_takePercentile(allBrightness, 0.85, 1.0));
    }


    if (emptyBrightness.isEmpty && allBrightness.length > 5) {

      logger.w(
          "No empty samples found for profile, using middle 20% as fallback.");
      emptyBrightness.addAll(_takePercentile(allBrightness, 0.4, 0.6));
    }


    final double whiteMean = _calculateMean(whiteBrightness);
    final double blackMean = _calculateMean(blackBrightness);
    final double emptyMean = _calculateMean(emptyBrightness);



    final double whiteStd =
        math.max(15.0, _calculateStdDev(whiteBrightness, whiteMean));
    final double blackStd =
        math.max(15.0, _calculateStdDev(blackBrightness, blackMean));
    final double emptyStd =
        math.max(15.0, _calculateStdDev(emptyBrightness, emptyMean));


    logger.i("Color profile statistics:");
    logger.i(
        "  WHITE: mean=$whiteMean, std=$whiteStd, samples=${whiteBrightness.length}");
    logger.i(
        "  BLACK: mean=$blackMean, std=$blackStd, samples=${blackBrightness.length}");
    logger.i(
        "  EMPTY: mean=$emptyMean, std=$emptyStd, samples=${emptyBrightness.length}");


    logger.i("Classification thresholds:");
    logger.i("  WHITE threshold: >${whiteMean - whiteStd}");
    logger.i("  BLACK threshold: <${blackMean + blackStd}");
    logger
        .i("  EMPTY range: ${emptyMean - emptyStd} to ${emptyMean + emptyStd}");

    return ColorProfile(
        whiteMean: whiteMean,
        blackMean: blackMean,
        emptyMean: emptyMean,
        whiteStd: whiteStd,
        blackStd: blackStd,
        emptyStd: emptyStd);
  }


  static double _calculateMean(List<int> values) {
    if (values.isEmpty) {
      return 128.0;
    }

    return values.fold<int>(0, (int sum, int item) => sum + item) /
        values.length;
  }


  static double _calculateStdDev(List<int> values, double mean) {
    if (values.length < 2) {

      return 30.0;
    }

    double sumSquaredDiff = 0.0;
    for (final int value in values) {
      final double diff = value - mean;
      sumSquaredDiff += diff * diff;
    }

    return math.sqrt(sumSquaredDiff / values.length);
  }



  static bool _isLikelyBoardColor(Rgb c) {

    final Color boardBackgroundColor =
        DB().colorSettings.boardBackgroundColor;
    if (boardBackgroundColor != null) {

      if (_colorDistance(c, _rgbFromColor(boardBackgroundColor)) < 25) {
        return true;
      }
    }



    final double r = c.r / 255.0;
    final double g = c.g / 255.0;
    final double b = c.b / 255.0;
    final double maxC = math.max(r, math.max(g, b));
    final double minC = math.min(r, math.min(g, b));
    final double delta = maxC - minC;


    final double v = maxC;
    if (v < 0.2 || v > 0.95) {
      return false;
    }


    final double s = maxC == 0 ? 0 : delta / maxC;
    if (s > 0.65) {

      return false;
    }



    if (s < 0.15) {


      return v > 0.3 && v < 0.85;
    } else {

      double h = 0;
      if (delta == 0) {

        h = 0;
      } else if (maxC == r) {
        h = ((g - b) / delta) % 6;
      } else if (maxC == g) {
        h = ((b - r) / delta) + 2;
      } else {

        h = ((r - g) / delta) + 4;
      }
      h = (h * 60 + 360) % 360;



      return h >= 15 && h <= 65;
    }
  }


  static Rgb _rgbFromColor(Color color) {

    int toInt8(double channel) => (channel * 255).round().clamp(0, 255);
    return Rgb(
      toInt8(color.r),
      toInt8(color.g),
      toInt8(color.b),
    );
  }


  static double _colorDistance(Rgb a, Rgb b) {
    final double dr = (a.r - b.r).toDouble();
    final double dg = (a.g - b.g).toDouble();
    final double db = (a.b - b.b).toDouble();
    return math.sqrt(dr * dr + dg * dg + db * db);
  }


  static math.Rectangle<int>? _findBoardBoundingBoxUsingColorSettings(
      img.Image imgSrc) {
    logger.i("Using color settings to find board boundary...");


    final Color boardBackgroundColor = DB().colorSettings.boardBackgroundColor;
    final Color boardLineColor = DB().colorSettings.boardLineColor;
    final Rgb boardBgRgb = _rgbFromColor(boardBackgroundColor);
    final Rgb boardLineRgb = _rgbFromColor(boardLineColor);

    logger.i("Board background color: $boardBgRgb, line color: $boardLineRgb");

    final int imgHeight = imgSrc.height;
    final int imgWidth = imgSrc.width;


    final List<List<bool>> boardMask = List<List<bool>>.generate(
        imgHeight, (_) => List<bool>.filled(imgWidth, false));


    const double bgColorThreshold = 30.0;


    for (int y = 0; y < imgHeight; y++) {
      for (int x = 0; x < imgWidth; x++) {
        final img.Pixel pixel = imgSrc.getPixel(x, y);
        final Rgb rgb = Rgb(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());


        if (_colorDistance(rgb, boardBgRgb) < bgColorThreshold) {
          boardMask[y][x] = true;
        }
      }
    }


    final List<List<int>> labels = List<List<int>>.generate(
        imgHeight, (_) => List<int>.filled(imgWidth, 0));
    int nextLabel = 1;
    int largestLabel = 0;
    int maxComponentSize = 0;


    for (int y = 0; y < imgHeight; y++) {
      for (int x = 0; x < imgWidth; x++) {
        if (boardMask[y][x] && labels[y][x] == 0) {
          int currentSize = 0;
          final Queue<_Point> queue = Queue<_Point>();

          queue.add(_Point(x, y));
          labels[y][x] = nextLabel;

          while (queue.isNotEmpty) {
            final _Point current = queue.removeFirst();
            currentSize++;


            for (int dy = -1; dy <= 1; dy++) {
              for (int dx = -1; dx <= 1; dx++) {
                if (dx == 0 && dy == 0) {
                  continue;
                }
                final int nx = current.x + dx;
                final int ny = current.y + dy;

                if (nx >= 0 &&
                    nx < imgWidth &&
                    ny >= 0 &&
                    ny < imgHeight &&
                    boardMask[ny][nx] &&
                    labels[ny][nx] == 0) {
                  labels[ny][nx] = nextLabel;
                  queue.add(_Point(nx, ny));
                }
              }
            }
          }


          if (currentSize > maxComponentSize) {
            maxComponentSize = currentSize;
            largestLabel = nextLabel;
          }
          nextLabel++;
        }
      }
    }


    if (largestLabel == 0) {
      logger.w(
          "No valid board background area found, trying line color detection");
      return null;
    }


    int minX = imgWidth, minY = imgHeight, maxX = 0, maxY = 0;

    for (int y = 0; y < imgHeight; y++) {
      for (int x = 0; x < imgWidth; x++) {
        if (labels[y][x] == largestLabel) {
          minX = math.min(minX, x);
          minY = math.min(minY, y);
          maxX = math.max(maxX, x);
          maxY = math.max(maxY, y);
        }
      }
    }



    const double lineColorThreshold = 35.0;


    final List<int> horizontalLinePositions = <int>[];
    final List<int> verticalLinePositions = <int>[];


    for (int y = minY; y <= maxY; y++) {
      int linePixels = 0;
      for (int x = minX; x <= maxX; x++) {
        final img.Pixel pixel = imgSrc.getPixel(x, y);
        final Rgb rgb = Rgb(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());

        if (_colorDistance(rgb, boardLineRgb) < lineColorThreshold) {
          linePixels++;
        }
      }


      if (linePixels > (maxX - minX + 1) * 0.3) {
        horizontalLinePositions.add(y);
      }
    }


    for (int x = minX; x <= maxX; x++) {
      int linePixels = 0;
      for (int y = minY; y <= maxY; y++) {
        final img.Pixel pixel = imgSrc.getPixel(x, y);
        final Rgb rgb = Rgb(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());

        if (_colorDistance(rgb, boardLineRgb) < lineColorThreshold) {
          linePixels++;
        }
      }


      if (linePixels > (maxY - minY + 1) * 0.3) {
        verticalLinePositions.add(x);
      }
    }


    horizontalLinePositions.sort();
    verticalLinePositions.sort();


    int leftBorder, topBorder, rightBorder, bottomBorder;
    int finalSize;


    if (horizontalLinePositions.length < 2 ||
        verticalLinePositions.length < 2) {
      logger
          .w("Not enough lines detected, using connected component boundaries");
      leftBorder = minX;
      topBorder = minY;
      rightBorder = maxX;
      bottomBorder = maxY;
    } else {

      leftBorder = verticalLinePositions.first;
      rightBorder = verticalLinePositions.last;
      topBorder = horizontalLinePositions.first;
      bottomBorder = horizontalLinePositions.last;
    }



    final int width = rightBorder - leftBorder + 1;
    final int height = bottomBorder - topBorder + 1;


    finalSize = math.max(width, height);


    if (leftBorder + finalSize > imgWidth ||
        topBorder + finalSize > imgHeight) {
      finalSize = math.min(imgWidth - leftBorder, imgHeight - topBorder);
    }


    if (leftBorder + finalSize < rightBorder) {

      final int shift = rightBorder - (leftBorder + finalSize);
      if (leftBorder - shift >= 0) {
        leftBorder -= shift;
      } else {

        finalSize = rightBorder - leftBorder + 1;
      }
    }

    if (topBorder + finalSize < bottomBorder) {

      final int shift = bottomBorder - (topBorder + finalSize);
      if (topBorder - shift >= 0) {
        topBorder -= shift;
      } else {

        finalSize = bottomBorder - topBorder + 1;
      }
    }


    finalSize = math.min(finalSize, imgWidth - leftBorder);
    finalSize = math.min(finalSize, imgHeight - topBorder);

    logger.i(
        "Board boundary detected using color settings: ($leftBorder, $topBorder, $finalSize, $finalSize) [strict square]");


    final math.Rectangle<int> boardRect =
        math.Rectangle<int>(leftBorder, topBorder, finalSize, finalSize);
    _lastDebugInfo = _lastDebugInfo.copyWith(boardRect: boardRect);


    _generateStandardBoardGrid(boardRect, imgSrc);


    final List<BoardPoint> refinedPoints =
        createRefinedBoardPoints(imgSrc, boardRect);
    _lastDebugInfo = _lastDebugInfo.copyWith(boardPoints: refinedPoints);
    _lastDetectedPoints = refinedPoints;

    return boardRect;
  }


  static math.Rectangle<int>? _findBoardBoundingBox(img.Image imgSrc) {

    final math.Rectangle<int>? colorSettingsResult =
        _findBoardBoundingBoxUsingColorSettings(imgSrc);
    if (colorSettingsResult != null) {
      logger.i("Successfully detected board boundary using color settings");


      _generateStandardBoardGrid(colorSettingsResult, imgSrc);


      final List<BoardPoint> refinedPoints =
          createRefinedBoardPoints(imgSrc, colorSettingsResult);
      _lastDebugInfo = _lastDebugInfo.copyWith(boardPoints: refinedPoints);
      _lastDetectedPoints = refinedPoints;

      return colorSettingsResult;
    }


    logger.i(
        "Color settings detection failed, falling back to original method...");



    final int imgHeight = imgSrc.height;
    final int imgWidth = imgSrc.width;
    final int scanStartY = (imgHeight * 0.02).toInt();
    final int scanHeight = imgHeight -
        2 * scanStartY;
    final int scanStartX = (imgWidth * 0.02).toInt();
    final int scanWidth =
        imgWidth - 2 * scanStartX;

    if (scanHeight <= 20 || scanWidth <= 20) {

      logger.w(
          "Image too small or scan area invalid for bounding box detection.");
      return null;
    }


    List<List<bool>> mask = List<List<bool>>.generate(
        imgHeight,
        (_) => List<bool>.filled(
            imgWidth, false));
    for (int y = scanStartY; y < scanStartY + scanHeight; y++) {
      for (int x = scanStartX; x < scanStartX + scanWidth; x++) {

        if (x >= 0 && x < imgWidth && y >= 0 && y < imgHeight) {
          final img.Pixel pixel = imgSrc.getPixel(x, y);
          final Rgb rgb =
              Rgb(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
          if (_isLikelyBoardColor(rgb)) {
            mask[y][x] = true;
          }
        }
      }
    }




    mask = _dilate(mask, 3);
    mask = _erode(mask, 2);
    mask = _dilate(mask, 3);


    _lastDebugInfo = _lastDebugInfo.copyWith(boardMask: mask);


    final List<List<int>> labels = List<List<int>>.generate(
        imgHeight, (_) => List<int>.filled(imgWidth, 0));
    int nextLabel = 1;
    int largestLabel = 0;
    int maxComponentSize = 0;


    for (int y = scanStartY; y < scanStartY + scanHeight; y++) {
      for (int x = scanStartX; x < scanStartX + scanWidth; x++) {
        if (mask[y][x] && labels[y][x] == 0) {
          int currentSize = 0;
          final Queue<_Point> queue = Queue<_Point>();
          final List<_Point> currentComponentPoints =
              <_Point>[];

          queue.add(_Point(x, y));
          labels[y][x] = nextLabel;

          while (queue.isNotEmpty) {
            final _Point current = queue.removeFirst();
            currentSize++;
            currentComponentPoints.add(current);


            for (int dy = -1; dy <= 1; dy++) {
              for (int dx = -1; dx <= 1; dx++) {
                if (dx == 0 && dy == 0) {
                  continue;
                }
                final int nx = current.x + dx;
                final int ny = current.y + dy;


                if (nx >= 0 &&
                    nx < imgWidth &&
                    ny >= 0 &&
                    ny < imgHeight &&
                    mask[ny][nx] &&
                    labels[ny][nx] == 0) {
                  labels[ny][nx] = nextLabel;
                  queue.add(_Point(nx, ny));
                }
              }
            }
          } // End of BFS for one component


          if (currentSize > maxComponentSize) {
            maxComponentSize = currentSize;
            largestLabel = nextLabel;
            if (currentComponentPoints.isNotEmpty) {

            }
          }
          nextLabel++;
        }
      }
    } // End of component search loops


    if (largestLabel == 0) {
      logger.w("No significant connected components found for the board.");
      return null;
    }


    int minX = imgWidth, minY = imgHeight, maxX = 0, maxY = 0;
    bool foundPoints = false;



    for (int y = 0; y < imgHeight; y++) {
      for (int x = 0; x < imgWidth; x++) {
        if (labels[y][x] == largestLabel) {
          minX = math.min(minX, x);
          minY = math.min(minY, y);
          maxX = math.max(maxX, x);
          maxY = math.max(maxY, y);
          foundPoints = true;
        }
      }
    }

    if (!foundPoints) {
      logger.w("Largest component label found, but no points associated?");
      return null;
    }


    const int padding = 2;
    minX = math.max(0, minX - padding);
    minY = math.max(0, minY - padding);
    maxX = math.min(imgWidth - 1, maxX + padding);
    maxY = math.min(imgHeight - 1, maxY + padding);


    final int width = maxX - minX + 1;
    final int height = maxY - minY + 1;


    int finalSize = math.max(width, height);


    final int centerX = minX + width ~/ 2;
    final int centerY = minY + height ~/ 2;


    int adjustedMinX = centerX - finalSize ~/ 2;
    int adjustedMinY = centerY - finalSize ~/ 2;


    if (adjustedMinX < 0) {
      adjustedMinX = 0;
    }
    if (adjustedMinY < 0) {
      adjustedMinY = 0;
    }
    if (adjustedMinX + finalSize > imgWidth) {
      adjustedMinX = imgWidth - finalSize;
    }
    if (adjustedMinY + finalSize > imgHeight) {
      adjustedMinY = imgHeight - finalSize;
    }


    finalSize = math.min(finalSize, imgWidth - adjustedMinX);
    finalSize = math.min(finalSize, imgHeight - adjustedMinY);

    logger.i(
        "Detected board bounding box via CCA: ($adjustedMinX, $adjustedMinY, $finalSize, $finalSize), [strict square]");


    final math.Rectangle<int> boardRect =
        math.Rectangle<int>(adjustedMinX, adjustedMinY, finalSize, finalSize);
    _lastDebugInfo = _lastDebugInfo.copyWith(boardRect: boardRect);


    _generateStandardBoardGrid(boardRect, imgSrc);


    final List<BoardPoint> refinedPoints =
        createRefinedBoardPoints(imgSrc, boardRect);
    _lastDebugInfo = _lastDebugInfo.copyWith(boardPoints: refinedPoints);
    _lastDetectedPoints = refinedPoints;

    return boardRect;
  }



  static List<BoardPoint> createRefinedBoardPoints(
      img.Image image, math.Rectangle<int> rect) {

    final List<BoardPoint> initialPoints = createBoardPointsFromRect(rect);

    if (initialPoints.isEmpty) {
      return initialPoints;
    }



    try {
      final List<BoardPoint> adjustedPoints = initialPoints;



      final List<Offset> gridPositions = <Offset>[];



      const double boardMarginRatio = 0.08;
      final double boardMargin = rect.width * boardMarginRatio;


      final double gridSpacing = (rect.width - 2 * boardMargin) / 6.0;


      for (int row = 0; row < 7; row++) {
        for (int col = 0; col < 7; col++) {
          final double x = rect.left + boardMargin + col * gridSpacing;
          final double y = rect.top + boardMargin + row * gridSpacing;
          gridPositions.add(Offset(x, y));
        }
      }


      for (int i = 0; i < initialPoints.length; i++) {
        final BoardPoint point = initialPoints[i];
        double minDistance = double.infinity;
        int bestIndex = -1;

        for (int j = 0; j < gridPositions.length; j++) {
          final Offset gridPos = gridPositions[j];
          final double distance = math.sqrt(math.pow(point.x - gridPos.dx, 2) +
              math.pow(point.y - gridPos.dy, 2));

          if (distance < minDistance) {
            minDistance = distance;
            bestIndex = j;
          }
        }

        if (bestIndex >= 0) {
          final Offset bestPos = gridPositions[bestIndex];
          adjustedPoints[i] = BoardPoint(bestPos.dx.round(), bestPos.dy.round(),
              point.radius, point.originalX, point.originalY);
        }
      }

      logger.i(
          "Refined ${adjustedPoints.length} board points to match grid intersections with ${boardMarginRatio * 100}% margin");
      return adjustedPoints;
    } catch (e) {
      logger.e("Error refining board points: $e");
      return initialPoints;
    }
  }



  static void _generateStandardBoardGrid(
      math.Rectangle<int>? boardRect, img.Image processedImage) {
    if (boardRect == null) {
      logger.w("Cannot generate standard grid mask without a board rectangle.");
      return;
    }
    logger.i("Generating standard 7x7 grid mask based on board rectangle.");


    final List<List<bool>> gridMask = List<List<bool>>.generate(
        processedImage.height,
        (_) => List<bool>.filled(processedImage.width, false));

    final int left = boardRect.left;
    final int top = boardRect.top;


    final int size = boardRect.width;

    if (size < 6) {
      logger.w("Board rectangle size ($size) too small to generate grid.");
      return;
    }

    final double segmentSize =
        size / 6.0;
    final int lineWidth =
        math.max(1, (size * 0.01).round());


    for (int i = 0; i < 7; i++) {
      final int y = top + (i * segmentSize).round();

      for (int dy = -lineWidth ~/ 2; dy <= lineWidth ~/ 2; dy++) {
        final int lineY = y + dy;
        if (lineY >= 0 && lineY < processedImage.height) {

          for (int x = left; x < left + size; x++) {
            if (x >= 0 && x < processedImage.width) {
              gridMask[lineY][x] = true;
            }
          }
        }
      }
    }


    for (int i = 0; i < 7; i++) {
      final int x = left + (i * segmentSize).round();

      for (int dx = -lineWidth ~/ 2; dx <= lineWidth ~/ 2; dx++) {
        final int lineX = x + dx;
        if (lineX >= 0 && lineX < processedImage.width) {

          for (int y = top; y < top + size; y++) {
            if (y >= 0 && y < processedImage.height) {
              gridMask[y][lineX] = true;
            }
          }
        }
      }
    }



    for (int x = left; x < left + size; x++) {
      for (int y = top; y < top + lineWidth; y++) {
        if (x >= 0 &&
            x < processedImage.width &&
            y >= 0 &&
            y < processedImage.height) {
          gridMask[y][x] = true;
        }
      }
    }


    for (int x = left; x < left + size; x++) {
      for (int y = top + size - lineWidth; y < top + size; y++) {
        if (x >= 0 &&
            x < processedImage.width &&
            y >= 0 &&
            y < processedImage.height) {
          gridMask[y][x] = true;
        }
      }
    }


    for (int y = top; y < top + size; y++) {
      for (int x = left; x < left + lineWidth; x++) {
        if (x >= 0 &&
            x < processedImage.width &&
            y >= 0 &&
            y < processedImage.height) {
          gridMask[y][x] = true;
        }
      }
    }


    for (int y = top; y < top + size; y++) {
      for (int x = left + size - lineWidth; x < left + size; x++) {
        if (x >= 0 &&
            x < processedImage.width &&
            y >= 0 &&
            y < processedImage.height) {
          gridMask[y][x] = true;
        }
      }
    }


    _lastDebugInfo = _lastDebugInfo.copyWith(
      boardMask: gridMask,
    );
  }



  static img.Image resizeForProcessing(img.Image original) =>
      _resizeForProcessing(original);


  static img.Image enhanceImageForProcessing(
    img.Image inputImage, {
    double? contrastEnhancementFactor,
  }) =>
      _enhanceImageForProcessing(inputImage,
          contrastEnhancementFactor: contrastEnhancementFactor);


  static ImageCharacteristics analyzeImageCharacteristics(
    img.Image image, {
    int? whiteBrightnessThresholdBase,
    int? blackBrightnessThresholdBase,
    double? pieceThreshold,
  }) =>
      _analyzeImageCharacteristics(
        image,
        whiteBrightnessThresholdBase: whiteBrightnessThresholdBase,
        blackBrightnessThresholdBase: blackBrightnessThresholdBase,
        pieceThreshold: pieceThreshold,
      );


  static Rgb estimateBoardColor(
          img.Image image, math.Rectangle<int>? boardRect) =>
      _estimateBoardColor(image, boardRect);


  static ColorProfile buildColorProfile(
          img.Image image, List<BoardPoint> points) =>
      _buildColorProfile(image, points);


  static PieceColor detectPieceAtPoint(
    img.Image image,
    BoardPoint point,
    ImageCharacteristics characteristics,
    ColorProfile colorProfile,
    Rgb boardColor,
    Rgb configuredWhiteRgb,
    Rgb configuredBlackRgb, {
    double? pieceColorMatchThreshold,
    double? boardColorDistanceThreshold,
    double? blackSaturationThreshold,
    int? blackColorVarianceThreshold,
  }) =>
      _detectPieceAtPoint(
        image,
        point,
        characteristics,
        colorProfile,
        boardColor,
        configuredWhiteRgb,
        configuredBlackRgb,
        pieceColorMatchThreshold: pieceColorMatchThreshold,
        boardColorDistanceThreshold: boardColorDistanceThreshold,
        blackSaturationThreshold: blackSaturationThreshold,
        blackColorVarianceThreshold: blackColorVarianceThreshold,
      );


  static Map<int, PieceColor> applyConsistencyRules(
          Map<int, PieceColor> detectedState) =>
      _applyConsistencyRules(detectedState);


  static Rgb rgbFromColor(Color color) => _rgbFromColor(color);


  static set lastDebugInfo(BoardRecognitionDebugInfo info) =>
      _lastDebugInfo = info;


  static set lastDetectedPoints(List<BoardPoint> points) =>
      _lastDetectedPoints = points;

}



List<BoardPoint> createBoardPointsFromRect(math.Rectangle<int> rect) {
  final List<BoardPoint> points = <BoardPoint>[];
  rect.width.toDouble();
  rect.height.toDouble();


  final double size = rect.width.toDouble();

  if (size < 10) {

    logger.e("Board rectangle too small ($rect) to create points.");
    return <BoardPoint>[];
  }




  const double boardMarginRatio = 0.08;
  final double effectiveBoardMargin = size * boardMarginRatio;


  final double playableSize = size - (effectiveBoardMargin * 2);


  final double segmentSize = playableSize / 6.0;


  final double offsetX = rect.left + effectiveBoardMargin;
  final double offsetY = rect.top + effectiveBoardMargin;


  final double pointRadius = segmentSize * 0.35;


  const List<Offset> stdPoints = <Offset>[

    Offset.zero, Offset(3, 0), Offset(6, 0), Offset(6, 3),
    Offset(6, 6), Offset(3, 6), Offset(0, 6), Offset(0, 3),

    Offset(1, 1), Offset(3, 1), Offset(5, 1), Offset(5, 3),
    Offset(5, 5), Offset(3, 5), Offset(1, 5), Offset(1, 3),

    Offset(2, 2), Offset(3, 2), Offset(4, 2), Offset(4, 3),
    Offset(4, 4), Offset(3, 4), Offset(2, 4), Offset(2, 3),
  ];


  for (int i = 0; i < stdPoints.length; i++) {
    final Offset gridPos = stdPoints[i];

    final double px = offsetX + gridPos.dx * segmentSize;
    final double py = offsetY + gridPos.dy * segmentSize;


    points.add(BoardPoint(px.round(), py.round(), pointRadius,
        gridPos.dx.toInt(), gridPos.dy.toInt()));
  }


  if (points.length != 24) {
    logger.w(
        "Created ${points.length} points from rect, expected 24. Rect: $rect");
  } else {
    logger.i(
        "Successfully created 24 board points with adjusted margin. Using margin: $effectiveBoardMargin px (${boardMarginRatio * 100}% of board size)");
  }

  return points;
}



List<BoardPoint> adjustPointsToLineIntersections(
    List<BoardPoint> initialPoints, img.Image image, Color boardLineColor) {
  if (initialPoints.isEmpty || image == null) {
    return initialPoints;
  }


  final Rgb lineRgb =
      BoardImageRecognitionService._rgbFromColor(boardLineColor);
  const double lineColorThreshold =
      35.0;
  const int searchRadius =
      10;

  final List<BoardPoint> adjustedPoints = <BoardPoint>[];

  for (int i = 0; i < initialPoints.length; i++) {
    final BoardPoint point = initialPoints[i];


    if (point.x < 0 ||
        point.x >= image.width ||
        point.y < 0 ||
        point.y >= image.height) {
      adjustedPoints.add(point);
      continue;
    }


    int bestX = point.x;
    int bestY = point.y;
    int maxLinePixelCount = 0;


    for (int dy = -searchRadius; dy <= searchRadius; dy++) {
      for (int dx = -searchRadius; dx <= searchRadius; dx++) {
        final int x = point.x + dx;
        final int y = point.y + dy;


        if (x < 0 || x >= image.width || y < 0 || y >= image.height) {
          continue;
        }


        int horizontalLinePixels = 0;
        int verticalLinePixels = 0;


        for (int hx = x - 5; hx <= x + 5; hx++) {
          if (hx < 0 || hx >= image.width) {
            continue;
          }
          final img.Pixel pixel = image.getPixel(hx, y);
          final Rgb rgb =
              Rgb(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());


          final double dr = (rgb.r - lineRgb.r).toDouble();
          final double dg = (rgb.g - lineRgb.g).toDouble();
          final double db = (rgb.b - lineRgb.b).toDouble();
          final double colorDistance = math.sqrt(dr * dr + dg * dg + db * db);

          if (colorDistance < lineColorThreshold) {
            horizontalLinePixels++;
          }
        }


        for (int vy = y - 5; vy <= y + 5; vy++) {
          if (vy < 0 || vy >= image.height) {
            continue;
          }
          final img.Pixel pixel = image.getPixel(x, vy);
          final Rgb rgb =
              Rgb(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());


          final double dr = (rgb.r - lineRgb.r).toDouble();
          final double dg = (rgb.g - lineRgb.g).toDouble();
          final double db = (rgb.b - lineRgb.b).toDouble();
          final double colorDistance = math.sqrt(dr * dr + dg * dg + db * db);

          if (colorDistance < lineColorThreshold) {
            verticalLinePixels++;
          }
        }


        final int totalLinePixels = horizontalLinePixels + verticalLinePixels;
        if (totalLinePixels > maxLinePixelCount) {
          maxLinePixelCount = totalLinePixels;
          bestX = x;
          bestY = y;
        }
      }
    }


    adjustedPoints.add(BoardPoint(
        bestX, bestY, point.radius, point.originalX, point.originalY));
  }

  logger.i(
      "Adjusted ${adjustedPoints.length} board points to match line intersections");
  return adjustedPoints;
}



math.Rectangle<int>? detectBoardGridFromImage(
    img.Image image, math.Rectangle<int> boardRect, Color boardLineColor) {
  if (image == null || boardRect == null) {
    return boardRect;
  }


  final Rgb lineRgb =
      BoardImageRecognitionService._rgbFromColor(boardLineColor);
  const double lineColorThreshold = 35.0;


  final List<int> horizontalLinesList = <int>[];
  final List<int> verticalLinesList = <int>[];


  for (int y = boardRect.top; y <= boardRect.top + boardRect.height; y++) {
    int linePixelCount = 0;
    for (int x = boardRect.left; x <= boardRect.left + boardRect.width; x++) {
      if (x < 0 || x >= image.width || y < 0 || y >= image.height) {
        continue;
      }
      final img.Pixel pixel = image.getPixel(x, y);
      final Rgb rgb = Rgb(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());


      final double dr = (rgb.r - lineRgb.r).toDouble();
      final double dg = (rgb.g - lineRgb.g).toDouble();
      final double db = (rgb.b - lineRgb.b).toDouble();
      final double colorDistance = math.sqrt(dr * dr + dg * dg + db * db);

      if (colorDistance < lineColorThreshold) {
        linePixelCount++;
      }
    }


    if (linePixelCount > boardRect.width * 0.3) {
      horizontalLinesList.add(y);
    }
  }


  for (int x = boardRect.left; x <= boardRect.left + boardRect.width; x++) {
    int linePixelCount = 0;
    for (int y = boardRect.top; y <= boardRect.top + boardRect.height; y++) {
      if (x < 0 || x >= image.width || y < 0 || y >= image.height) {
        continue;
      }
      final img.Pixel pixel = image.getPixel(x, y);
      final Rgb rgb = Rgb(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());


      final double dr = (rgb.r - lineRgb.r).toDouble();
      final double dg = (rgb.g - lineRgb.g).toDouble();
      final double db = (rgb.b - lineRgb.b).toDouble();
      final double colorDistance = math.sqrt(dr * dr + dg * dg + db * db);

      if (colorDistance < lineColorThreshold) {
        linePixelCount++;
      }
    }


    if (linePixelCount > boardRect.height * 0.3) {
      verticalLinesList.add(x);
    }
  }


  if (horizontalLinesList.length < 7 || verticalLinesList.length < 7) {
    logger.w(
        "Could not detect complete grid. H-lines: ${horizontalLinesList.length}, V-lines: ${verticalLinesList.length}");
    return boardRect;
  }


  List<int> horizontalLines = horizontalLinesList;
  List<int> verticalLines = verticalLinesList;

  if (horizontalLines.length > 7 || verticalLines.length > 7) {

    horizontalLines.sort();
    verticalLines.sort();


    if (horizontalLines.length > 7) {

      horizontalLines = _selectRepresentativeLines(horizontalLines, 7);
    }

    if (verticalLines.length > 7) {
      verticalLines = _selectRepresentativeLines(verticalLines, 7);
    }
  }


  final int left = verticalLines.first;
  final int right = verticalLines.last;
  final int top = horizontalLines.first;
  final int bottom = horizontalLines.last;

  final int width = right - left;
  final int height = bottom - top;


  final int size = math.max(width, height);

  logger.i(
      "Detected grid lines: H=${horizontalLines.length}, V=${verticalLines.length}");
  logger.i("Refined board rectangle: ($left, $top, $size, $size)");

  return math.Rectangle<int>(left, top, size, size);
}


List<int> _selectRepresentativeLines(List<int> lines, int n) {
  if (lines.length <= n) {
    return lines;
  }




  final List<int> result = <int>[];
  final double step = (lines.length - 1) / (n - 1);

  for (int i = 0; i < n; i++) {
    final int index = (i * step).round();
    result.add(lines[index]);
  }

  return result;
}


class BoardPoint {
  BoardPoint(this.x, this.y, this.radius, [this.originalX, this.originalY]);

  final int x;
  final int y;
  final double radius;
  final int? originalX;
  final int? originalY;
}


class ImageCharacteristics {
  ImageCharacteristics(
      {required this.averageBrightness,
      required this.isDarkBackground,
      required this.isHighContrast,
      required this.whiteBrightnessThreshold,
      required this.blackBrightnessThreshold,
      required this.pieceDetectionThreshold,
      required this.contrastRatio});

  final double averageBrightness;
  final bool isDarkBackground;
  final bool isHighContrast;
  final int whiteBrightnessThreshold;
  final int blackBrightnessThreshold;
  final double pieceDetectionThreshold;
  final double contrastRatio;
}


class ColorProfile {
  ColorProfile(
      {required this.whiteMean,
      required this.blackMean,
      required this.emptyMean,
      required this.whiteStd,
      required this.blackStd,
      required this.emptyStd});

  final double whiteMean;
  final double blackMean;
  final double emptyMean;
  final double whiteStd;
  final double blackStd;
  final double emptyStd;
}


class Rgb {
  const Rgb(this.r, this.g, this.b);

  final int r, g, b;


  double distanceTo(Rgb other) {
    final int dr = r - other.r, dg = g - other.g, db = b - other.b;
    return math.sqrt(dr * dr + dg * dg + db * db);
  }

  @override
  String toString() => 'RGB($r, $g, $b)';
}


extension RgbToPixelExtension on Rgb {
  img.Pixel toPixel() {



    final img.Image dummyImage = img.Image(width: 1, height: 1);

    dummyImage.setPixelRgba(
        0, 0, r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255), 255);
    return dummyImage.getPixel(0, 0);
  }
}


class OptimalSamplingPoint {
  OptimalSamplingPoint(this.x, this.y);

  final int x;
  final int y;
}
