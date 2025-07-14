




import 'dart:math' as math;

import 'package:flutter/material.dart';


class BoardRectOverlay extends StatelessWidget {
  const BoardRectOverlay({
    super.key,
    required this.boardRect,
    required this.imageSize,
  });


  final math.Rectangle<int> boardRect;


  final Size imageSize;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _BoardRectPainter(
        boardRect: boardRect,
        imageSize: imageSize,
      ),
    );
  }
}


class _BoardRectPainter extends CustomPainter {
  _BoardRectPainter({
    required this.boardRect,
    required this.imageSize,
  });

  final math.Rectangle<int> boardRect;
  final Size imageSize;

  @override
  void paint(Canvas canvas, Size size) {

    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;


    final Paint rectPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;


    final Path dashedPath = Path();


    final Rect rect = Rect.fromLTWH(
      boardRect.left * scaleX,
      boardRect.top * scaleY,
      boardRect.width * scaleX,
      boardRect.height * scaleY,
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


    const String label = 'Detected Board Area';
    const TextSpan textSpan = TextSpan(
      text: label,
      style: TextStyle(
        color: Colors.yellow,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        backgroundColor: Colors.black54,
      ),
    );

    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.left + 10, rect.top + 10),
    );
  }

  @override
  bool shouldRepaint(covariant _BoardRectPainter oldDelegate) =>
      oldDelegate.boardRect != boardRect || oldDelegate.imageSize != imageSize;
}
