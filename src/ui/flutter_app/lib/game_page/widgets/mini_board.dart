

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../../shared/database/database.dart';
import '../services/mill.dart';
import 'game_page.dart';





class MiniBoard extends StatefulWidget {
  const MiniBoard({
    super.key,
    required this.boardLayout,
    this.extMove,
    this.onNavigateMove, // Callback when navigation icon is tapped.
  });

  final String boardLayout;
  final ExtMove? extMove;



  final VoidCallback? onNavigateMove;

  @override
  MiniBoardState createState() => MiniBoardState();
}

class MiniBoardState extends State<MiniBoard>
    with SingleTickerProviderStateMixin {

  static MiniBoardState? _activeBoard;


  bool _showNavigationIcon = false;


  late AnimationController _pulseController;


  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);


    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {

    if (_activeBoard == this) {
      _activeBoard = null;
    }
    _pulseController.dispose();
    super.dispose();
  }


  static void _hidePreviousActiveBoard() {


    if (_activeBoard != null && _activeBoard!.mounted) {
      _activeBoard!.setState(() {
        _activeBoard!._showNavigationIcon = false;
      });
    }

    _activeBoard = null;
  }


  static void hideActiveBoard() {
    _hidePreviousActiveBoard();
  }



  void _handleBoardTap() {

    if (_activeBoard != this) {
      _hidePreviousActiveBoard();
    }

    _activeBoard = this;

    setState(() {
      _showNavigationIcon = true;
    });
  }








  void _handleNavigationIconTap() {
    final ExtMove? em = widget.extMove;
    if (em != null && em.moveIndex != null && em.moveIndex! >= 0) {
      final int clickedIndex = em.moveIndex!;


      final GameController controller = GameController();
      List<String> mergedMoves = getMergedMoves(controller);


      String? fen;
      if (mergedMoves.isNotEmpty && mergedMoves[0].startsWith('[')) {
        fen = mergedMoves[0];
        mergedMoves = mergedMoves.sublist(1);
      }


      String ml = mergedMoves.sublist(0, clickedIndex + 1).join(' ');
      if (fen != null) {
        ml = '$fen $ml';
      }


      try {
        ImportService.import(ml);
      } catch (exception) {


        final String tip = "Cannot import partial moves: $ml";
        GameController().headerTipNotifier.showTip(tip);

        return;
      }


      HistoryNavigator.takeBackAll(context, pop: false);
      HistoryNavigator.stepForwardAll(context, pop: false);
    }


    setState(() {
      _showNavigationIcon = false;
    });


    widget.onNavigateMove?.call();


    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        onTap: _handleBoardTap,
        child: Stack(
          children: <Widget>[

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(DB().displaySettings.boardCornerRadius),
              child: Container(
                color: DB().colorSettings.boardBackgroundColor,
                child: CustomPaint(
                  painter: MiniBoardPainter(
                    boardLayout: widget.boardLayout,
                    extMove: widget.extMove,
                  ),
                  child: Container(), // Ensures the CustomPaint has a size.
                ),
              ),
            ),



            if (_showNavigationIcon && widget.extMove != null)
              Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: IconButton(

                    icon: Icon(
                      FluentIcons.arrow_undo_48_regular,
                      color: DB().colorSettings.boardLineColor,
                      size: 48.0,
                    ),
                    onPressed: _handleNavigationIconTap,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}






class MiniBoardPainter extends CustomPainter {
  MiniBoardPainter({
    required this.boardLayout,
    this.extMove,
  }) {
    boardState = _parseBoardLayout(boardLayout);
  }

  final String boardLayout;


  final ExtMove? extMove;


  late final List<PieceColor> boardState;



  static List<PieceColor> _parseBoardLayout(String layout) {
    final List<String> parts = layout.split('/');
    if (parts.length != 3 ||
        parts[0].length != 8 ||
        parts[1].length != 8 ||
        parts[2].length != 8) {

      return List<PieceColor>.filled(24, PieceColor.none);
    }

    final List<PieceColor> state = <PieceColor>[];












    for (int i = 0; i < 8; i++) {
      state.add(_charToPieceColor(parts[0][i]));
    }

    for (int i = 0; i < 8; i++) {
      state.add(_charToPieceColor(parts[1][i]));
    }

    for (int i = 0; i < 8; i++) {
      state.add(_charToPieceColor(parts[2][i]));
    }
    return state;
  }


  static PieceColor _charToPieceColor(String ch) {
    switch (ch) {
      case 'O':
        return PieceColor.white;
      case '@':
        return PieceColor.black;
      case 'X':
        return PieceColor.marked;
      default:
        return PieceColor.none;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double minSide = math.min(w, h);


    final double offsetX = (w - minSide) / 2;
    final double offsetY = (h - minSide) / 2;


    const double outerMarginFactor = 0.06;
    const double ringSpacingFactor = 0.13;


    const double pieceRadiusFactor = 0.05;

    final double outerMargin = minSide * outerMarginFactor;
    final double ringSpacing = minSide * ringSpacingFactor;
    final double pieceRadius = minSide * pieceRadiusFactor;


    final double marginMiddle = outerMargin + ringSpacing;
    final double marginInner = outerMargin + ringSpacing * 2;


    final Paint boardPaint = Paint()
      ..color = DB().colorSettings.boardLineColor
      ..style = PaintingStyle.stroke

      ..strokeWidth = math.max(1.0, minSide * 0.003);


    final List<Offset> outerPoints = _ringPoints(
      offsetX,
      offsetY,
      outerMargin,
      minSide - 2 * outerMargin,
    );
    final List<Offset> middlePoints = _ringPoints(
      offsetX,
      offsetY,
      marginMiddle,
      minSide - 2 * marginMiddle,
    );
    final List<Offset> innerPoints = _ringPoints(
      offsetX,
      offsetY,
      marginInner,
      minSide - 2 * marginInner,
    );


    _drawSquare(canvas, outerPoints, boardPaint);
    _drawSquare(canvas, middlePoints, boardPaint);
    _drawSquare(canvas, innerPoints, boardPaint);


    _drawLine(canvas, outerPoints[1], middlePoints[1], boardPaint);
    _drawLine(canvas, middlePoints[1], innerPoints[1], boardPaint);

    _drawLine(canvas, outerPoints[3], middlePoints[3], boardPaint);
    _drawLine(canvas, middlePoints[3], innerPoints[3], boardPaint);

    _drawLine(canvas, outerPoints[5], middlePoints[5], boardPaint);
    _drawLine(canvas, middlePoints[5], innerPoints[5], boardPaint);

    _drawLine(canvas, outerPoints[7], middlePoints[7], boardPaint);
    _drawLine(canvas, middlePoints[7], innerPoints[7], boardPaint);


    if (DB().ruleSettings.hasDiagonalLines) {
      canvas.drawLine(outerPoints[0], innerPoints[0], boardPaint);
      canvas.drawLine(outerPoints[2], innerPoints[2], boardPaint);
      canvas.drawLine(outerPoints[4], innerPoints[4], boardPaint);
      canvas.drawLine(outerPoints[6], innerPoints[6], boardPaint);
    }


    for (int i = 0; i < 24; i++) {
      final PieceColor pc = boardState[i];
      if (pc == PieceColor.none) {
        continue;
      }


      Offset pos;
      if (i < 8) {

        pos = innerPoints[(i + 1) % 8];
      } else if (i < 16) {

        pos = middlePoints[((i - 8) + 1) % 8];
      } else {

        pos = outerPoints[((i - 16) + 1) % 8];
      }


      final double pieceDiameter = pieceRadius * 2;










      final Paint paint = Paint();
      const double opacity = 1.0;
      final double circleOuterRadius = pieceDiameter / 2.0;
      final double circleInnerRadius = circleOuterRadius * 0.99;


      const ui.Image? pieceImage = null;
      if (pieceImage != null) {
        paintImage(
          canvas: canvas,
          rect: Rect.fromCircle(
            center: pos,
            radius: circleInnerRadius,
          ),
          image: pieceImage,
          fit: BoxFit.cover,
        );
      } else {

        canvas.drawShadow(
          Path()
            ..addOval(
              Rect.fromCircle(center: pos, radius: circleOuterRadius),
            ),
          Colors.black,
          2,
          true,
        );



        Color borderColor;
        if (pc == PieceColor.white) {
          borderColor = DB().colorSettings.whitePieceColor;
        } else if (pc == PieceColor.black) {
          borderColor = DB().colorSettings.blackPieceColor;
        } else if (pc == PieceColor.marked) {
          borderColor = DB().colorSettings.pieceHighlightColor;
        } else {
          borderColor = DB().colorSettings.boardLineColor;
        }


        paint.color = borderColor.withValues(alpha: opacity);


        if (DB().colorSettings.boardBackgroundColor == Colors.white) {
          paint.style = PaintingStyle.stroke;
          paint.strokeWidth = 4.0;
        } else {
          paint.style = PaintingStyle.fill;
        }
        canvas.drawCircle(pos, circleOuterRadius, paint);


        paint.style = PaintingStyle.fill;
        paint.color = borderColor.withValues(alpha: opacity);
        canvas.drawCircle(pos, circleInnerRadius, paint);
      }


    }


    _drawMoveHighlight(
      canvas,
      innerPoints,
      middlePoints,
      outerPoints,
      pieceRadius,
    );
  }







  void _drawMoveHighlight(
    Canvas canvas,
    List<Offset> innerPoints,
    List<Offset> middlePoints,
    List<Offset> outerPoints,
    double pieceRadius,
  ) {
    if (extMove == null) {
      return;
    }

    final MoveType type = extMove!.type;
    if (type == MoveType.none || type == MoveType.draw) {
      return;
    }


    final Offset? fromPos = _convertSquareToOffset(
      extMove!.from,
      innerPoints,
      middlePoints,
      outerPoints,
    );
    final Offset? toPos = _convertSquareToOffset(
      extMove!.to,
      innerPoints,
      middlePoints,
      outerPoints,
    );


    if (fromPos != null && extMove!.from >= 8) {

      final int? fromIndex = _convertSquareToBoardIndex(extMove!.from);
      if (fromIndex != null && fromIndex >= 0 && fromIndex < 24) {
        final PieceColor fromPc = boardState[fromIndex];
        if (fromPc != PieceColor.none) {

          final Paint blurPaint = Paint()..style = PaintingStyle.fill;

          final Color c = (fromPc == PieceColor.white)
              ? DB().colorSettings.whitePieceColor.withValues(alpha: 0.3)
              : (fromPc == PieceColor.black)
                  ? DB().colorSettings.blackPieceColor.withValues(alpha: 0.3)
                  : DB()
                      .colorSettings
                      .pieceHighlightColor
                      .withValues(alpha: 0.3);
          blurPaint.color = c;


          canvas.drawCircle(fromPos, pieceRadius * 0.8, blurPaint);
        }
      }
    }


    if (type != MoveType.remove && toPos != null && extMove!.to >= 8) {
      final Paint focusPaint = Paint()
        ..color = DB().colorSettings.pieceHighlightColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(toPos, pieceRadius, focusPaint);
    }


    final Paint highlightPaint = Paint()
      ..color = DB().colorSettings.pieceHighlightColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    switch (type) {
      case MoveType.place:


        break;

      case MoveType.move:
        if (fromPos != null && toPos != null) {
          final Offset v = toPos - fromPos;
          final double magnitude = v.distance;
          if (magnitude == 0) {
            return;
          }
          final Offset normalizedV = Offset(v.dx / magnitude, v.dy / magnitude);
          final Offset newFromPos = fromPos + normalizedV * pieceRadius;
          final Offset newToPos = toPos - normalizedV * pieceRadius;
          final double arrowSize = pieceRadius * 0.8;

          canvas.drawLine(newFromPos, newToPos, highlightPaint);
          _drawArrowHead(
              canvas, newFromPos, newToPos, highlightPaint, arrowSize);
        }
        break;

      case MoveType.remove:

        if (toPos != null) {
          PieceColor removedPieceColor;
          if (extMove!.side == PieceColor.white) {
            removedPieceColor = PieceColor.black;
          } else if (extMove!.side == PieceColor.black) {
            removedPieceColor = PieceColor.white;
          } else {
            removedPieceColor = PieceColor.none;
          }

          Color xColor;
          if (removedPieceColor == PieceColor.white) {
            xColor = DB().colorSettings.whitePieceColor;
          } else if (removedPieceColor == PieceColor.black) {
            xColor = DB().colorSettings.blackPieceColor;
          } else {
            xColor = DB().colorSettings.pieceHighlightColor;
          }

          final Paint xPaint = Paint()
            ..color = xColor
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;

          _drawHighlightX(canvas, toPos, pieceRadius * 2.0, xPaint);
        }
        break;

      case MoveType.none:
      case MoveType.draw:
        break;
    }
  }










  Offset? _convertSquareToOffset(
    int sq,
    List<Offset> innerPoints,
    List<Offset> middlePoints,
    List<Offset> outerPoints,
  ) {

    if (sq < 8 || sq > 31) {
      return null;
    }


    if (sq < 16) {

      final int index = (sq - 8 + 1) % 8;
      return innerPoints[index];
    } else if (sq < 24) {

      final int index = (sq - 16 + 1) % 8;
      return middlePoints[index];
    } else {

      final int index = (sq - 24 + 1) % 8;
      return outerPoints[index];
    }
  }



  int? _convertSquareToBoardIndex(int sq) {
    if (sq < 8 || sq > 31) {
      return null;
    }

    if (sq < 16) {

      return sq - 8;
    } else if (sq < 24) {

      return (sq - 16) + 8;
    } else {

      return (sq - 24) + 16;
    }
  }


  void _drawArrowHead(
      Canvas canvas, Offset from, Offset to, Paint paint, double arrowSize) {
    final double angle = math.atan2(to.dy - from.dy, to.dx - from.dx);

    final Offset arrowP1 = Offset(
      to.dx - arrowSize * math.cos(angle - math.pi / 6),
      to.dy - arrowSize * math.sin(angle - math.pi / 6),
    );
    final Offset arrowP2 = Offset(
      to.dx - arrowSize * math.cos(angle + math.pi / 6),
      to.dy - arrowSize * math.sin(angle + math.pi / 6),
    );

    final Path path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(arrowP1.dx, arrowP1.dy)
      ..moveTo(to.dx, to.dy)
      ..lineTo(arrowP2.dx, arrowP2.dy);

    canvas.drawPath(path, paint);
  }



  void _drawHighlightX(
      Canvas canvas, Offset center, double xSize, Paint paint) {
    final double half = xSize / 2;
    final Offset topLeft = Offset(center.dx - half, center.dy - half);
    final Offset topRight = Offset(center.dx + half, center.dy - half);
    final Offset bottomLeft = Offset(center.dx - half, center.dy + half);
    final Offset bottomRight = Offset(center.dx + half, center.dy + half);

    final Path path = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..moveTo(topRight.dx, topRight.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy);

    canvas.drawPath(path, paint);
  }










  List<Offset> _ringPoints(
    double baseX,
    double baseY,
    double offset,
    double ringSide,
  ) {
    final double left = baseX + offset;
    final double top = baseY + offset;
    final double right = left + ringSide;
    final double bottom = top + ringSide;
    final double centerX = left + ringSide / 2;
    final double centerY = top + ringSide / 2;

    return <Offset>[
      Offset(left, top), // 0: top-left
      Offset(centerX, top), // 1: top-center
      Offset(right, top), // 2: top-right
      Offset(right, centerY), // 3: right-center
      Offset(right, bottom), // 4: bottom-right
      Offset(centerX, bottom), // 5: bottom-center
      Offset(left, bottom), // 6: bottom-left
      Offset(left, centerY), // 7: left-center
    ];
  }


  void _drawSquare(Canvas canvas, List<Offset> points, Paint paint) {
    final Path path = Path()..addPolygon(points, true);
    canvas.drawPath(path, paint);
  }


  void _drawLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(covariant MiniBoardPainter oldDelegate) {

    return oldDelegate.boardLayout != boardLayout ||
        oldDelegate.extMove?.move != extMove?.move;
  }
}
