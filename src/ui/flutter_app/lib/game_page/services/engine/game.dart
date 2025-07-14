




part of '../mill.dart';

class Player {
  Player({required this.color, required this.isAi});

  final PieceColor color;
  bool isAi;
}

class Game {
  Game({required GameMode gameMode}) {
    this.gameMode = gameMode;
  }

  static const String _logTag = "[game]";

  bool get isAiSideToMove {
    assert(GameController().position.sideToMove == PieceColor.white ||
        GameController().position.sideToMove == PieceColor.black);
    return getPlayerByColor(GameController().position.sideToMove).isAi;
  }

  bool get isHumanToMove => !isAiSideToMove;

  int? focusIndex;
  int? blurIndex;
  int? removeIndex;

  final List<Player> players = <Player>[
    Player(color: PieceColor.white, isAi: false),
    Player(color: PieceColor.black, isAi: true),
  ];

  Player getPlayerByColor(PieceColor color) {
    if (color == PieceColor.draw) {
      return Player(color: PieceColor.draw, isAi: false);
    } else if (color == PieceColor.marked) {
      return Player(color: PieceColor.marked, isAi: false);
    } else if (color == PieceColor.nobody) {
      return Player(color: PieceColor.nobody, isAi: false);
    } else if (color == PieceColor.none) {
      return Player(color: PieceColor.none, isAi: false);
    }

    return players.firstWhere((Player player) => player.color == color);
  }

  void reverseWhoIsAi() {
    if (GameController().gameInstance.gameMode == GameMode.humanVsAi) {
      for (final Player player in players) {
        player.isAi = !player.isAi;
      }
    } else if (GameController().gameInstance.gameMode ==
        GameMode.humanVsHuman) {
      final bool whiteIsAi = getPlayerByColor(PieceColor.white).isAi;
      final bool blackIsAi = getPlayerByColor(PieceColor.black).isAi;
      if (whiteIsAi == blackIsAi) {
        getPlayerByColor(GameController().position.sideToMove).isAi = true;
      } else {
        for (final Player player in players) {
          player.isAi = false;
        }
      }
    }
  }

  late GameMode _gameMode;

  GameMode get gameMode => _gameMode;

  set gameMode(GameMode type) {
    _gameMode = type;

    logger.i("$_logTag Engine type: $type");

    final Map<PieceColor, bool> whoIsAi = type.whoIsAI;
    for (final Player player in players) {
      player.isAi = whoIsAi[player.color]!;
    }

    logger.i(
      "$_logTag White is AI? ${getPlayerByColor(PieceColor.white).isAi}\n"
      "$_logTag Black is AI? ${getPlayerByColor(PieceColor.black).isAi}\n",
    );
  }

  void _select(int pos) {
    focusIndex = pos;
    blurIndex = null;
  }

  @visibleForTesting
  bool doMove(ExtMove extMove) {
    assert(GameController().position.phase != Phase.ready);

    logger.i("$_logTag doMove: $extMove");


    if (!GameController().position.doMove(extMove.move)) {
      return false;
    }




    final ExtMove? finalMove = GameController().position._record;
    if (finalMove == null) {

      return false;
    }





    if (!GameController().gameRecorder.isAtEnd()) {
      GameController().gameRecorder.branchNewMoveFromActiveNode(finalMove);
    } else {
      GameController().gameRecorder.appendMove(finalMove);
    }


    if (GameController().position.phase != Phase.gameOver) {
      GameController().gameResultNotifier.showResult();
    } else if (gameMode == GameMode.humanVsLAN) {

      if (GameController().networkService!.isConnected) {
        GameController()
            .sendLanMove("gameOver:${GameController().position.winner}");
      }
    }

    GifShare().captureView();


    if (EnvironmentConfig.catcher && !kIsWeb && !Platform.isIOS) {
      final Catcher2Options options = catcher.getCurrentConfig()!;

      options.customParameters["MoveList"] =
          GameController().gameRecorder.moveHistoryText;
    }

    _logStat();
    return true;
  }

  void _logStat() {
    final Position position = GameController().position;
    final int total = Position.score[PieceColor.white]! +
        Position.score[PieceColor.black]! +
        Position.score[PieceColor.draw]!;

    double whiteWinRate = 0;
    double blackWinRate = 0;
    double drawRate = 0;
    if (total != 0) {
      whiteWinRate = Position.score[PieceColor.white]! * 100 / total;
      blackWinRate = Position.score[PieceColor.black]! * 100 / total;
      drawRate = Position.score[PieceColor.draw]! * 100 / total;
    }

    final String scoreInfo = "Score: ${position.scoreString}\ttotal:"
        " $total\n$whiteWinRate% : $blackWinRate% : $drawRate%\n";

    logger.i("$_logTag $scoreInfo");
  }
}
