




part of '../mill.dart';





class HistoryNavigator {
  const HistoryNavigator._();

  static const String _logTag = "[HistoryNavigator]";

  static String importFailedStr = "";
  static bool _isGoingToHistory = false;

  static Future<HistoryResponse?> _gotoHistory(
    BuildContext context,
    HistoryNavMode navMode, {
    bool pop = true,
    bool toolbar = false,
    int? number,
  }) async {

    AnalysisMode.disable();


    GameController().disableStats = true;






    final GameMode currentMode = GameController().gameInstance.gameMode;
    if (currentMode == GameMode.humanVsLAN) {
      if (navMode == HistoryNavMode.takeBack && number == null) {


        final bool success = await _requestLanTakeBack(context, 1);


        if (pop && context.mounted) {
          Navigator.pop(context);
        }
        return success ? const HistoryOK() : const HistoryAbort();
      } else {

        if (context.mounted) {

          final String takeBackRejected = S.of(context).takeBackRejected;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(takeBackRejected),
            ),
          );
        }
        if (pop && context.mounted) {
          Navigator.pop(context);
        }
        return const HistoryAbort();
      }
    }


    assert(navMode != HistoryNavMode.takeBackN || number != null);

    if (pop == true || toolbar == true) {
      GameController().loadedGameFilenamePrefix = null;
    }

    if (GameController().isEngineInDelay) {
      rootScaffoldMessengerKey.currentState!
          .showSnackBarClear(S.of(context).aiIsDelaying);
      if (pop) {
        Navigator.pop(context);
      }
      return const HistoryOK();
    }

    GameController().isControllerActive = false;
    GameController().engine.stopSearching();

    final GameController controller = GameController();


    GameController().headerTipNotifier.showTip(S.of(context).atEnd);
    GameController().headerIconsNotifier.showIcons();
    GameController().boardSemanticsNotifier.updateSemantics();

    if (_isGoingToHistory) {
      logger.i("$_logTag Is going to history, ignore repeated request.");
      if (pop) {
        Navigator.pop(context);
      }
      return const HistoryOK();
    }

    _isGoingToHistory = true;
    SoundManager().mute();

    if (navMode == HistoryNavMode.takeBackAll ||
        navMode == HistoryNavMode.takeBackN ||
        navMode == HistoryNavMode.takeBack) {
      GameController().animationManager.allowAnimations = false;
    }


    final HistoryResponse resp = await doEachMove(navMode, number);

    GameController().animationManager.allowAnimations = true;

    if (!context.mounted) {
      return const HistoryAbort();
    }

    switch (resp) {
      case HistoryOK():
        final ExtMove? lastEffectiveMove =
            controller.gameRecorder.activeNode?.data;
        if (lastEffectiveMove != null) {
          GameController().headerTipNotifier.showTip(
                S.of(context).lastMove(lastEffectiveMove.notation),
              );
          GameController().headerIconsNotifier.showIcons();
          GameController().boardSemanticsNotifier.updateSemantics();
        }
        break;
      case HistoryRange(): // TODO: Impossible resp
        rootScaffoldMessengerKey.currentState!
            .showSnackBarClear(S.of(context).atEnd);
        logger.i(HistoryRange);
        break;
      case HistoryRule():
      default:
        rootScaffoldMessengerKey.currentState!
            .showSnackBarClear(S.of(context).movesAndRulesNotMatch);
        logger.i(HistoryRule);
        break;
    }

    SoundManager().unMute();
    await navMode.gotoHistoryPlaySound();

    _isGoingToHistory = false;

    if (pop) {
      if (!context.mounted) {
        return const HistoryAbort();
      }
      Navigator.pop(context);
    }

    return resp;
  }


  static Future<bool> _requestLanTakeBack(
      BuildContext context, int steps) async {
    if (steps != 1) {
      return false;
    }


    final bool ok = await GameController().requestLanTakeBack(steps);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).takeBackRequestWasRejectedOrFailed),
        ),
      );
    }
    return ok;
  }

  static Future<HistoryResponse?> takeBack(
    BuildContext context, {
    bool pop = true,
    bool toolbar = false,
  }) async {
    return _gotoHistory(context, HistoryNavMode.takeBack,
        pop: pop, toolbar: toolbar);
  }

  static Future<HistoryResponse?> stepForward(
    BuildContext context, {
    bool pop = true,
    bool toolbar = false,
  }) async {
    return _gotoHistory(context, HistoryNavMode.stepForward,
        pop: pop, toolbar: toolbar);
  }

  static Future<HistoryResponse?> takeBackAll(
    BuildContext context, {
    bool pop = true,
    bool toolbar = false,
  }) async {
    return _gotoHistory(context, HistoryNavMode.takeBackAll,
        pop: pop, toolbar: toolbar);
  }

  static Future<HistoryResponse?> stepForwardAll(
    BuildContext context, {
    bool pop = true,
    bool toolbar = false,
  }) async {
    return _gotoHistory(context, HistoryNavMode.stepForwardAll,
        pop: pop, toolbar: toolbar);
  }

  static Future<HistoryResponse?> takeBackN(
    BuildContext context,
    int n, {
    bool pop = true,
    bool toolbar = false,
  }) async {
    return _gotoHistory(
      context,
      HistoryNavMode.takeBackN,
      number: n,
      pop: pop,
      toolbar: toolbar,
    );
  }





  @visibleForTesting
  static Future<HistoryResponse> doEachMove(
    HistoryNavMode navMode, [
    int? number,
  ]) async {

    switch (navMode) {
      case HistoryNavMode.takeBack:
        _takeBack(1);
        break;
      case HistoryNavMode.takeBackN:
        if (number == null) {
          return const HistoryRange();
        }
        _takeBack(number);
        break;
      case HistoryNavMode.takeBackAll:
        _takeBackAll();
        break;
      case HistoryNavMode.stepForward:
        _stepForward(1);
        break;
      case HistoryNavMode.stepForwardAll:
        _stepForwardAll();
        break;
    }


    final GameMode backupMode = GameController().gameInstance.gameMode;
    GameController().gameInstance.gameMode = GameMode.humanVsHuman;

    if (GameController().newGameRecorder == null) {
      GameController().newGameRecorder = GameController().gameRecorder;
    }


    GameController().reset();
    posKeyHistory.clear();

    final GameRecorder tempRec = GameController().newGameRecorder!;

    final List<ExtMove> pathMoves = _collectPathMoves(tempRec);

    bool success = true;
    for (final ExtMove move in pathMoves) {
      if (!GameController().gameInstance.doMove(move)) {
        importFailedStr = move.notation;
        success = false;
        break;
      }
    }


    GameController().gameInstance.gameMode = backupMode;

    final String? lastPosWithRemove =
        GameController().gameRecorder.lastPositionWithRemove;
    GameController().gameRecorder = tempRec;
    GameController().gameRecorder.lastPositionWithRemove = lastPosWithRemove;
    GameController().newGameRecorder = null;

    return success ? const HistoryOK() : const HistoryRule();
  }

  static Future<HistoryResponse?> gotoNode(
    BuildContext context,
    PgnNode<ExtMove> targetNode, {
    bool pop = true,
  }) async {

    GameController().isControllerActive = false;
    GameController().engine.stopSearching();


    final List<PgnNode<ExtMove>> path = <PgnNode<ExtMove>>[];
    PgnNode<ExtMove>? cur = targetNode;
    while (cur != null) {
      path.insert(0, cur);
      cur = cur.parent;
    }


    final GameMode backupMode = GameController().gameInstance.gameMode;

    GameController().gameInstance.gameMode = GameMode.humanVsHuman;


    GameController().reset();
    posKeyHistory.clear();

    bool success = true;
    for (final PgnNode<ExtMove> node in path) {
      if (node.data != null) {
        final bool ok = GameController().gameInstance.doMove(node.data!);
        if (!ok) {
          importFailedStr = node.data!.notation;
          success = false;
          break;
        }
      }
    }


    GameController().gameInstance.gameMode = backupMode;


    GameController().gameRecorder.activeNode = targetNode;


    GameController().isControllerActive = true;
    SoundManager().unMute();


    if (pop && context.mounted) {
      Navigator.pop(context);
    }

    return success ? const HistoryOK() : const HistoryRule();
  }


  static void _takeBack(int n) {
    while (n-- > 0) {
      final PgnNode<ExtMove>? node = GameController().gameRecorder.activeNode;
      if (node == null) {
        break;
      }

      if (node.parent == null) {
        break;
      }

      GameController().gameRecorder.activeNode = node.parent;
    }
  }


  static void _takeBackAll() {

    GameController().gameRecorder.activeNode =
        GameController().gameRecorder.pgnRoot;
  }


  static void _stepForward(int n) {
    while (n-- > 0) {
      final PgnNode<ExtMove>? node = GameController().gameRecorder.activeNode;
      if (node == null) {
        final PgnNode<ExtMove> root = GameController().gameRecorder.pgnRoot;
        if (root.children.isNotEmpty) {
          GameController().gameRecorder.activeNode = root.children.first;
        } else {
          break;
        }
      } else {
        if (node.children.isNotEmpty) {
          GameController().gameRecorder.activeNode = node.children.first;
        } else {
          break;
        }
      }
    }
  }


  static void _stepForwardAll() {
    while (true) {
      final PgnNode<ExtMove>? node = GameController().gameRecorder.activeNode;
      if (node == null) {
        final PgnNode<ExtMove> root = GameController().gameRecorder.pgnRoot;
        if (root.children.isNotEmpty) {
          GameController().gameRecorder.activeNode = root.children.first;
        } else {
          break;
        }
      } else if (node.children.isNotEmpty) {
        GameController().gameRecorder.activeNode = node.children.first;
      } else {
        break;
      }
    }
  }


  static List<ExtMove> _collectPathMoves(GameRecorder rec) {
    final List<ExtMove> moves = <ExtMove>[];
    PgnNode<ExtMove>? cur = rec.activeNode;
    while (cur != null && cur.parent != null) {

      if (cur.data != null) {
        moves.add(cur.data!);
      }
      cur = cur.parent;
    }

    return moves.reversed.toList();
  }
}

enum HistoryNavMode {
  takeBack,
  stepForward,
  takeBackAll,
  stepForwardAll,
  takeBackN,
}

extension HistoryNavModeExtension on HistoryNavMode {
  Future<void> gotoHistoryPlaySound() async {
    if (DB().generalSettings.keepMuteWhenTakingBack) {
      return;
    }
    switch (this) {
      case HistoryNavMode.stepForwardAll:
      case HistoryNavMode.stepForward:
        return SoundManager().playTone(Sound.place);
      case HistoryNavMode.takeBackAll:
      case HistoryNavMode.takeBackN:
      case HistoryNavMode.takeBack:
        return SoundManager().playTone(Sound.remove);
    }
  }
}
