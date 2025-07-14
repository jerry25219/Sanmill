




part of '../mill.dart';

class ImportService {
  const ImportService._();

  static const String _logTag = "[Importer]";


  static Future<void> importGame(BuildContext context,
      {bool shouldPop = true}) async {

    rootScaffoldMessengerKey.currentState?.clearSnackBars();


    final S s = S.of(context);
    final NavigatorState navigator = Navigator.of(context);


    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);


    if (!context.mounted) {
      return;
    }


    if (data == null) {
      rootScaffoldMessengerKey.currentState
          ?.showSnackBarClear(s.cannotImport("null"));
      GameController().headerTipNotifier.showTip(s.cannotImport("null"));

      if (shouldPop) {
        navigator.pop();
      }
      return;
    }

    final String? text = data.text;


    if (text == null) {
      rootScaffoldMessengerKey.currentState
          ?.showSnackBarClear(s.cannotImport("null"));
      GameController().headerTipNotifier.showTip(s.cannotImport("null"));

      if (shouldPop) {
        navigator.pop();
      }
      return;
    }


    try {
      import(text);
    } catch (exception) {
      if (!context.mounted) {
        return;
      }

      final String tip = s.cannotImport(exception.toString());
      rootScaffoldMessengerKey.currentState?.showSnackBarClear(tip);
      GameController().headerTipNotifier.showTip(tip);

      if (shouldPop) {
        navigator.pop();
      }
      return;
    }


    if (!context.mounted) {
      return;
    }


    await HistoryNavigator.takeBackAll(context, pop: false);

    if (!context.mounted) {
      return;
    }

    final HistoryResponse? historyResult =
        await HistoryNavigator.stepForwardAll(context, pop: false);

    if (!context.mounted) {
      return;
    }

    if (historyResult == const HistoryOK()) {
      rootScaffoldMessengerKey.currentState?.showSnackBarClear(s.gameImported);
      GameController().headerTipNotifier.showTip(s.gameImported);
    } else {
      final String tip = s.cannotImport(HistoryNavigator.importFailedStr);
      rootScaffoldMessengerKey.currentState?.showSnackBarClear(tip);
      GameController().headerTipNotifier.showTip(tip);

      HistoryNavigator.importFailedStr = "";
    }

    if (shouldPop) {
      navigator.pop();
    }
  }

  static String addTagPairs(String moveList) {
    final DateTime dateTime = DateTime.now();
    final String date = "${dateTime.year}.${dateTime.month}.${dateTime.day}";

    final int total = Position.score[PieceColor.white]! +
        Position.score[PieceColor.black]! +
        Position.score[PieceColor.draw]!;

    final Game gameInstance = GameController().gameInstance;
    final Player whitePlayer = gameInstance.getPlayerByColor(PieceColor.white);
    final Player blackPlayer = gameInstance.getPlayerByColor(PieceColor.black);

    String white;
    String black;
    String result;

    if (whitePlayer.isAi) {
      white = "AI";
    } else {
      white = "Human";
    }

    if (blackPlayer.isAi) {
      black = "AI";
    } else {
      black = "Human";
    }

    switch (GameController().position.winner) {
      case PieceColor.white:
        result = "1-0";
        break;
      case PieceColor.black:
        result = "0-1";
        break;
      case PieceColor.draw:
        result = "1/2-1/2";
        break;
      case PieceColor.marked:
      case PieceColor.none:
      case PieceColor.nobody:
        result = "*";
        break;
    }

    String variantTag;
    if (DB().ruleSettings.isLikelyNineMensMorris()) {
      variantTag = '[Variant "Nine Men\'s Morris"]\r\n';
    } else if (DB().ruleSettings.isLikelyTwelveMensMorris()) {
      variantTag = '[Variant "Twelve Men\'s Morris"]\r\n';
    } else if (DB().ruleSettings.isLikelyElFilja()) {
      variantTag = '[Variant "El Filja"]\r\n';
    } else {
      variantTag = '';
    }

    final String plyCountTag =
        '[PlyCount "${GameController().gameRecorder.mainlineMoves.length}"]\r\n';

    String tagPairs = '[Event "Sanmill-Game"]\r\n'
        '[Site "Sanmill"]\r\n'
        '[Date "$date"]\r\n'
        '[Round "$total"]\r\n'
        '[White "$white"]\r\n'
        '[Black "$black"]\r\n'
        '[Result "$result"]\r\n'
        '$variantTag'
        '$plyCountTag';


    if (!(moveList.length > 3 && moveList.startsWith("[FEN"))) {
      tagPairs = "$tagPairs\r\n";
    }

    return tagPairs + moveList;
  }

  static void import(String moveList) {
    moveList = moveList.trim();
    String ml = moveList;

    logger.t("Clipboard text: $moveList");


    if (moveList.isEmpty) {
      throw const ImportFormatException("Clipboard content is empty");
    }

    try {

      if (isPlayOkMoveList(ml)) {
        _importPlayOk(ml);
        return;
      }

      if (isPureFen(ml)) {
        ml = '[FEN "$ml"]\r\n[SetUp "1"]';
      }

      if (isGoldTokenMoveList(ml)) {
        int start = ml.indexOf("1\t");

        if (start == -1) {
          start = ml.indexOf("1 ");
        }

        if (start == -1) {
          start = 0;
        }

        ml = ml.substring(start);


        final int quickJumpIndex = ml.indexOf("Quick Jump");
        if (quickJumpIndex != -1) {
          ml = ml.substring(0, quickJumpIndex).trim();
        }
      }

      final Map<String, String> replacements = <String, String>{
        "\n": " ",
        "()": " ",
        "white": " ",
        "black": " ",
        "win": " ",
        "lose": " ",
        "draw": " ",
        "resign": " ",
        "-/x": "x",
        "/x": "x",
        ".a": ". a",
        ".b": ". b",
        ".c": ". c",
        ".d": ". d",
        ".e": ". e",
        ".f": ". f",
        ".g": ". g",

        "\t": " ",
        "Place to ": "",
        ", take ": "x",
        " -> ": "-"
      };

      ml = processOutsideBrackets(ml, replacements);
      _importPgn(ml);
    } catch (e) {

      logger.e("$_logTag Import failed: $e");


      logger.e("$_logTag Original move list to import:\n$moveList");
      logger.e("$_logTag Processed move list:\n$ml");


      rethrow;
    }
  }

  static void _importPlayOk(String moveList) {
    String cleanUpPlayOkMoveList(String moveList) {
      moveList = removeTagPairs(moveList);
      final String ret = moveList
          .replaceAll("\n", " ")
          .replaceAll(" 1/2-1/2", "")
          .replaceAll(" 1-0", "")
          .replaceAll(" 0-1", "")
          .replaceAll("TXT", "");
      return ret;
    }

    final Position localPos = Position();
    localPos.reset();

    final GameRecorder newHistory =
        GameRecorder(lastPositionWithRemove: GameController().position.fen);

    final List<String> list = cleanUpPlayOkMoveList(moveList).split(" ");


    bool hasValidMoves = false;

    for (String token in list) {
      token = token.trim();
      if (token.isEmpty ||
          token.endsWith(".") ||
          token.startsWith("[") ||
          token.endsWith("]")) {
        continue;
      }


      if (token.startsWith("x")) {
        final String move = _playOkNotationToMoveString(token);
        newHistory.appendMove(ExtMove(move, side: localPos.sideToMove));
        final bool ok = localPos.doMove(move);
        if (!ok) {
          throw ImportFormatException(" $token → $move");
        }
      }

      else if (!token.contains("x")) {
        final String move = _playOkNotationToMoveString(token);
        newHistory.appendMove(ExtMove(move, side: localPos.sideToMove));
        final bool ok = localPos.doMove(move);
        if (!ok) {
          throw ImportFormatException("$token → $move");
        }
      }

      else {
        final int idx = token.indexOf("x");
        final String preMove = token.substring(0, idx);
        final String captureMove = token.substring(idx);
        final String m1 = _playOkNotationToMoveString(preMove);
        newHistory.appendMove(ExtMove(m1, side: localPos.sideToMove));
        final bool ok1 = localPos.doMove(m1);
        if (!ok1) {
          throw ImportFormatException(" $preMove → $m1");
        }

        final String m2 = _playOkNotationToMoveString(captureMove);
        newHistory.appendMove(ExtMove(m2, side: localPos.sideToMove));
        final bool ok2 = localPos.doMove(m2);
        if (!ok2) {
          throw ImportFormatException(" $captureMove → $m2");
        }
      }
    }

    if (newHistory.mainlineMoves.isNotEmpty) {
      GameController().newGameRecorder = newHistory;
      hasValidMoves = true;
    }


    if (!hasValidMoves) {
      throw const ImportFormatException(
          "Cannot import: No valid moves found in the notation");
    }
  }


  static void fillAllNodesBoardLayout(PgnNode<ExtMove> root,
      {String? setupFen}) {
    final Position pos = Position();


    if (setupFen != null && setupFen.isNotEmpty) {
      pos.setFen(setupFen);
    } else {


      pos.reset();
    }

    void dfs(PgnNode<ExtMove> node, Position currentPos) {

      if (node.data != null) {
        final ExtMove move = node.data!;

        final bool ok = currentPos.doMove(move.move);
        if (!ok) {



          return;
        }

        move.boardLayout = currentPos.generateBoardLayoutAfterThisMove();
      }


      for (final PgnNode<ExtMove> child in node.children) {

        final Position saved = currentPos.clone();

        dfs(child, currentPos);

        currentPos.copyWith(saved);
      }
    }


    dfs(root, pos);
  }



  static void _importPgn(String moveList) {

    final PgnGame<PgnNodeData> game = PgnGame.parsePgn(moveList);


    final bool hasValidMoves = game.moves.mainline().isNotEmpty;
    final bool hasValidFen = game.headers.containsKey('FEN') &&
        game.headers['FEN'] != null &&
        game.headers['FEN']!.isNotEmpty;

    if (!hasValidMoves && !hasValidFen) {
      logger.e(
          "$_logTag Failed to parse PGN: Empty game with no moves and no FEN");
      throw const ImportFormatException("");
    }

    final Position localPos = Position();


    final String? fen = game.headers['FEN'];
    if (fen != null && fen.isNotEmpty) {
      localPos.setFen(fen);
    } else {
      localPos.reset();
    }

    final GameRecorder newHistory = GameRecorder(
      lastPositionWithRemove: fen ?? GameController().position.fen,
      setupPosition: fen,
    );


    if (fen != null && fen.isNotEmpty) {
      GameController().position.setFen(fen);
    }


    List<String> splitSan(String san) {
      san = san.replaceAll(RegExp(r'\{[^}]*\}'), '').trim();

      List<String> segments = <String>[];

      if (san.contains('x')) {
        if (san.startsWith('x')) {

          final RegExp regex = RegExp(r'(x[a-g][1-7])');
          segments = regex
              .allMatches(san)
              .map((RegExpMatch m) => m.group(0)!)
              .toList();
        } else {
          final int firstX = san.indexOf('x');
          if (firstX > 0) {

            final String firstSegment = san.substring(0, firstX);
            segments.add(firstSegment);

            final RegExp regex = RegExp(r'(x[a-g][1-7])');
            final String remainingSan = san.substring(firstX);
            segments.addAll(regex
                .allMatches(remainingSan)
                .map((RegExpMatch m) => m.group(0)!)
                .toList());
          } else {

            final RegExp regex = RegExp(r'(x[a-g][1-7])');
            segments = regex
                .allMatches(san)
                .map((RegExpMatch m) => m.group(0)!)
                .toList();
          }
        }
      } else {

        segments.add(san);
      }

      return segments;
    }


    for (final PgnNodeData node in game.moves.mainline()) {
      final String san = node.san.trim().toLowerCase();
      if (san.isEmpty ||
          san == "*" ||
          san == "x" ||
          san == "xx" ||
          san == "xxx" ||
          san == "p") {

        continue;
      }

      final List<String> segments = splitSan(san);


      for (int i = 0; i < segments.length; i++) {
        final String segment = segments[i];
        if (segment.isEmpty) {
          continue;
        }
        try {
          final String uciMove = _wmdNotationToMoveString(segment);

          final List<int>? nags = (i == segments.length - 1) ? node.nags : null;
          final List<String>? startingComments =
              (i == segments.length - 1) ? node.startingComments : null;
          final List<String>? comments =
              (i == segments.length - 1) ? node.comments : null;

          newHistory.appendMove(ExtMove(
            uciMove,
            side: localPos.sideToMove,
            nags: nags,
            startingComments: startingComments,
            comments: comments,
          ));

          final bool ok = localPos.doMove(uciMove);
          if (!ok) {
            throw ImportFormatException(" $segment → $uciMove");
          }
        } catch (e) {
          logger.e("$_logTag Failed to parse move segment '$segment': $e");
          throw ImportFormatException(" $segment");
        }
      }
    }

    if (newHistory.mainlineMoves.isNotEmpty ||
        (fen != null && fen.isNotEmpty)) {
      fillAllNodesBoardLayout(newHistory.pgnRoot, setupFen: fen);
      GameController().newGameRecorder = newHistory;
    }

    if (fen != null && fen.isNotEmpty) {
      GameController().gameRecorder.setupPosition = fen;
    }
  }
}
