




part of '../mill.dart';











class GameController {
  factory GameController() => instance;

  GameController._() {
    _init(GameMode.humanVsAi);
  }

  static const String _logTag = "[Controller]";

  NetworkService? networkService;
  bool isLanOpponentTurn = false;

  bool isDisposed = false;
  bool isControllerReady = false;
  bool isControllerActive = false;
  bool isEngineRunning = false;
  bool isEngineInDelay = false;
  bool isPositionSetupMarkedPiece =
      false;

  bool lastMoveFromAI = false;

  bool disableStats = false;

  String? value;
  AiMoveType? aiMoveType;

  late Game gameInstance;
  late Position position;
  late Position setupPosition;
  late Engine engine;


  bool? lanHostPlaysWhite;


  Completer<bool>? pendingTakeBackCompleter;


  DateTime? _gameStartTime;
  bool _gameStartTimeRecorded = false;

  final HeaderTipNotifier headerTipNotifier = HeaderTipNotifier();
  final HeaderIconsNotifier headerIconsNotifier = HeaderIconsNotifier();
  final SetupPositionNotifier setupPositionNotifier = SetupPositionNotifier();
  final GameResultNotifier gameResultNotifier = GameResultNotifier();
  final BoardSemanticsNotifier boardSemanticsNotifier =
      BoardSemanticsNotifier();

  late GameRecorder gameRecorder;
  GameRecorder? newGameRecorder;


  bool isAnnotationMode = false;

  final AnnotationManager annotationManager = AnnotationManager();

  String? _initialSharingMoveList;
  ValueNotifier<String?> initialSharingMoveListNotifier =
      ValueNotifier<String?>(null);

  String? get initialSharingMoveList => _initialSharingMoveList;

  set initialSharingMoveList(String? list) {
    _initialSharingMoveList = list;
    initialSharingMoveListNotifier.value = list;
  }

  String? loadedGameFilenamePrefix;

  late AnimationManager animationManager;

  bool _isInitialized = false;

  bool get initialized => _isInitialized;

  bool get isPositionSetup => gameRecorder.setupPosition != null;

  void clearPositionSetupFlag() => gameRecorder.setupPosition = null;

  @visibleForTesting
  static GameController instance = GameController._();


  Future<void> startController() async {
    if (_isInitialized) {
      return;
    }

    await SoundManager().loadSounds();

    _isInitialized = true;
    logger.i("$_logTag initialized");
  }


  PieceColor getLocalColor() {
    final bool amIHost = networkService?.isHost ?? false;
    final bool hostPlaysWhite = lanHostPlaysWhite ?? true;
    if (amIHost) {

      return hostPlaysWhite ? PieceColor.white : PieceColor.black;
    } else {

      return hostPlaysWhite ? PieceColor.black : PieceColor.white;
    }
  }



  void requestRestart() {

    if (gameInstance.gameMode == GameMode.humanVsLAN &&
        (networkService?.isConnected ?? false)) {

      networkService!.sendMove("restart:request");

    } else {

      reset();
    }
  }




  void handleRestartRequest() {

    final BuildContext? context = rootScaffoldMessengerKey.currentContext;
    if (context == null) {
      return;
    }
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Restart Request"),
          content: Text(
              S.of(dialogContext).opponentRequestedToRestartTheGameDoYouAccept),
          actions: <Widget>[
            TextButton(

              onPressed: () {
                Navigator.of(dialogContext).pop(true);
                networkService?.sendMove("restart:accepted");

                reset(lanRestart: true);
              },
              child: const Text("Yes"),
            ),
            TextButton(

              onPressed: () {
                Navigator.of(dialogContext).pop(false);
                networkService?.sendMove("restart:rejected");
                headerTipNotifier
                    .showTip("S.of(context).restartRequestRejected");
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }



  void requestResignation() {
    if (gameInstance.gameMode != GameMode.humanVsLAN ||
        !(networkService?.isConnected ?? false)) {

      logger.i("$_logTag Local resignation in non-LAN mode");
      _handleLocalResignation();
      return;
    }


    final BuildContext? context = rootScaffoldMessengerKey.currentContext;
    if (context == null) {
      return;
    }

    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(S.of(context).confirmResignation),
          content:
              const Text("S.of(context).areYouSureYouWantToResignThisGame"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(S.of(context).cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);


                try {
                  networkService!.sendMove("resign:request");
                  logger.i("$_logTag Sent resignation request");


                  final PieceColor localColor = getLocalColor();
                  final PieceColor winnerColor = localColor.opponent;


                  position.setGameOver(
                    winnerColor,
                    GameOverReason.loseResign, // Using a generic reason
                  );


                  headerTipNotifier
                      .showTip("S.of(context).youResignedGameOver");
                  gameResultNotifier.showResult(force: true);


                  SoundManager().playTone(Sound.lose);
                } catch (e) {
                  logger.e("$_logTag Failed to send resignation: $e");
                  headerTipNotifier.showTip("Failed to send resignation: $e");
                }
              },
              child: const Text("Resign"),
            ),
          ],
        );
      },
    );
  }



  void handleResignation() {
    if (gameInstance.gameMode != GameMode.humanVsLAN) {
      logger.w("$_logTag Ignoring resignation request: not in LAN mode");
      return;
    }

    try {

      final PieceColor localColor = getLocalColor();


      position.setGameOver(
        localColor,
        GameOverReason.loseResign, // Using a generic reason for now
      );


      final BuildContext? context = rootScaffoldMessengerKey.currentContext;
      if (context != null) {
        headerTipNotifier.showTip(S.of(context).opponentResignedYouWin);
      } else {
        headerTipNotifier.showTip("Opponent resigned, you win");
      }
      gameResultNotifier.showResult(force: true);
      isLanOpponentTurn = false;


      SoundManager().playTone(Sound.win);

      logger.i("$_logTag Handled opponent resignation");
    } catch (e) {
      logger.e("$_logTag Error handling resignation: $e");
      headerTipNotifier.showTip("Error handling opponent resignation");
    }
  }


  void _handleLocalResignation() {

    final PieceColor winnerColor = position.sideToMove.opponent;


    position.setGameOver(
      winnerColor,
      GameOverReason.drawStalemateCondition, // Using a generic reason
    );


    final BuildContext? context = rootScaffoldMessengerKey.currentContext;
    final String youResignedGameOver = context != null
        ? S.of(context).youResignedGameOver
        : "You resigned, game over";
    headerTipNotifier.showTip(youResignedGameOver);
    gameResultNotifier.showResult(force: true);


    SoundManager().playTone(Sound.win);

    logger.i("$_logTag Local player resigned. Winner: $winnerColor");
  }


  void reset({bool force = false, bool lanRestart = false}) {
    final GameMode gameModeBak = gameInstance.gameMode;
    String? fen = "";
    final bool isPosSetup = isPositionSetup;
    final bool? savedHostPlaysWhite = lanHostPlaysWhite;

    value = "0";
    aiMoveType = AiMoveType.unknown;
    engine.stopSearching();
    AnalysisMode.disable();

    if (gameModeBak == GameMode.humanVsAi) {
      GameController().disableStats = false;
    } else if (gameModeBak == GameMode.humanVsHuman) {
      GameController().disableStats = true;
    }


    PlayerTimer().reset();


    _resetGameTiming();

    if (gameModeBak == GameMode.humanVsLAN) {


      if (force || !(networkService?.isConnected ?? false)) {
        networkService?.dispose();
        networkService = null;
        isLanOpponentTurn = false;
      } else if (!lanRestart) {

        networkService?.dispose();
        networkService = null;
        isLanOpponentTurn = false;
      }

    } else {
      networkService?.dispose();
      networkService = null;
      if (!force) {
        isLanOpponentTurn = false;
      }
    }

    if (isPosSetup && !force) {
      fen = gameRecorder.setupPosition;
    }


    _init(gameModeBak);

    lanHostPlaysWhite = savedHostPlaysWhite;


    if (gameModeBak == GameMode.humanVsLAN) {
      position.sideToMove = PieceColor.white;
      final PieceColor localColor = getLocalColor();
      isLanOpponentTurn = (position.sideToMove != localColor);
    }

    if (isPosSetup && !force && fen != null) {
      gameRecorder.setupPosition = fen;
      gameRecorder.lastPositionWithRemove = fen;
      position.setFen(fen);
    }

    gameInstance.gameMode = gameModeBak;
    GifShare().captureView(first: true);



  }




  void _startGame() {

  }

  void _init(GameMode mode) {
    position = Position();
    position.reset();
    gameInstance = Game(gameMode: mode);
    engine = Engine();
    gameRecorder = GameRecorder(lastPositionWithRemove: position.fen);

    _startGame();


    PlayerTimer().reset();
  }








  void startLanGame({
    bool isHost = true,
    String? hostAddress,
    int port = 33333,
    bool hostPlaysWhite = true, // Explicitly enforce Host as White
    void Function(String, int)? onClientConnected,
  }) {
    gameInstance.gameMode = GameMode.humanVsLAN;
    lanHostPlaysWhite = hostPlaysWhite;

    headerIconsNotifier.showIcons();

    if (networkService == null || !networkService!.isConnected) {
      networkService?.dispose();
      networkService = NetworkService();
    }

    final BuildContext? currentContext =
        rootScaffoldMessengerKey.currentContext;

    final String connectedWaitingForOpponentSMove = currentContext != null
        ? S.of(currentContext).connectedWaitingForOpponentSMove
        : "Connected, waiting for opponent's move";

    try {
      if (isHost) {
        position.sideToMove = PieceColor.white;
        DB().generalSettings =
            DB().generalSettings.copyWith(aiMovesFirst: false);
        final PieceColor localColor = getLocalColor();
        isLanOpponentTurn =
            (position.sideToMove != localColor);

        networkService!.startHost(port,
            onClientConnected: (String clientIp, int clientPort) {
          logger.i(
              "$_logTag onClientConnected => IP:$clientIp, port:$clientPort");
          headerTipNotifier.showTip("Client connected at $clientIp:$clientPort",
              snackBar: false);

          isLanOpponentTurn = false;
          headerIconsNotifier.showIcons();
          onClientConnected?.call(clientIp, clientPort);
        });
      } else if (hostAddress != null) {
        position.sideToMove = PieceColor.white;
        DB().generalSettings =
            DB().generalSettings.copyWith(aiMovesFirst: true);
        networkService!.connectToHost(hostAddress, port).then((_) {
          final PieceColor localColor = getLocalColor();
          isLanOpponentTurn = (position.sideToMove != localColor);

          headerTipNotifier.showTip(connectedWaitingForOpponentSMove,
              snackBar: false);
          onClientConnected?.call(hostAddress, port);
        });
      } else {
        logger.e("$_logTag Host address required when not hosting");
        headerTipNotifier.showTip("Error: Host address required");
        return;
      }

      boardSemanticsNotifier.updateSemantics();
    } catch (e) {
      logger.e("$_logTag LAN game setup failed: $e");
      headerTipNotifier.showTip("Failed to start LAN game: $e");
      resetLanState();
    }
  }


  void resetLanState() {
    if (gameInstance.gameMode == GameMode.humanVsLAN) {
      if (networkService?.isConnected != true) {
        networkService?.dispose();
        networkService = null;
      }
      isLanOpponentTurn = false;
      position.sideToMove = PieceColor.white;
      headerIconsNotifier.showIcons();
      boardSemanticsNotifier.updateSemantics();
    }
  }


  void handleLanMove(String moveNotation) {
    if (gameInstance.gameMode != GameMode.humanVsLAN) {
      logger.w("$_logTag Ignoring LAN move: wrong mode");
      return;
    }

    try {
      if (moveNotation.startsWith("request:aiMovesFirst")) {

        final bool aiMovesFirst = DB().generalSettings.aiMovesFirst;
        networkService?.sendMove("response:aiMovesFirst:$aiMovesFirst");
        logger.i("$_logTag Sent aiMovesFirst: $aiMovesFirst to Client");
        return;
      }

      final ExtMove move = ExtMove(
        moveNotation,
        side: position.sideToMove.opponent,
      );

      if (gameInstance.doMove(move)) {

        final PieceColor localColor = getLocalColor();
        isLanOpponentTurn = (position.sideToMove != localColor);
        boardSemanticsNotifier.updateSemantics();

        final BuildContext? context = rootScaffoldMessengerKey.currentContext;
        final String ot =
            context != null ? S.of(context).opponentSTurn : "Opponent's turn";
        final String yt =
            context != null ? S.of(context).yourTurn : "Your turn";
        headerTipNotifier.showTip(
          isLanOpponentTurn ? ot : yt,
          snackBar: false,
        );
        logger.i("$_logTag Successfully processed LAN move: $moveNotation");

        gameRecorder.appendMoveIfDifferent(move);
        if (position.phase == Phase.gameOver) {
          gameResultNotifier.showResult(force: true);
        }
      } else {
        logger.e("$_logTag Invalid move received from LAN: $moveNotation");
        headerTipNotifier.showTip("Opponent sent an invalid move");
      }
    } catch (e) {
      logger.e("$_logTag Error processing LAN move: $e");
      headerTipNotifier.showTip("Error with opponent's move: $e");
    }
  }


  void sendLanMove(String moveNotation) {
    if (gameInstance.gameMode != GameMode.humanVsLAN || isLanOpponentTurn) {
      logger.w("$_logTag Cannot send move: not your turn or wrong mode");
      return;
    }

    try {
      networkService?.sendMove(moveNotation);

      final PieceColor localColor = getLocalColor();
      isLanOpponentTurn = (position.sideToMove != localColor);
      logger.i("$_logTag Sent move to LAN opponent: $moveNotation");
      final BuildContext? context = rootScaffoldMessengerKey.currentContext;
      final String ot =
          context != null ? S.of(context).opponentSTurn : "Opponent's turn";
      final String yt = context != null ? S.of(context).yourTurn : "Your turn";
      headerTipNotifier.showTip(
        isLanOpponentTurn ? ot : yt,
        snackBar: false,
      );
    } catch (e) {
      logger.e("$_logTag Failed to send move: $e");
      headerTipNotifier.showTip("Failed to send move: $e");
    }
  }


  Future<bool> requestLanTakeBack(int steps) async {
    if (gameInstance.gameMode != GameMode.humanVsLAN) {
      return false;
    }
    if (steps != 1) {

      return false;
    }


    if (networkService == null || !networkService!.isConnected) {
      final BuildContext? context = rootScaffoldMessengerKey.currentContext;
      final String notConnectedToLanOpponent = context != null
          ? S.of(context).notConnectedToLanOpponent
          : "You resigned, game over";
      headerTipNotifier.showTip(notConnectedToLanOpponent);
      return false;
    }
    if (isLanOpponentTurn) {
      final BuildContext? context = rootScaffoldMessengerKey.currentContext;
      final String cannotRequestATakeBackWhenItSNotYourTurn = context != null
          ? S.of(context).cannotRequestATakeBackWhenItSNotYourTurn
          : "Cannot request a take back when it's not your turn";
      headerTipNotifier.showTip(cannotRequestATakeBackWhenItSNotYourTurn);
      return false;
    }




    pendingTakeBackCompleter = Completer<bool>();

    networkService!.sendMove("take back:$steps:request");

    final BuildContext? context = rootScaffoldMessengerKey.currentContext;
    final String takeBackRequestSentToTheOpponent = context != null
        ? S.of(context).takeBackRequestSentToTheOpponent
        : "Take back request sent to the opponent";
    headerTipNotifier.showTip(takeBackRequestSentToTheOpponent,
        snackBar: false);



    Future<void>.delayed(const Duration(seconds: 30), () {
      if (pendingTakeBackCompleter != null &&
          !pendingTakeBackCompleter!.isCompleted) {
        pendingTakeBackCompleter!.complete(false);
      }
    });


    return pendingTakeBackCompleter!.future;
  }


  void handleTakeBackRequest(int steps) {
    if (steps != 1) {

      networkService?.sendMove("take back:$steps:rejected");
      return;
    }
    final BuildContext? context = rootScaffoldMessengerKey.currentContext;
    if (context == null) {

      networkService?.sendMove("take back:$steps:rejected");
      return;
    }
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(S.of(dialogContext).takeBackRequest),
          content:
              Text("Opponent requests to take back $steps move(s). Accept?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
                networkService?.sendMove("take back:$steps:accepted");

                HistoryNavigator.doEachMove(HistoryNavMode.takeBack, 1);

              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
                networkService?.sendMove("take back:$steps:rejected");
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  bool isAutoRestart() {
    if (EnvironmentConfig.devMode == true) {
      return DB().generalSettings.isAutoRestart && position.isNoDraw() == false;
    }

    return DB().generalSettings.isAutoRestart;
  }



  Future<EngineResponse> engineToGo(
    BuildContext context, {
    required bool isMoveNow,
  }) async {
    const String tag = "[engineToGo]";

    if (gameInstance.gameMode == GameMode.humanVsLAN) {

      return const EngineResponseHumanOK();
    }

    late EngineRet engineRet;

    bool searched = false;
    bool loopIsFirst = true;

    final String aiStr = S.of(context).ai;
    final String thinkingStr = S.of(context).thinking;
    final String humanStr = S.of(context).human;

    final GameMode gameMode = gameInstance.gameMode;
    final bool isGameRunning = position.winner == PieceColor.nobody;


    if (isMoveNow && gameInstance.isHumanToMove) {
      return const EngineResponseSkip();
    }








    if (!isMoveNow && position._checkIfGameIsOver()) {
      return const EngineGameIsOver();
    }

    if (isEngineRunning && !isMoveNow) {

      logger.t("$tag engineToGo() is still running, skip.");
      return const EngineResponseSkip();
    }

    isEngineRunning = true;
    isControllerActive = true;



    if (gameInstance.isAiSideToMove && gameMode == GameMode.humanVsAi) {


      PlayerTimer().start();
    }


    logger.t("$tag engine type is $gameMode");

    if (gameMode == GameMode.humanVsAi &&
        position.phase == Phase.moving &&
        !isMoveNow &&
        DB().ruleSettings.mayFly &&
        DB().generalSettings.remindedOpponentMayFly == false &&
        (position.pieceOnBoardCount[position.sideToMove]! <=
                DB().ruleSettings.flyPieceCount &&
            position.pieceOnBoardCount[position.sideToMove]! >= 3)) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        CustomSnackBar(S.of(context).enteredFlyingPhase,
            duration: const Duration(seconds: 8)),
      );
      DB().generalSettings = DB().generalSettings.copyWith(
            remindedOpponentMayFly: true,
          );
    }

    while (
        (gameInstance.isAiSideToMove && (isGameRunning || isAutoRestart())) &&
            isControllerActive) {
      if (gameMode == GameMode.aiVsAi) {
        headerTipNotifier.showTip(position.scoreString, snackBar: false);
      } else {
        headerTipNotifier.showTip(thinkingStr, snackBar: false);
        showSnakeBarHumanNotation(humanStr);
      }

      headerIconsNotifier.showIcons();
      boardSemanticsNotifier.updateSemantics();

      try {
        logger.t("$tag Searching..., isMoveNow: $isMoveNow");

        if (position.pieceOnBoardCount[PieceColor.black]! > 0) {
          isEngineInDelay = true;
          await Future<void>.delayed(Duration(
            milliseconds:
                (DB().displaySettings.animationDuration * 1000).toInt(),
          ));
          isEngineInDelay = false;
        }

        engineRet = await engine.search(moveNow: loopIsFirst && isMoveNow);

        if (!isControllerActive) {
          break;
        }


        if (!gameInstance.doMove(engineRet.extMove!)) {

          isEngineRunning = false;
          return const EngineNoBestMove();
        }

        loopIsFirst = false;
        searched = true;


        _recordGameStartTime();


        if (DB().generalSettings.screenReaderSupport) {
          rootScaffoldMessengerKey.currentState!.showSnackBar(
              CustomSnackBar("$aiStr: ${engineRet.extMove!.notation}"));
        }
      } on EngineTimeOut {
        logger.i("$tag Engine response type: timeout");
        isEngineRunning = false;
        return const EngineTimeOut();
      } on EngineNoBestMove {
        logger.i("$tag Engine response type: nobestmove");
        isEngineRunning = false;
        return const EngineNoBestMove();
      }

      value = engineRet.value;
      aiMoveType = engineRet.aiMoveType;

      if (value != null && aiMoveType != AiMoveType.unknown) {
        lastMoveFromAI = true;
      }

      if (position.winner != PieceColor.nobody) {
        if (isAutoRestart()) {
          reset();
        } else {
          isEngineRunning = false;
          if (gameMode == GameMode.aiVsAi) {
            headerTipNotifier.showTip(position.scoreString, snackBar: false);
            headerIconsNotifier.showIcons();
            boardSemanticsNotifier.updateSemantics();
          }

          gameResultNotifier.showResult(force: true);
          return const EngineResponseOK();
        }
      }
    }

    isEngineRunning = false;


    boardSemanticsNotifier.updateSemantics();


    if (gameInstance.gameMode == GameMode.humanVsAi) {
      PlayerTimer().start();
    }

    return searched ? const EngineResponseOK() : const EngineResponseHumanOK();
  }

  Future<void> moveNow(BuildContext context) async {
    const String tag = "[engineToGo]";
    bool reversed = false;

    loadedGameFilenamePrefix = null;

    if (isEngineInDelay) {
      return rootScaffoldMessengerKey.currentState!
          .showSnackBarClear(S.of(context).aiIsDelaying);
    }

    if (AnalysisMode.isEnabled || AnalysisMode.isAnalyzing) {
      return rootScaffoldMessengerKey.currentState!
          .showSnackBarClear(S.of(context).analyzing);
    }


    if (position.sideToMove != PieceColor.white &&
        position.sideToMove != PieceColor.black) {
      return rootScaffoldMessengerKey.currentState!
          .showSnackBarClear(S.of(context).notAIsTurn);
    }

    if (gameInstance.isHumanToMove) {
      logger.i("$tag Human to Move. Temporarily swap AI and Human roles.");


      gameInstance.reverseWhoIsAi();
      reversed = true;
    }

    final String strTimeout = S.of(context).timeout;
    final String strNoBestMoveErr = S.of(context).error(S.of(context).noMove);

    GameController().disableStats = true;

    switch (await engineToGo(context, isMoveNow: isEngineRunning)) {
      case EngineResponseOK():
      case EngineGameIsOver():
        gameResultNotifier.showResult(force: true);
        break;
      case EngineResponseHumanOK():
        gameResultNotifier.showResult();
        break;
      case EngineTimeOut():
        headerTipNotifier.showTip(strTimeout);
        break;
      case EngineNoBestMove():
        headerTipNotifier.showTip(strNoBestMoveErr);
        break;
      case EngineResponseSkip():
        headerTipNotifier.showTip("Error: Skip");
        break;
      default:
        logger.e("$tag Unknown engine response type.");
        break;
    }

    if (reversed) {
      gameInstance.reverseWhoIsAi();
    }
  }

  void showSnakeBarHumanNotation(String humanStr) {
    final List<ExtMove> moves = gameRecorder.mainlineMoves;
    final ExtMove? lastMove = moves.isNotEmpty ? moves.last : null;
    final String? n = lastMove?.notation;

    if (DB().generalSettings.screenReaderSupport &&
        position.action != Act.remove &&
        n != null) {
      rootScaffoldMessengerKey.currentState!
          .showSnackBar(CustomSnackBar("$humanStr: $n"));
    }
  }

  Future<void> gifShare(BuildContext context) async {
    headerTipNotifier.showTip(S.of(context).pleaseWait);
    final String done = S.of(context).done;
    await GifShare().captureView();
    headerTipNotifier.showTip(done);

    GifShare().shareGif();
  }


  static Future<String?> save(BuildContext context,
      {bool shouldPop = true}) async {
    return LoadService.saveGame(context, shouldPop: shouldPop);
  }


  static Future<void> load(BuildContext context,
      {bool shouldPop = true}) async {
    return LoadService.loadGame(context, null,
        isRunning: true, shouldPop: shouldPop);
  }


  static Future<void> import(BuildContext context,
      {bool shouldPop = true}) async {
    return ImportService.importGame(context, shouldPop: shouldPop);
  }


  static Future<void> export(BuildContext context,
      {bool shouldPop = true}) async {
    return ExportService.exportGame(context, shouldPop: shouldPop);
  }


  Future<void> runAnalysis() async {

    AnalysisMode.setAnalyzing(true);

    final PositionAnalysisResult result = await engine.analyzePosition();


    AnalysisMode.setAnalyzing(false);

    if (result.isValid && result.possibleMoves.isNotEmpty) {

      AnalysisMode.enable(result.possibleMoves);


      boardSemanticsNotifier.updateSemantics();


      headerTipNotifier
          .showTip("Analysis complete. Green = win, Yellow = draw, Red = loss");
    } else {

      final String errorMsg = result.errorMessage ?? "Analysis failed";
      headerTipNotifier.showTip(errorMsg);
    }
  }


  void _recordGameStartTime() {
    if (gameInstance.gameMode == GameMode.aiVsAi && !_gameStartTimeRecorded) {
      _gameStartTime = DateTime.now();
      _gameStartTimeRecorded = true;
      logger.i("$_logTag AI vs AI game start time recorded: $_gameStartTime");
    }
  }


  int calculateGameDurationSeconds() {
    if (_gameStartTime == null) {
      return 0;
    }
    final DateTime endTime = DateTime.now();
    final Duration gameDuration = endTime.difference(_gameStartTime!);
    return gameDuration.inSeconds;
  }


  void _resetGameTiming() {
    _gameStartTime = null;
    _gameStartTimeRecorded = false;
  }
}
