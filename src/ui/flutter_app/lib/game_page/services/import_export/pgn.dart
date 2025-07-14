




import 'dart:math' as math;

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';

import '../mill.dart';

typedef PgnHeaders = Map<String, String>;





String fromPgn(String? result) {
  if (result == '1-0' || result == '0-1' || result == '1/2-1/2') {
    return result!;
  }
  return '*';
}


String toPgnString(String result) => result;


@immutable
class Square {
  const Square(this.name);

  final String name;

  static Square? parse(String str) {

    if (str.length == 2) {
      final int file = str.codeUnitAt(0);
      final int rank = str.codeUnitAt(1);
      if (file >= 97 && file <= 103 && rank >= 49 && rank <= 55) {
        return Square(str);
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Square && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}


class _TransformStackFrame<U extends PgnNodeData, T extends PgnNodeData, C> {
  _TransformStackFrame({
    required this.after,
    required this.before,
    required this.context,
  });

  PgnNode<U> after;
  PgnNode<T> before;
  C context;
}



























































class PgnGame<T extends PgnNodeData> {
  PgnGame({required this.headers, required this.moves, required this.comments});

  final PgnHeaders headers;
  final List<String> comments;
  final PgnNode<T> moves;

  static PgnHeaders defaultHeaders() => <String, String>{
        'Event': '?',
        'Site': '?',
        'Date': '????.??.??',
        'Round': '?',
        'White': '?',
        'Black': '?',
        'Result': '*'
      };

  static PgnHeaders emptyHeaders() => <String, String>{};

  static PgnGame<PgnNodeData> parsePgn(String pgn,
      {PgnHeaders Function() initHeaders = defaultHeaders}) {
    final List<PgnGame<PgnNodeData>> games = <PgnGame<PgnNodeData>>[];
    _PgnParser((PgnGame<PgnNodeData> game) {
      games.add(game);
    }, initHeaders)
        .parse(pgn);

    if (games.isEmpty) {
      return PgnGame<PgnNodeData>(
        headers: initHeaders(),
        moves: PgnNode<PgnNodeData>(),
        comments: const <String>[],
      );
    }
    return games[0];
  }

  static List<PgnGame<PgnNodeData>> parseMultiGamePgn(String pgn,
      {PgnHeaders Function() initHeaders = defaultHeaders}) {
    final RegExp multiGamePgnSplit = RegExp(r'\n\s+(?=\[)');
    final List<PgnGame<PgnNodeData>> games = <PgnGame<PgnNodeData>>[];
    final List<String> pgnGames = pgn.split(multiGamePgnSplit);
    for (final String pgnGame in pgnGames) {
      final List<PgnGame<PgnNodeData>> parsedGames = <PgnGame<PgnNodeData>>[];
      _PgnParser((PgnGame<PgnNodeData> game) {
        parsedGames.add(game);
      }, initHeaders)
          .parse(pgnGame);
      if (parsedGames.isNotEmpty) {
        games.add(parsedGames[0]);
      }
    }
    return games;
  }

  static Position startingPosition(PgnHeaders headers) {
    final Position pos = Position();
    pos.reset();
    if (headers.containsKey('FEN')) {
      final String fen = headers['FEN']!;
      if (!pos.setFen(fen)) {
        throw Exception("Invalid FEN: $fen");
      }
    }
    return pos;
  }

  String makePgn() {
    final StringBuffer builder = StringBuffer();
    final StringBuffer token = StringBuffer();

    if (headers.isNotEmpty) {
      headers.forEach((String key, String value) {
        builder.writeln('[$key "${_escapeHeader(value)}"]');
      });
      builder.write('\n');
    }

    for (final String comment in comments) {
      builder.writeln('{ ${_safeComment(comment)} }');
    }

    final String? fen = headers['FEN'];
    final int initialPly = fen != null ? _getPlyFromSetup(fen) : 0;

    final List<_PgnFrame> stack = <_PgnFrame>[];

    if (moves.children.isNotEmpty) {
      final Iterator<PgnNode<T>> variations = moves.children.iterator;
      variations.moveNext();
      stack.add(_PgnFrame(
        state: _PgnState.pre,
        ply: initialPly,
        node: variations.current,
        sidelines: variations,
        startsVariation: false,
        inVariation: false,
      ));
    }

    bool forceMoveNumber = true;
    while (stack.isNotEmpty) {
      final _PgnFrame frame = stack.last;

      if (frame.inVariation) {
        token.write(') ');
        frame.inVariation = false;
        forceMoveNumber = true;
      }

      switch (frame.state) {
        case _PgnState.pre:
          {

            if (frame.node.data?.startingComments != null) {
              for (final String comment in frame.node.data!.startingComments!) {
                token.write('{ ${_safeComment(comment)} } ');
              }
              forceMoveNumber = true;
            }
            if (forceMoveNumber || frame.ply.isEven) {
              token.write(
                '${(frame.ply / 2).floor() + 1}'
                '${frame.ply.isOdd ? "..." : "."} ',
              );
              forceMoveNumber = false;
            }
            if (frame.node.data != null) {
              token.write('${frame.node.data!.san} ');
              if (frame.node.data!.nags != null) {
                for (final int nag in frame.node.data!.nags!) {
                  token.write('\$$nag ');
                }
                forceMoveNumber = true;
              }
              if (frame.node.data!.comments != null) {
                for (final String comment in frame.node.data!.comments!) {
                  token.write('{ ${_safeComment(comment)} } ');
                }
              }
            }
            frame.state = _PgnState.sidelines;
            continue;
          }

        case _PgnState.sidelines:
          {
            final bool child = frame.sidelines.moveNext();
            if (child) {
              token.write('( ');
              forceMoveNumber = true;
              stack.add(_PgnFrame(
                state: _PgnState.pre,
                ply: frame.ply,
                node: frame.sidelines.current,
                sidelines: <PgnNode<PgnNodeData>>[].iterator,
                startsVariation: true,
                inVariation: false,
              ));
              frame.inVariation = true;
            } else {
              if (frame.node.children.isNotEmpty) {
                final Iterator<PgnNode<PgnNodeData>> variations =
                    frame.node.children.iterator;
                variations.moveNext();
                stack.add(_PgnFrame(
                  state: _PgnState.pre,
                  ply: frame.ply + 1,
                  node: variations.current,
                  sidelines: variations,
                  startsVariation: false,
                  inVariation: false,
                ));
              }
              frame.state = _PgnState.end;
            }
            break;
          }

        case _PgnState.end:
          {
            stack.removeLast();
          }
      }
    }
    token.write(toPgnString(fromPgn(headers['Result'])));
    builder.writeln(token.toString());
    return builder.toString();
  }
}


class PgnNodeData {
  PgnNodeData({
    required this.san,
    this.startingComments,
    this.comments,
    this.nags,
  });


  final String san;


  final List<String>? startingComments;


  List<String>? comments;


  List<int>? nags;
}



class PgnNode<T extends PgnNodeData> {

  PgnNode([this.data]);


  T? data;


  PgnNode<T>? parent;


  final List<PgnNode<T>> children = <PgnNode<T>>[];



  Iterable<T> mainline() sync* {
    PgnNode<T> node = this;
    while (node.children.isNotEmpty) {
      final PgnNode<T> child = node.children[0];
      if (child.data != null) {
        yield child.data!;
      }
      node = child;
    }
  }






  PgnNode<U> transform<U extends PgnNodeData, C>(
      C context, (C, U)? Function(C context, T data, int childIndex) f) {
    final PgnNode<U> root = PgnNode<U>();
    final List<_TransformStackFrame<U, T, C>> stack =
        <_TransformStackFrame<U, T, C>>[
      _TransformStackFrame<U, T, C>(after: root, before: this, context: context)
    ];

    while (stack.isNotEmpty) {
      final _TransformStackFrame<U, T, C> frame = stack.removeLast();


      if (frame.before.data != null) {
        final T originalData = frame.before.data!;

        final (C, U)? result = f(frame.context, originalData, -1);
        if (result == null) {

          continue;
        }
        final (C newCtx, U data) = result;
        frame.context = newCtx;


        frame.after.data = data;
      }


      for (int childIdx = 0;
          childIdx < frame.before.children.length;
          childIdx++) {
        final PgnNode<T> childBefore = frame.before.children[childIdx];
        if (childBefore.data == null) {

          continue;
        }
        final (C, U)? transformData =
            f(frame.context, childBefore.data!, childIdx);
        if (transformData != null) {
          final (C newCtx, U data) = transformData;
          final PgnNode<U> childAfter = PgnNode<U>(data);
          childAfter.parent = frame.after;
          frame.after.children.add(childAfter);

          stack.add(
            _TransformStackFrame<U, T, C>(
              after: childAfter,
              before: childBefore,
              context: newCtx,
            ),
          );
        }
      }
    }
    return root;
  }
}




enum CommentShapeColor {
  green,
  red,
  yellow,
  blue;

  String get string {
    switch (this) {
      case CommentShapeColor.green:
        return 'Green';
      case CommentShapeColor.red:
        return 'Red';
      case CommentShapeColor.yellow:
        return 'Yellow';
      case CommentShapeColor.blue:
        return 'Blue';
    }
  }

  static CommentShapeColor? parseShapeColor(String str) {
    switch (str) {
      case 'G':
        return CommentShapeColor.green;
      case 'R':
        return CommentShapeColor.red;
      case 'Y':
        return CommentShapeColor.yellow;
      case 'B':
        return CommentShapeColor.blue;
      default:
        return null;
    }
  }
}




@immutable
class PgnCommentShape {
  const PgnCommentShape({
    required this.color,
    required this.from,
    required this.to,
  });

  final CommentShapeColor color;
  final Square from;
  final Square to;

  @override
  String toString() {
    return to == from
        ? '${color.string[0]}${to.name}'
        : '${color.string[0]}${from.name}${to.name}';
  }

  static PgnCommentShape? fromPgn(String str) {
    final CommentShapeColor? color = CommentShapeColor.parseShapeColor(
      str.substring(0, 1),
    );
    final Square? from = Square.parse(str.substring(1, 3));
    if (color == null || from == null) {
      return null;
    }
    if (str.length == 3) {
      return PgnCommentShape(color: color, from: from, to: from);
    }
    final Square? to = Square.parse(str.substring(3, 5));
    if (str.length == 5 && to != null) {
      return PgnCommentShape(color: color, from: from, to: to);
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PgnCommentShape &&
          color == other.color &&
          from == other.from &&
          to == other.to;

  @override
  int get hashCode => Object.hash(color, from, to);
}


enum EvalType { pawns, mate }


@immutable
class PgnEvaluation {
  const PgnEvaluation.pawns({
    required this.pawns,
    this.depth,
    this.mate,
    this.evalType = EvalType.pawns,
  });

  const PgnEvaluation.mate({
    required this.mate,
    this.depth,
    this.pawns,
    this.evalType = EvalType.mate,
  });

  final double? pawns;
  final int? mate;
  final int? depth;
  final EvalType evalType;

  bool isPawns() => evalType == EvalType.pawns;

  String toPgn() {
    String str = '';
    if (isPawns()) {
      str = pawns!.toStringAsFixed(2);
    } else {
      str = '#$mate';
    }
    if (depth != null) {
      str = '$str,$depth';
    }
    return str;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PgnEvaluation &&
          pawns == other.pawns &&
          depth == other.depth &&
          mate == other.mate &&
          evalType == other.evalType;

  @override
  int get hashCode => Object.hash(pawns, depth, mate, evalType);
}


@immutable
class PgnComment {
  const PgnComment({
    this.text,
    this.shapes = const IListConst<PgnCommentShape>(<PgnCommentShape>[]),
    this.clock,
    this.emt,
    this.eval,
  }) : assert(text == null || text != '');

  factory PgnComment.fromPgn(String comment) {
    Duration? emt;
    Duration? clock;
    final List<PgnCommentShape> shapes = <PgnCommentShape>[];
    PgnEvaluation? eval;

    final String text = comment.replaceAllMapped(
        RegExp(
            r'\s?\[%(emt|clk)\s(\d{1,5}):(\d{1,2}):(\d{1,2}(?:\.\d{0,3})?)\]\s?'),
        (Match match) {
      final String? annotation = match.group(1);
      final String? hours = match.group(2);
      final String? minutes = match.group(3);
      final String? seconds = match.group(4);
      final double secondsValue = double.parse(seconds!);
      final Duration duration = Duration(
        hours: int.parse(hours!),
        minutes: int.parse(minutes!),
        seconds: secondsValue.truncate(),
        milliseconds: ((secondsValue - secondsValue.truncate()) * 1000).round(),
      );
      if (annotation == 'emt') {
        emt = duration;
      } else if (annotation == 'clk') {
        clock = duration;
      }
      return '  ';
    }).replaceAllMapped(
        RegExp(
            r'\s?\[%(?:csl|cal)\s([RGYB][a-g][1-7](?:[a-g][1-7])?(?:,[RGYB][a-g][1-7](?:[a-g][1-7])?)*)\]\s?'),
        (Match match) {
      final String? arrows = match.group(1);
      if (arrows != null) {
        for (final String arrow in arrows.split(',')) {
          final PgnCommentShape? shape = PgnCommentShape.fromPgn(arrow);
          if (shape != null) {
            shapes.add(shape);
          }
        }
      }
      return '  ';
    }).replaceAllMapped(
        RegExp(
            r'\s?\[%eval\s(?:#([+-]?\d{1,5})|([+-]?(?:\d{1,5}|\d{0,5}\.\d{1,2})))(?:,(\d{1,5}))?\]\s?'),
        (Match match) {
      final String? mate = match.group(1);
      final String? pawns = match.group(2);
      final String? d = match.group(3);
      final int? depth = d != null ? int.parse(d) : null;
      eval = mate != null
          ? PgnEvaluation.mate(mate: int.parse(mate), depth: depth)
          : PgnEvaluation.pawns(
              pawns: pawns != null ? double.parse(pawns) : null, depth: depth);
      return '  ';
    }).trim();

    return PgnComment(
      text: text.isNotEmpty ? text : null,
      shapes: IList<PgnCommentShape>(shapes),
      emt: emt,
      clock: clock,
      eval: eval,
    );
  }


  final String? text;


  final IList<PgnCommentShape> shapes;


  final Duration? clock;


  final Duration? emt;


  final PgnEvaluation? eval;

  String makeComment() {
    final List<String> builder = <String>[];
    if (text != null) {
      builder.add(text!);
    }
    final Iterable<String> circles = shapes
        .where((PgnCommentShape shape) => shape.to == shape.from)
        .map((PgnCommentShape shape) => shape.toString());
    if (circles.isNotEmpty) {
      builder.add('[%csl ${circles.join(",")}]');
    }
    final Iterable<String> arrows = shapes
        .where((PgnCommentShape shape) => shape.to != shape.from)
        .map((PgnCommentShape shape) => shape.toString());
    if (arrows.isNotEmpty) {
      builder.add('[%cal ${arrows.join(",")}]');
    }
    if (eval != null) {
      builder.add('[%eval ${eval!.toPgn()}]');
    }
    if (emt != null) {
      builder.add('[%emt ${_makeClk(emt!)}]');
    }
    if (clock != null) {
      builder.add('[%clk ${_makeClk(clock!)}]');
    }
    return builder.join(' ');
  }

  @override
  String toString() {
    return 'PgnComment(text: $text, shapes: $shapes, emt: $emt, '
        'clock: $clock, eval: $eval)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PgnComment &&
            text == other.text &&
            shapes == other.shapes &&
            clock == other.clock &&
            emt == other.emt &&
            eval == other.eval;
  }

  @override
  int get hashCode => Object.hash(text, shapes, clock, emt, eval);
}


class _ParserFrame {
  _ParserFrame({required this.parent, required this.root});

  PgnNode<PgnNodeData> parent;
  bool root;
  PgnNode<PgnNodeData>? node;
  List<String>? startingComments;
}

enum _ParserState { bom, pre, headers, moves, comment }

enum _PgnState { pre, sidelines, end }

class _PgnFrame {
  _PgnFrame({
    required this.state,
    required this.ply,
    required this.node,
    required this.sidelines,
    required this.startsVariation,
    required this.inVariation,
  });

  _PgnState state;
  int ply;
  PgnNode<PgnNodeData> node;
  Iterator<PgnNode<PgnNodeData>> sidelines;
  bool startsVariation;
  bool inVariation;
}


String _escapeHeader(String value) =>
    value.replaceAll(RegExp(r'\\'), r'\\').replaceAll(RegExp('"'), r'\"');


String _safeComment(String value) => value.replaceAll(RegExp(r'\}'), '');


int _getPlyFromSetup(String fen) {
  return 0;
}

const String _bom = '\ufeff';

bool _isWhitespace(String line) => RegExp(r'^\s*$').hasMatch(line);

bool _isCommentLine(String line) => line.startsWith('%');


class _PgnParser {
  _PgnParser(this.emitGame, this.initHeaders) {
    _resetGame();
    _state = _ParserState.bom;
  }
  List<String> _lineBuf = <String>[];
  late bool _found;
  late _ParserState _state = _ParserState.pre;
  late PgnHeaders _gameHeaders;
  late List<String> _gameComments;
  late PgnNode<PgnNodeData> _gameMoves;
  late List<_ParserFrame> _stack;
  late List<String> _commentBuf;


  final void Function(PgnGame<PgnNodeData>) emitGame;


  final PgnHeaders Function() initHeaders;

  void _resetGame() {
    _found = false;
    _state = _ParserState.pre;
    _gameHeaders = initHeaders();
    _gameMoves = PgnNode<PgnNodeData>();
    _gameComments = <String>[];
    _commentBuf = <String>[];
    _stack = <_ParserFrame>[_ParserFrame(parent: _gameMoves, root: true)];
  }

  void _emit() {
    if (_state == _ParserState.comment) {
      _handleComment();
    }
    if (_found) {
      emitGame(
        PgnGame<PgnNodeData>(
            headers: _gameHeaders, moves: _gameMoves, comments: _gameComments),
      );
    }
    _resetGame();
  }


  void parse(String data) {
    int idx = 0;
    for (;;) {
      final int nlIdx = data.indexOf('\n', idx);
      if (nlIdx == -1) {
        break;
      }
      final int crIdx =
          nlIdx > idx && data[nlIdx - 1] == '\r' ? nlIdx - 1 : nlIdx;
      _lineBuf.add(data.substring(idx, crIdx));
      idx = nlIdx + 1;
      _handleLine();
    }
    _lineBuf.add(data.substring(idx));

    _handleLine();
    _emit();
  }

  void _handleLine() {
    bool freshLine = true;
    String line = _lineBuf.join();
    _lineBuf = <String>[];
    continuedLine:
    for (;;) {
      switch (_state) {
        case _ParserState.bom:
          {
            if (line.startsWith(_bom)) {
              line = line.substring(_bom.length);
            }
            _state = _ParserState.pre;
            continue;
          }

        case _ParserState.pre:
          {
            if (_isWhitespace(line) || _isCommentLine(line)) {
              return;
            }
            _found = true;
            _state = _ParserState.headers;
            continue;
          }

        case _ParserState.headers:
          {
            if (_isCommentLine(line)) {
              return;
            }
            bool moreHeaders = true;
            final RegExp headerReg = RegExp(
                r'^\s*\[([A-Za-z0-9][A-Za-z0-9_+#=:-]*)\s+"((?:[^"\\]|\\"|\\\\)*)"\]');
            while (moreHeaders) {
              moreHeaders = false;
              line = line.replaceFirstMapped(headerReg, (Match match) {
                if (match[1] != null && match[2] != null) {
                  _gameHeaders[match[1]!] =
                      match[2]!.replaceAll(r'\"', '"').replaceAll(r'\\', r'\');
                  moreHeaders = true;
                  freshLine = false;
                }
                return '';
              });
            }
            if (_isWhitespace(line)) {
              return;
            }
            _state = _ParserState.moves;
            continue;
          }

        case _ParserState.moves:
          {
            if (freshLine) {
              if (_isWhitespace(line) || _isCommentLine(line)) {
                return;
              }
            }

            final RegExp tokenRegex = RegExp(
                r'(?:p|(?:[a-g][1-7](?:[-x][a-g][1-7])*)|(?:x[a-g][1-7](?:[-x][a-g][1-7])*))'
                r'|{|;|\$\d{1,4}|[?!]{1,2}|\(|\)|\*|1-0|0-1|1\/2-1\/2');
            final Iterable<RegExpMatch> matches = tokenRegex.allMatches(line);
            for (final RegExpMatch match in matches) {
              final _ParserFrame frame = _stack[_stack.length - 1];
              final String? token = match[0];
              if (token != null) {
                if (token == ';') {

                  return;
                } else if (token.startsWith(r'$')) {
                  _handleNag(int.parse(token.substring(1)));
                } else if (token == '!') {
                  _handleNag(1);
                } else if (token == '?') {
                  _handleNag(2);
                } else if (token == '!!') {
                  _handleNag(3);
                } else if (token == '??') {
                  _handleNag(4);
                } else if (token == '!?') {
                  _handleNag(5);
                } else if (token == '?!') {
                  _handleNag(6);
                } else if (token == '1-0' ||
                    token == '0-1' ||
                    token == '1/2-1/2' ||
                    token == '*') {
                  if (_stack.length == 1 && token != '*') {
                    _gameHeaders['Result'] = token;
                  }
                } else if (token == '(') {
                  _stack.add(_ParserFrame(parent: frame.parent, root: false));
                } else if (token == ')') {
                  if (_stack.length > 1) {
                    _stack.removeLast();
                  }
                } else if (token == '{') {
                  final int openIndex = match.end;
                  _state = _ParserState.comment;
                  if (openIndex < line.length) {
                    final int beginIndex =
                        line[openIndex] == ' ' ? openIndex + 1 : openIndex;
                    line = line.substring(beginIndex);
                  } else if (openIndex == line.length) {
                    return;
                  }
                  continue continuedLine;
                } else {

                  if (frame.node != null) {

                    frame.parent = frame.node!;
                  }
                  frame.node = PgnNode<PgnNodeData>(PgnNodeData(
                      san: token, startingComments: frame.startingComments));
                  frame.startingComments = null;
                  frame.root = false;
                  frame.parent.children.add(frame.node!);
                }
              }
            }
            return;
          }

        case _ParserState.comment:
          {
            final int closeIndex = line.indexOf('}');
            if (closeIndex == -1) {
              _commentBuf.add(line);
              return;
            } else {
              final int endIndex = closeIndex > 0 && line[closeIndex - 1] == ' '
                  ? closeIndex - 1
                  : closeIndex;
              _commentBuf.add(line.substring(0, endIndex));
              _handleComment();
              line = line.substring(closeIndex);
              _state = _ParserState.moves;
              freshLine = false;
            }
          }
      }
    }
  }

  void _handleNag(int nag) {
    final _ParserFrame frame = _stack[_stack.length - 1];
    if (frame.node != null && frame.node!.data != null) {
      frame.node!.data!.nags ??= <int>[];
      frame.node!.data!.nags?.add(nag);
    }
  }

  void _handleComment() {
    final _ParserFrame frame = _stack[_stack.length - 1];
    final String comment = _commentBuf.join('\n');
    _commentBuf = <String>[];
    if (frame.node != null && frame.node!.data != null) {
      frame.node!.data!.comments ??= <String>[];
      frame.node!.data!.comments?.add(comment);
    } else if (frame.root) {
      _gameComments.add(comment);
    } else {
      frame.startingComments ??= <String>[];
      frame.startingComments!.add(comment);
    }
  }
}


String _makeClk(Duration duration) {
  final double seconds = duration.inMilliseconds / 1000;
  final num positiveSecs = math.max(0, seconds);
  final int hours = (positiveSecs / 3600).floor();
  final int minutes = ((positiveSecs % 3600) / 60).floor();
  final num maxSec = (positiveSecs % 3600) % 60;
  final int intVal = maxSec.toInt();
  final String frac = (maxSec - intVal)
      .toStringAsFixed(3)
      .replaceAll(RegExp(r'\.?0+$'), '')
      .substring(1);
  final String dec = intVal.toString().padLeft(2, '0');
  return '$hours:${minutes.toString().padLeft(2, "0")}:$dec$frac';
}
