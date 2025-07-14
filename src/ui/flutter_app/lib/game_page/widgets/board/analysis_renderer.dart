






import 'dart:math';

import 'package:flutter/material.dart';

import '../../../shared/database/database.dart';
import '../../../shared/services/environment_config.dart';
import '../../../shared/services/logger.dart';
import '../../services/analysis_mode.dart';
import '../../services/mill.dart';
import '../../services/painters/painters.dart';


enum AnalysisResultType {
  place, // Place a piece on a point
  move, // Move a piece from one point to another
  remove // Remove a piece from a point
}


class AnalysisRenderer {

  static const double valueTolerance = 0.001;

  static void render(Canvas canvas, Size size, double squareSize) {
    if (!AnalysisMode.isEnabled || AnalysisMode.analysisResults.isEmpty) {
      return;
    }


    if (EnvironmentConfig.devMode) {
      logger
          .i("Analysis results count: ${AnalysisMode.analysisResults.length}");
      for (final MoveAnalysisResult result in AnalysisMode.analysisResults) {
        logger.i("Move: ${result.move}, Outcome: ${result.outcome.name}, "
            "Value: ${result.outcome.valueStr}, Steps: ${result.outcome.stepCount}");
      }
    }


    final List<MoveAnalysisResult> sortedResults =
        _getSortedResults(AnalysisMode.analysisResults);


    final double? bestValue = _getBestValue(sortedResults);


    final bool isFlyingMode = _shouldFilterToOnlyBestMoves();


    List<MoveAnalysisResult> resultsToRender = sortedResults;
    if (isFlyingMode && bestValue != null) {
      resultsToRender = sortedResults.where((MoveAnalysisResult result) {

        if (result.outcome.valueStr == null ||
            result.outcome.valueStr!.isEmpty) {
          return false;
        }

        try {
          final double resultValue = double.parse(result.outcome.valueStr!);

          return (resultValue - bestValue).abs() < valueTolerance;
        } catch (e) {
          logger.w("Error parsing result value for flying mode filtering: $e");
          return false;
        }
      }).toList();


      if (resultsToRender.isEmpty && sortedResults.isNotEmpty) {
        resultsToRender = <MoveAnalysisResult>[sortedResults.first];
      }
    }

    for (int i = 0; i < resultsToRender.length; i++) {
      final MoveAnalysisResult result = resultsToRender[i];


      final bool isTopResult = _isTopResult(result, bestValue);


      final AnalysisResultType resultType = _determineResultType(result.move);

      switch (resultType) {
        case AnalysisResultType.place:

          if (result.move.length == 2 &&
              RegExp(r'^[a-g][1-7]$').hasMatch(result.move)) {

            final Offset position =
                _getPositionFromStandardNotation(result.move, size);


            _drawOutcomeMark(canvas, position, result.outcome, squareSize * 0.4,
                isTopResult);
          } else {
            logger.w("Failed to parse place move: ${result.move}");
          }
          break;

        case AnalysisResultType.move:

          _drawMoveArrow(
              canvas, result.move, result.outcome, size, isTopResult);
          break;

        case AnalysisResultType.remove:

          _drawRemoveCircle(canvas, result.move, result.outcome, size,
              squareSize * 0.5, isTopResult);
          break;
      }
    }
  }


  static double? _getBestValue(List<MoveAnalysisResult> sortedResults) {

    if (sortedResults.isEmpty) {
      return null;
    }


    final MoveAnalysisResult firstResult = sortedResults.first;
    if (firstResult.outcome.valueStr == null ||
        firstResult.outcome.valueStr!.isEmpty) {
      return null;
    }

    try {
      return double.parse(firstResult.outcome.valueStr!);
    } catch (e) {
      logger.w("Error parsing first result value: $e");
      return null;
    }
  }


  static bool _isTopResult(MoveAnalysisResult result, double? bestValue) {

    if (bestValue == null) {
      return true;
    }


    if (result.outcome.valueStr == null || result.outcome.valueStr!.isEmpty) {
      return false;
    }

    try {
      final double resultValue = double.parse(result.outcome.valueStr!);

      return (resultValue - bestValue).abs() < valueTolerance;
    } catch (e) {
      logger.w("Error parsing result value: $e");
      return false;
    }
  }


  static List<MoveAnalysisResult> _getSortedResults(
      List<MoveAnalysisResult> results) {

    final List<MoveAnalysisResult> sortedResults =
        List<MoveAnalysisResult>.from(results);


    sortedResults.sort((MoveAnalysisResult a, MoveAnalysisResult b) {

      if (a.outcome.valueStr == null || a.outcome.valueStr!.isEmpty) {
        return 1;
      }
      if (b.outcome.valueStr == null || b.outcome.valueStr!.isEmpty) {
        return -1;
      }


      try {
        final double aValue = double.parse(a.outcome.valueStr!);
        final double bValue = double.parse(b.outcome.valueStr!);


        return bValue.compareTo(aValue);
      } catch (e) {

        logger.w("Error parsing analysis values: $e");
        return 0;
      }
    });

    return sortedResults;
  }


  static bool _shouldUseDashPattern(GameOutcome outcome) {
    return outcome == GameOutcome.advantage ||
        outcome == GameOutcome.disadvantage;
  }


  static double _getStrokeWidth(GameOutcome outcome, bool isTopResult) {

    const double normalWidth = 2.5;
    const double reducedWidth = 1.5;


    if (outcome == GameOutcome.advantage ||
        outcome == GameOutcome.disadvantage) {
      return isTopResult ? normalWidth : reducedWidth;
    }


    return normalWidth;
  }


  static void _drawOutcomeMark(
    Canvas canvas,
    Offset position,
    GameOutcome outcome,
    double radius,
    bool isTopResult,
  ) {
    final bool useDashPattern = _shouldUseDashPattern(outcome);
    final double strokeWidth = _getStrokeWidth(outcome, isTopResult);

    final Paint paint = Paint()
      ..color = AnalysisMode.getColorForOutcome(outcome).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;


    if (useDashPattern) {
      _drawDashedCircle(
        canvas,
        position,
        radius,
        paint.color,
        strokeWidth: strokeWidth,
      );
    } else {
      canvas.drawCircle(position, radius, paint);
    }


    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: _getDisplaySymbolForOutcome(outcome),
        style: TextStyle(
          color: AnalysisMode.getColorForOutcome(outcome),
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();


    final Offset textOffset = Offset(
      position.dx - textPainter.width / 2,
      position.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, textOffset);
  }


  static void _drawMoveArrow(
    Canvas canvas,
    String moveStr,
    GameOutcome outcome,
    Size size,
    bool isTopResult,
  ) {




    if (!moveStr.contains('-') || moveStr.length != 5) {
      return;
    }

    final List<String> squares = moveStr.split('-');
    if (squares.length != 2) {
      return;
    }

    final String fromSquare = squares[0];
    final String toSquare = squares[1];


    final Offset startPos = _getPositionFromStandardNotation(fromSquare, size);
    final Offset endPos = _getPositionFromStandardNotation(toSquare, size);


    final Color arrowColor = AnalysisMode.getColorForOutcome(outcome);


    final double opacity = AnalysisMode.getOpacityForOutcome(outcome);


    final bool useDashPattern = _shouldUseDashPattern(outcome);


    final double strokeWidth = _getStrokeWidth(outcome, isTopResult);


    _drawArrow(
      canvas,
      startPos,
      endPos,
      arrowColor.withValues(alpha: opacity),
      useDashPattern: useDashPattern,
      strokeWidth: strokeWidth,
    );


    final int? stepCount = outcome.stepCount;
    if (stepCount != null && stepCount > 0) {
      final TextPainter stepTextPainter = TextPainter(
        text: TextSpan(
          text: stepCount.toString(),
          style: TextStyle(
            color: arrowColor, // Use arrowColor for consistency
            fontSize: 12, // Adjust font size as needed
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      stepTextPainter.layout();


      final Offset midPoint = Offset(
        (startPos.dx + endPos.dx) / 2,
        (startPos.dy + endPos.dy) / 2,
      );










      final double angle = (endPos - startPos).direction;
      double textX = midPoint.dx;
      double textY = midPoint.dy;



      if (cos(angle).abs() > sin(angle).abs()) {

        textY = midPoint.dy -
            stepTextPainter.height -
            5;
        textX = midPoint.dx - stepTextPainter.width / 2;
      } else {

        textX = midPoint.dx + 10;
        textY = midPoint.dy - stepTextPainter.height / 2;

        if (endPos.dx < startPos.dx) {

          textX = midPoint.dx - stepTextPainter.width - 10;
        }
      }

      final Offset stepTextOffset = Offset(textX, textY);

      stepTextPainter.paint(canvas, stepTextOffset);
    }
  }


  static void _drawRemoveCircle(
    Canvas canvas,
    String moveStr,
    GameOutcome outcome,
    Size size,
    double radius,
    bool isTopResult,
  ) {

    if (!moveStr.startsWith('x') || moveStr.length != 3) {
      logger.w("Failed to parse remove move: $moveStr");
      return;
    }


    final String squareNotation = moveStr.substring(1);


    final Offset position =
        _getPositionFromStandardNotation(squareNotation, size);


    final Color circleColor = AnalysisMode.getColorForOutcome(outcome);


    final double opacity = AnalysisMode.getOpacityForOutcome(outcome);


    final bool useDashPattern = _shouldUseDashPattern(outcome);
    final double strokeWidth = _getStrokeWidth(outcome, isTopResult);


    if (useDashPattern) {
      _drawDashedCircle(
        canvas,
        position,
        radius,
        circleColor.withValues(alpha: opacity),
        strokeWidth: strokeWidth,
        dashLength: 6.0,
      );
    } else {
      final Paint circlePaint = Paint()
        ..color = circleColor.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawCircle(position, radius, circlePaint);
    }


    final int? stepCount = outcome.stepCount;
    if (stepCount != null && stepCount > 0) {
      final TextPainter stepTextPainter = TextPainter(
        text: TextSpan(
          text: stepCount.toString(),
          style: TextStyle(
            color: circleColor,
            fontSize: radius * 0.7, // Adjust font size as needed
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      stepTextPainter.layout();


      final Offset stepTextOffset = Offset(
        position.dx - stepTextPainter.width / 2,
        position.dy -
            radius -
            stepTextPainter.height -
            2, // 2 is a small padding
      );

      stepTextPainter.paint(canvas, stepTextOffset);
    }
  }


  static void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Color color, {
    double strokeWidth = 2.0,
    double dashLength = 5.0,
    double gapLength = 3.0,
  }) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;


    final double circumference = 2 * pi * radius;


    final int dashCount = (circumference / (dashLength + gapLength)).round();


    final double dashAngle = 2 * pi / dashCount;


    for (int i = 0; i < dashCount; i++) {
      final double startAngle = i * dashAngle;
      final double endAngle =
          startAngle + (dashLength / circumference) * 2 * pi;

      final Path dashPath = Path()
        ..addArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          endAngle - startAngle,
        );

      canvas.drawPath(dashPath, paint);
    }
  }


  static void _drawArrow(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color, {
    bool useDashPattern = false,
    double strokeWidth = 3.0,
  }) {

    const double arrowLength = 15.0;
    const double arrowWidth = 12.0;

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;


    final double angle = (end - start).direction;


    final Offset adjustedEnd = end -
        Offset(
          arrowLength * cos(angle),
          arrowLength * sin(angle),
        );


    if (useDashPattern) {
      _drawDashedLine(canvas, start, adjustedEnd, paint);
    } else {
      canvas.drawLine(start, adjustedEnd, paint);
    }


    final Paint circlePaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(start, arrowWidth / 4, circlePaint);


    final Offset perpendicular = Offset(-sin(angle), cos(angle));


    final Offset arrowBaseLeft =
        adjustedEnd + (perpendicular * (arrowWidth / 2));
    final Offset arrowBaseRight =
        adjustedEnd - (perpendicular * (arrowWidth / 2));


    final Path arrowPath = Path()
      ..moveTo(end.dx, end.dy) // Arrow tip
      ..lineTo(arrowBaseLeft.dx, arrowBaseLeft.dy)
      ..lineTo(arrowBaseRight.dx, arrowBaseRight.dy)
      ..close();


    final Paint arrowPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;


    canvas.drawPath(arrowPath, arrowPaint);
  }


  static void _drawDashedLine(
      Canvas canvas, Offset start, Offset end, Paint paint) {
    const double dashLength = 8.0;
    const double gapLength = 4.0;


    final double dx = end.dx - start.dx;
    final double dy = end.dy - start.dy;
    final double distance = sqrt(dx * dx + dy * dy);


    final double unitX = dx / distance;
    final double unitY = dy / distance;


    final int segmentCount = (distance / (dashLength + gapLength)).floor();


    double currentX = start.dx;
    double currentY = start.dy;

    for (int i = 0; i < segmentCount; i++) {

      final double dashEndX = currentX + unitX * dashLength;
      final double dashEndY = currentY + unitY * dashLength;


      canvas.drawLine(
        Offset(currentX, currentY),
        Offset(dashEndX, dashEndY),
        paint,
      );


      currentX = dashEndX + unitX * gapLength;
      currentY = dashEndY + unitY * gapLength;
    }


    final double remainingDistance =
        distance - segmentCount * (dashLength + gapLength);
    if (remainingDistance > 0) {
      final double dashPortion = min(remainingDistance, dashLength);
      canvas.drawLine(
        Offset(currentX, currentY),
        Offset(currentX + unitX * dashPortion, currentY + unitY * dashPortion),
        paint,
      );
    }
  }


  static AnalysisResultType _determineResultType(String move) {
    if (move.startsWith('x')) {

      return AnalysisResultType.remove;
    } else if (move.contains('-') &&
        move.length == 5 &&
        RegExp(r'^[a-g][1-7]-[a-g][1-7]$').hasMatch(move)) {

      return AnalysisResultType.move;
    } else if (move.length == 2 && RegExp(r'^[a-g][1-7]$').hasMatch(move)) {

      return AnalysisResultType.place;
    } else {

      return AnalysisResultType.place;
    }
  }


  static String _getSymbolForOutcome(GameOutcome outcome) {

    switch (outcome) {
      case GameOutcome.win:
        return '';
      case GameOutcome.draw:
        return '';
      case GameOutcome.loss:
        return '';
      case GameOutcome.advantage:

        if (EnvironmentConfig.devMode &&
            outcome.valueStr != null &&
            outcome.valueStr!.isNotEmpty) {
          return outcome
              .valueStr!;
        }
        return '';
      case GameOutcome.disadvantage:

        if (EnvironmentConfig.devMode &&
            outcome.valueStr != null &&
            outcome.valueStr!.isNotEmpty) {
          return outcome
              .valueStr!;
        }
        return '';
      case GameOutcome.unknown:
      default:

        if (EnvironmentConfig.devMode &&
            outcome.valueStr != null &&
            outcome.valueStr!.isNotEmpty) {
          return outcome
              .valueStr!;
        }
        return '?';
    }
  }


  static String _getDisplaySymbolForOutcome(GameOutcome outcome) {

    if (EnvironmentConfig.devMode) {
      logger.i("Getting display symbol for outcome: ${outcome.name}, "
          "valueStr: ${outcome.valueStr}, stepCount: ${outcome.stepCount}");
    }


    if (outcome.stepCount != null && outcome.stepCount! > 0) {

      if (EnvironmentConfig.devMode) {
        logger.i(
            "Displaying step count ${outcome.stepCount} for outcome ${outcome.name}");
      }

      return outcome.stepCount!.toString();
    }


    if (outcome.valueStr != null && outcome.valueStr!.isNotEmpty) {

      if (EnvironmentConfig.devMode) {
        logger.i(
            "Displaying value string '${outcome.valueStr}' for outcome ${outcome.name}");
      }


      if (EnvironmentConfig.devMode &&
          (outcome == GameOutcome.advantage ||
              outcome == GameOutcome.disadvantage)) {
        return outcome.valueStr!;
      }
    }


    if (EnvironmentConfig.devMode) {
      logger.i(
          "Using fallback symbol for outcome ${outcome.name}, stepCount: ${outcome.stepCount}");
    }


    final String fallbackSymbol = _getSymbolForOutcome(outcome);


    if (fallbackSymbol.isEmpty) {
      switch (outcome) {
        case GameOutcome.win:
          return '✓';
        case GameOutcome.draw:
          return '=';
        case GameOutcome.loss:
          return '✗';
        case GameOutcome.advantage:
          return '+';
        case GameOutcome.disadvantage:
          return '-';
        case GameOutcome.unknown:
        default:
          return '?';
      }
    }

    return fallbackSymbol;
  }


  static Offset _getPositionFromStandardNotation(
      String squareNotation, Size size) {

    if (squareNotation.length != 2 ||
        !RegExp(r'^[a-g][1-7]$').hasMatch(squareNotation)) {
      logger.w("Invalid standard notation: $squareNotation");
      return size.center(Offset.zero);
    }

    final int square = notationToSquare(squareNotation);


    return pointFromSquare(square, size);
  }



  static bool _shouldFilterToOnlyBestMoves() {

    return DB().ruleSettings.mayFly &&
        GameController().position.phase == Phase.moving &&
        GameController()
                .position
                .pieceOnBoardCount[GameController().position.sideToMove]! <=
            DB().ruleSettings.flyPieceCount;
  }


  static String getAnalysisDisplayText(MoveAnalysisResult result) {
    if (result.outcome.stepCount != null) {

      return "${result.move}: ${result.outcome.displayString}";
    } else {

      return "${result.move}: ${result.outcome.name}${result.outcome.valueStr != null ? " (${result.outcome.valueStr})" : ""}";
    }
  }


  static bool hasPerfectDatabaseInfo(MoveAnalysisResult result) {
    return result.outcome.stepCount != null && result.outcome.stepCount! > 0;
  }
}
