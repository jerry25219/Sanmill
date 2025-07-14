




import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../shared/themes/app_theme.dart';
import '../services/board_image_recognition.dart';
import '../services/mill.dart';


class PieceOverlayPainter extends CustomPainter {
  PieceOverlayPainter({
    required this.boardPoints,
    required this.resultMap,
    required this.imageSize,
    this.boardRect,
  });

  final List<BoardPoint> boardPoints;
  final Map<int, PieceColor> resultMap;
  final Size imageSize;
  final math.Rectangle<int>? boardRect;

  @override
  void paint(Canvas canvas, Size size) {

    if (boardPoints.isEmpty) {
      return;
    }

    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;


    if (boardRect != null) {
      final Paint rectPaint = Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;


      final Path dashedPath = Path();


      final Rect rect = Rect.fromLTWH(
        boardRect!.left * scaleX,
        boardRect!.top * scaleY,
        boardRect!.width * scaleX,
        boardRect!.height * scaleY,
      );


      const double dashWidth = 10.0;
      const double dashSpace = 5.0;


      double startX = rect.left;
      while (startX < rect.right) {
        final double endX =
            startX + dashWidth < rect.right ? startX + dashWidth : rect.right;
        dashedPath.moveTo(startX, rect.top);
        dashedPath.lineTo(endX, rect.top);
        startX = endX + dashSpace;
      }


      double startY = rect.top;
      while (startY < rect.bottom) {
        final double endY =
            startY + dashWidth < rect.bottom ? startY + dashWidth : rect.bottom;
        dashedPath.moveTo(rect.right, startY);
        dashedPath.lineTo(rect.right, endY);
        startY = endY + dashSpace;
      }


      startX = rect.right;
      while (startX > rect.left) {
        final double endX =
            startX - dashWidth > rect.left ? startX - dashWidth : rect.left;
        dashedPath.moveTo(startX, rect.bottom);
        dashedPath.lineTo(endX, rect.bottom);
        startX = endX - dashSpace;
      }


      startY = rect.bottom;
      while (startY > rect.top) {
        final double endY =
            startY - dashWidth > rect.top ? startY - dashWidth : rect.top;
        dashedPath.moveTo(rect.left, startY);
        dashedPath.lineTo(rect.left, endY);
        startY = endY - dashSpace;
      }


      canvas.drawPath(dashedPath, rectPaint);


      final TextPainter textPainter = TextPainter(
        text: const TextSpan(
          text: 'Detected Board Area', // Changed text to English
          style: TextStyle(
            color: Colors.yellow,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.black54,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.left + 10, rect.top + 10),
      );
    }








    final List<BoardPoint> outerRingPoints = boardPoints.take(8).toList();
    final List<BoardPoint> middleRingPoints =
        boardPoints.skip(8).take(8).toList();
    final List<BoardPoint> innerRingPoints =
        boardPoints.skip(16).take(8).toList();


    double minX = double.infinity, minY = double.infinity;
    double maxX = -double.infinity, maxY = -double.infinity;


    for (final BoardPoint point in outerRingPoints) {
      if (point.x < minX) {
        minX = point.x.toDouble();
      }
      if (point.y < minY) {
        minY = point.y.toDouble();
      }
      if (point.x > maxX) {
        maxX = point.x.toDouble();
      }
      if (point.y > maxY) {
        maxY = point.y.toDouble();
      }
    }


    final double detectedWidth = maxX - minX;
    final double detectedHeight = maxY - minY;
    final double detectedSize = math.max(detectedWidth, detectedHeight);


    final double viewPadding = AppTheme.boardPadding;
    final double availableSize =
        math.min(size.width, size.height) - (viewPadding * 2);


    final double scaleFactor = availableSize / detectedSize;


    final double xOffset = (size.width - detectedWidth * scaleFactor) / 2;
    final double yOffset = (size.height - detectedHeight * scaleFactor) / 2;


    Offset mapPointToView(BoardPoint point) {
      return Offset(xOffset + (point.x - minX) * scaleFactor,
          yOffset + (point.y - minY) * scaleFactor);
    }



    final Paint gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.yellow.withValues(alpha: 0.7);



    final List<Offset> outerOffsets =
        outerRingPoints.map(mapPointToView).toList();
    final List<Offset> middleOffsets =
        middleRingPoints.map(mapPointToView).toList();
    final List<Offset> innerOffsets =
        innerRingPoints.map(mapPointToView).toList();

    for (int i = 0; i < outerOffsets.length; i++) {
      final int next = (i + 1) % outerOffsets.length;
      canvas.drawLine(outerOffsets[i], outerOffsets[next], gridPaint);
    }

    for (int i = 0; i < middleOffsets.length; i++) {
      final int next = (i + 1) % middleOffsets.length;
      canvas.drawLine(middleOffsets[i], middleOffsets[next], gridPaint);
    }

    for (int i = 0; i < innerOffsets.length; i++) {
      final int next = (i + 1) % innerOffsets.length;
      canvas.drawLine(innerOffsets[i], innerOffsets[next], gridPaint);
    }

    const List<int> connections = <int>[1, 3, 5, 7];
    for (final int idx in connections) {
      canvas.drawLine(outerOffsets[idx], middleOffsets[idx], gridPaint);
      canvas.drawLine(middleOffsets[idx], innerOffsets[idx], gridPaint);
    }



    for (int i = 0; i < boardPoints.length && i < resultMap.length; i++) {
      final PieceColor pieceColor = resultMap[i]!;
      if (pieceColor == PieceColor.none) {
        continue;
      }


      final BoardPoint detectedPoint =
          boardPoints[i];


      final Offset viewPosition;
      if (i < 8) {
        viewPosition = outerOffsets[i];
      } else if (i < 16) {
        viewPosition = middleOffsets[i - 8];
      } else {
        viewPosition = innerOffsets[i - 16];
      }




      final double viewRadius = detectedPoint.radius * scaleFactor * 0.8;


      final Paint crossPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = pieceColor == PieceColor.black ? Colors.black : Colors.white;

      final Paint borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0 // Border is thicker
        ..color = pieceColor == PieceColor.black
            ? Colors.white
            : Colors.black;


      final double crossSize = viewRadius * 0.8;


      canvas.drawLine(
        Offset(viewPosition.dx - crossSize, viewPosition.dy),
        Offset(viewPosition.dx + crossSize, viewPosition.dy),
        borderPaint,
      );
      canvas.drawLine(
        Offset(viewPosition.dx, viewPosition.dy - crossSize),
        Offset(viewPosition.dx, viewPosition.dy + crossSize),
        borderPaint,
      );


      canvas.drawLine(
        Offset(viewPosition.dx - crossSize, viewPosition.dy),
        Offset(viewPosition.dx + crossSize, viewPosition.dy),
        crossPaint,
      );
      canvas.drawLine(
        Offset(viewPosition.dx, viewPosition.dy - crossSize),
        Offset(viewPosition.dx, viewPosition.dy + crossSize),
        crossPaint,
      );
    }


    for (int i = 0; i < boardPoints.length; i++) {
      final BoardPoint point = boardPoints[i];
      final Offset rawViewPosition = Offset(point.x * scaleX, point.y * scaleY);


      final Paint pointMarkerPaint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.6) // Use withOpacity
        ..style = PaintingStyle.fill;


      canvas.drawCircle(
        rawViewPosition,
        3.0, // Fixed small size for marker
        pointMarkerPaint,
      );


      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: '$i',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            backgroundColor: Colors.black54,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          rawViewPosition.dx - textPainter.width / 2,
          rawViewPosition.dy - textPainter.height / 2,
        ),
      );


      final PieceColor? color = resultMap[i];
      if (color != null && color != PieceColor.none) {
        final Paint resultCirclePaint = Paint()
          ..color = color == PieceColor.white ? Colors.green : Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;


        final double radius = point.radius *
            scaleX;

        canvas.drawCircle(
          rawViewPosition,
          radius,
          resultCirclePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PieceOverlayPainter oldDelegate) =>
      oldDelegate.boardPoints != boardPoints ||
      oldDelegate.resultMap != resultMap ||
      oldDelegate.imageSize != imageSize ||
      oldDelegate.boardRect != boardRect;
}
