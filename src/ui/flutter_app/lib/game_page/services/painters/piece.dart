




import 'dart:ui';

import '../mill.dart';




class Piece {
  const Piece({
    required this.pieceColor,
    required this.pos,
    required this.diameter,
    required this.index,
    this.squareAttribute,
    this.image,
  });


  final PieceColor pieceColor;


  final Offset pos;


  final double diameter;


  final int index;

  final SquareAttribute? squareAttribute;
  final Image? image;
}
