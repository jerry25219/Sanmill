




part of '../../../game_page/services/painters/painters.dart';





class PiecePainter extends CustomPainter {
  PiecePainter({
    required this.placeAnimationValue,
    required this.moveAnimationValue,
    required this.removeAnimationValue,
    required this.pieceImages,
    required this.placeEffectAnimation,
    required this.removeEffectAnimation,
  });

  final double placeAnimationValue;
  final double moveAnimationValue;
  final double removeAnimationValue;

  final Map<PieceColor, ui.Image?>? pieceImages;


  final PieceEffectAnimation placeEffectAnimation;
  final PieceEffectAnimation removeEffectAnimation;

  @override
  void paint(Canvas canvas, Size size) {
    assert(size.width == size.height);
    final int? focusIndex = GameController().gameInstance.focusIndex;
    final int? blurIndex = GameController().gameInstance.blurIndex;
    final int? removeIndex = GameController().gameInstance.removeIndex;

    final Paint paint = Paint();
    final Path shadowPath = Path();


    final List<Piece> normalPiecesToDraw = <Piece>[];
    final List<Piece> movingPiecesToDraw = <Piece>[];

    final double pieceWidth = (size.width - AppTheme.boardPadding * 2) *
            DB().displaySettings.pieceWidth /
            6 -
        1;


    Offset? movingPos;


    for (int row = 0; row < 7; row++) {
      for (int col = 0; col < 7; col++) {
        final int index = row * 7 + col;

        final PieceColor pieceColor =
            GameController().position.pieceOnGrid(index);

        Offset pos;


        final bool isPlacingPiece = (placeAnimationValue < 1.0) &&
            (focusIndex != null) &&
            (blurIndex == null) &&
            (index == focusIndex);


        final bool isMovingPiece = (moveAnimationValue < 1.0) &&
            (focusIndex != null) &&
            (blurIndex != null) &&
            (index == focusIndex) &&
            !GameController().animationManager.isRemoveAnimationAnimating();


        final bool isRemovingPiece = (removeAnimationValue < 1.0) &&
            (removeIndex != null) &&
            (index == removeIndex);

        if (isPlacingPiece) {
          pos = pointFromIndex(index, size);

          placeEffectAnimation.draw(
            canvas,
            pos,
            pieceWidth,
            placeAnimationValue,
          );

        }

        if (isMovingPiece) {

          final Offset fromPos = pointFromIndex(blurIndex, size);
          final Offset toPos = pointFromIndex(focusIndex, size);

          pos = Offset.lerp(fromPos, toPos, moveAnimationValue)!;


          movingPos = pos;
        } else {

          pos = pointFromIndex(index, size);
        }

        if (isRemovingPiece) {
          removeEffectAnimation.draw(
            canvas,
            pos,
            pieceWidth,
            removeAnimationValue,
          );
          continue;
        }

        if (pieceColor == PieceColor.none) {
          continue;
        }

        final int sq = indexToSquare[index]!;
        final SquareAttribute squareAttribute =
            GameController().position.sqAttrList[sq];

        final ui.Image? image =
            pieceImages == null ? null : pieceImages?[pieceColor];

        final double adjustedPieceWidth = pieceWidth;

        final Piece piece = Piece(
          pieceColor: pieceColor,
          pos: pos,
          diameter: adjustedPieceWidth,
          index: index,
          squareAttribute: squareAttribute,
          image: image,
        );


        if (isMovingPiece) {
          movingPiecesToDraw.add(piece);
        } else {
          normalPiecesToDraw.add(piece);
        }

        shadowPath.addOval(
          Rect.fromCircle(
            center: pos,
            radius: adjustedPieceWidth / 2,
          ),
        );
      }
    }


    for (final Piece piece in normalPiecesToDraw) {
      if (piece.image == null) {
        canvas.drawShadow(
          Path()
            ..addOval(
              Rect.fromCircle(
                center: piece.pos,
                radius: piece.diameter / 2,
              ),
            ),
          Colors.black,
          2,
          true,
        );
      }
    }


    for (final Piece piece in movingPiecesToDraw) {
      if (piece.image == null) {
        canvas.drawShadow(
          Path()
            ..addOval(
              Rect.fromCircle(
                center: piece.pos,
                radius: piece.diameter / 2,
              ),
            ),
          Colors.black,
          2,
          true,
        );
      }
    }

    paint.style = PaintingStyle.fill;

    Color blurPositionColor = Colors.transparent;


    for (final Piece piece in normalPiecesToDraw) {
      blurPositionColor = piece.pieceColor.blurPositionColor;

      const double opacity = 1.0;

      final double pieceRadius = piece.diameter / 2;
      final double pieceInnerRadius = pieceRadius * 0.99;

      if (piece.image != null) {
        paintImage(
          canvas: canvas,
          rect: Rect.fromCircle(
            center: piece.pos,
            radius: pieceInnerRadius,
          ),
          image: piece.image!,
          fit: BoxFit.cover,
        );
      } else {

        paint.color = piece.pieceColor.borderColor.withValues(alpha: opacity);

        if (DB().colorSettings.boardBackgroundColor == Colors.white) {
          paint.style = PaintingStyle.stroke;
          paint.strokeWidth = 4.0;
        } else {
          paint.style = PaintingStyle.fill;
        }

        canvas.drawCircle(
          piece.pos,
          pieceRadius,
          paint,
        );


        paint.style = PaintingStyle.fill;
        paint.color = piece.pieceColor.mainColor.withValues(alpha: opacity);
        canvas.drawCircle(
          piece.pos,
          pieceInnerRadius,
          paint,
        );
      }


      if (DB().displaySettings.isNumbersOnPiecesShown &&
          piece.squareAttribute?.placedPieceNumber != null &&
          piece.squareAttribute!.placedPieceNumber > 0) {

        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: piece.squareAttribute?.placedPieceNumber.toString(),
            style: TextStyle(
              color: piece.pieceColor.mainColor.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
              fontSize: piece.diameter * 0.5,
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();


        final Offset textOffset = Offset(
          piece.pos.dx - textPainter.width / 2,
          piece.pos.dy - textPainter.height / 2,
        );

        textPainter.paint(canvas, textOffset);
      }
    }


    for (final Piece piece in movingPiecesToDraw) {
      blurPositionColor = piece.pieceColor.blurPositionColor;

      const double opacity = 1.0;

      final double pieceRadius = piece.diameter / 2;
      final double pieceInnerRadius = pieceRadius * 0.99;

      if (piece.image != null) {
        paintImage(
          canvas: canvas,
          rect: Rect.fromCircle(
            center: piece.pos,
            radius: pieceInnerRadius,
          ),
          image: piece.image!,
          fit: BoxFit.cover,
        );
      } else {

        paint.color = piece.pieceColor.borderColor.withValues(alpha: opacity);

        if (DB().colorSettings.boardBackgroundColor == Colors.white) {
          paint.style = PaintingStyle.stroke;
          paint.strokeWidth = 4.0;
        } else {
          paint.style = PaintingStyle.fill;
        }

        canvas.drawCircle(
          piece.pos,
          pieceRadius,
          paint,
        );


        paint.style = PaintingStyle.fill;
        paint.color = piece.pieceColor.mainColor.withValues(alpha: opacity);
        canvas.drawCircle(
          piece.pos,
          pieceInnerRadius,
          paint,
        );
      }


      if (DB().displaySettings.isNumbersOnPiecesShown &&
          piece.squareAttribute?.placedPieceNumber != null &&
          piece.squareAttribute!.placedPieceNumber > 0) {

        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: piece.squareAttribute?.placedPieceNumber.toString(),
            style: TextStyle(
              color: piece.pieceColor.mainColor.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
              fontSize: piece.diameter * 0.5,
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();


        final Offset textOffset = Offset(
          piece.pos.dx - textPainter.width / 2,
          piece.pos.dy - textPainter.height / 2,
        );

        textPainter.paint(canvas, textOffset);
      }
    }


    if (focusIndex != null &&
        GameController().gameInstance.gameMode != GameMode.setupPosition) {
      paint.color = DB().colorSettings.pieceHighlightColor;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;


      final Offset focusPos = movingPos ?? pointFromIndex(focusIndex, size);

      canvas.drawCircle(
        focusPos,
        pieceWidth / 2,
        paint,
      );
    }

    if (blurIndex != null &&
        GameController().gameInstance.gameMode != GameMode.setupPosition) {
      if (kDebugMode) {
        if (blurPositionColor == Colors.transparent) {
          throw Exception('Blur position color is transparent');
        }
      }
      paint.color = blurPositionColor;
      paint.style = PaintingStyle.fill;


      canvas.drawCircle(
        pointFromIndex(blurIndex, size),
        pieceWidth / 2 * 0.8,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(PiecePainter oldDelegate) =>
      placeAnimationValue != oldDelegate.placeAnimationValue ||
      moveAnimationValue != oldDelegate.moveAnimationValue ||
      removeAnimationValue != oldDelegate.removeAnimationValue;
}
