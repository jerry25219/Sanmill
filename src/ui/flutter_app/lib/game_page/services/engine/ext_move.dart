




part of '../mill.dart';

enum MoveType { place, move, remove, draw, none }

class MoveParser {
  MoveType parseMoveType(String move) {
    if (move.startsWith("x") && move.length == 3) {
      return MoveType.remove;
    } else if (move.contains("-") && move.length == 5) {
      return MoveType.move;
    } else if (RegExp(r'^[a-g][1-8]$').hasMatch(move) && move.length == 2) {
      return MoveType.place;
    } else if (move == "draw") {
      logger.i("[TODO] Computer request draw");
      return MoveType.draw;
    } else if (move == "(none)" || move == "none") {
      logger.i("MoveType is (none).");
      return MoveType.none;
    } else {

      throw const FormatException();
    }
  }
}



class ExtMove extends PgnNodeData {








  ExtMove(
    this.move, {
    required this.side,
    this.boardLayout,
    this.moveIndex,
    this.roundIndex,
    super.nags,
    super.startingComments,
    super.comments,
  })  : type = MoveParser().parseMoveType(move),
        to = _parseToSquare(move),

        super(

          san: move,
        ) {
    _checkLegal(move);
  }


  final String move;


  final PieceColor side;


  final MoveType type;


  final int to;


  String? boardLayout;


  int? moveIndex;








  int? roundIndex;

  static const String _logTag = "[Move]";


  int get from {
    if (type != MoveType.move) {
      return -1;
    }


    if (move.contains("-") && move.length == 5 && !move.contains("(")) {

      final List<String> parts = move.split("-");
      if (parts.length == 2) {
        return _standardNotationToSquare(parts[0].trim());
      }
    }

    return -1;
  }

  static int _parseToSquare(String move) {
    MoveParser().parseMoveType(move);


    if (move.startsWith("x") && move.length == 3) {

      final String target = move.substring(1).trim();
      return _standardNotationToSquare(target);
    } else if (move.contains("-") && move.length == 5) {

      final List<String> parts = move.split("-");
      if (parts.length == 2) {
        return _standardNotationToSquare(parts[1].trim());
      }
    } else if (RegExp(r'^[a-g][1-7]$').hasMatch(move)) {

      return _standardNotationToSquare(move);
    }

    return -1;
  }

  static int _standardNotationToSquare(String notation) {
    final Map<String, int> standardToSquare = <String, int>{

      "d5": 8, "e5": 9, "e4": 10, "e3": 11,
      "d3": 12, "c3": 13, "c4": 14, "c5": 15,

      "d6": 16, "f6": 17, "f4": 18, "f2": 19,
      "d2": 20, "b2": 21, "b4": 22, "b6": 23,

      "d7": 24, "g7": 25, "g4": 26, "g1": 27,
      "d1": 28, "a1": 29, "a4": 30, "a7": 31
    };

    return standardToSquare[notation.toLowerCase()] ?? -1;
  }

  static final Map<int, String> _squareToWmdNotation = <int, String>{
    -1: "(none)", // TODO: Can parse it?
    0: "draw", // TODO: Can parse it?
    8: "d5",
    9: "e5",
    10: "e4",
    11: "e3",
    12: "d3",
    13: "c3",
    14: "c4",
    15: "c5",
    16: "d6",
    17: "f6",
    18: "f4",
    19: "f2",
    20: "d2",
    21: "b2",
    22: "b4",
    23: "b6",
    24: "d7",
    25: "g7",
    26: "g4",
    27: "g1",
    28: "d1",
    29: "a1",
    30: "a4",
    31: "a7"
  };

  static String sqToNotation(int sq) {
    final String? ret = _squareToWmdNotation[sq];
    return ret ?? "";
  }


  static void _checkLegal(String move) {

    if (move == "draw" || move == "(none)" || move == "none") {
      return;
    }


    if (RegExp(r'^[a-g][1-7]$').hasMatch(move)) {

      return;
    }

    if (move.startsWith("x") && RegExp(r'^x[a-g][1-7]$').hasMatch(move)) {

      return;
    }

    if (RegExp(r'^[a-g][1-7]-[a-g][1-7]$').hasMatch(move)) {

      final List<String> parts = move.split("-");
      if (parts[0] == parts[1]) {
        throw Exception(
            "$_logTag Invalid Move: cannot move to the same place.");
      }
      return;
    }

    throw FormatException("$_logTag Invalid Move: ", move);
  }



  String get notation {
    final bool useUpperCase = DB().generalSettings.screenReaderSupport;
    final int f = from;
    final String? fromStr = _squareToWmdNotation[f];
    final String? toStr = _squareToWmdNotation[to];
    switch (type) {
      case MoveType.remove:
        return useUpperCase ? "x${toStr?.toUpperCase()}" : "x$toStr";
      case MoveType.move:
        final String sep = useUpperCase ? "-" : "-";
        return useUpperCase
            ? "${fromStr?.toUpperCase()}$sep${toStr?.toUpperCase()}"
            : "$fromStr$sep$toStr";
      case MoveType.place:
      case MoveType.draw:
      case MoveType.none:
        return useUpperCase ? toStr?.toUpperCase() ?? "" : toStr ?? "";
    }
  }
}

class EngineRet {
  EngineRet(this.value, this.aiMoveType, this.extMove);

  String? value;
  ExtMove? extMove;
  AiMoveType? aiMoveType;
}
