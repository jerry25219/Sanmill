




import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../shared/database/database.dart';
import '../../../shared/utils/helpers/color_helpers/color_helper.dart';












class AdvantageGraphPainter extends CustomPainter {
  AdvantageGraphPainter(this.data);

  final List<int> data;

  @override
  void paint(Canvas canvas, Size size) {

    final int showCount = math.min(50, data.length);



    final Color bgColor = DB().colorSettings.boardBackgroundColor;
    final Color lineColor = DB().colorSettings.boardLineColor;
    final Color darkBgColor = DB().colorSettings.darkBackgroundColor;

    final Color chosenColor =
        pickColorWithMaxDifference(bgColor, lineColor, darkBgColor)
            .withValues(alpha: 0.5);


    final Paint zeroLinePaint = Paint()
      ..color = chosenColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double margin = 10.0;
    final double chartWidth = size.width - margin * 2;
    final double chartHeight = size.height - margin * 2;


    final double zeroY = margin + chartHeight / 2;



    final double dxStep = chartWidth / 49.0;


    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(margin, margin, chartWidth, chartHeight),
        const Radius.circular(5),
      ),
    );


    canvas.drawLine(
      Offset(margin, zeroY),
      Offset(margin + 49 * dxStep, zeroY),
      zeroLinePaint,
    );


    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(margin, margin, chartWidth, chartHeight),
        const Radius.circular(5),
      ),
      zeroLinePaint,
    );




    if (showCount < 2) {
      return;
    }


    final List<int> shownData = data.sublist(data.length - showCount);


    final Paint linePaint = Paint()
      ..color = Color.lerp(
        DB().colorSettings.whitePieceColor,
        DB().colorSettings.blackPieceColor,
        0.5,
      )!
          .withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;


    double valueToPixel(int val) {
      return zeroY - (val * (chartHeight / 200.0));
    }

    final Path path = Path();
    double? lastY;
    int? lastVal;


    final List<Offset> points = <Offset>[];

    for (int i = 0; i < showCount; i++) {
      final double x = margin + i * dxStep;
      final int val = shownData[i];
      double y;



      if (val == 100 || val == -100) {
        if (lastY == null) {
          y = valueToPixel(0);
        } else {
          y = lastY;
        }
      } else {
        y = valueToPixel(val);
      }



      bool newLineStart = false;
      if (lastVal != null) {
        if ((lastVal < -75 || lastVal > 75) && val == 0) {
          newLineStart = true;
        }
      }

      if (i == 0 || newLineStart) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      points.add(Offset(x, y));
      lastY = y;
      lastVal = val;
    }



    final Paint topFillPaint = Paint()
      ..color = DB().colorSettings.blackPieceColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;


    final Paint bottomFillPaint = Paint()
      ..color = DB().colorSettings.whitePieceColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;






    final Path topFillPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      topFillPath.lineTo(points[i].dx, points[i].dy);
    }
    topFillPath.lineTo(points.last.dx, margin);
    topFillPath.lineTo(points.first.dx, margin);
    topFillPath.close();






    final Path bottomFillPath = Path()
      ..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      bottomFillPath.lineTo(points[i].dx, points[i].dy);
    }
    bottomFillPath.lineTo(points.last.dx, margin + chartHeight);
    bottomFillPath.lineTo(points.first.dx, margin + chartHeight);
    bottomFillPath.close();


    canvas.drawPath(topFillPath, topFillPaint);

    canvas.drawPath(bottomFillPath, bottomFillPaint);


    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(AdvantageGraphPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
