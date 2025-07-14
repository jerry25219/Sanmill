




import 'dart:async';

import 'package:flutter/material.dart';

import '../../shared/database/database.dart';
import 'mill.dart';





class PlayerTimer {

  factory PlayerTimer() => instance;

  PlayerTimer._();

  static final PlayerTimer instance = PlayerTimer._();


  Timer? _timer;


  int _remainingTime = 0;


  final ValueNotifier<int> remainingTimeNotifier = ValueNotifier<int>(0);


  bool _isActive = false;


  void start() {
    final GameController gameController = GameController();


    if (gameController.gameInstance.gameMode == GameMode.humanVsLAN) {
      return;
    }


    if (gameController.gameInstance.gameMode == GameMode.aiVsAi) {
      _isActive = false;
      remainingTimeNotifier.value = 0;
      return;
    }


    if (gameController.gameRecorder.mainlineMoves.isEmpty) {
      return;
    }



    final bool isAiWithUnlimitedTime =
        gameController.gameInstance.isAiSideToMove &&
            DB().generalSettings.moveTime <= 0;
    if (isAiWithUnlimitedTime) {

      _remainingTime = 0;
      remainingTimeNotifier.value = 0;
      _isActive = false;
      return;
    }


    _timer?.cancel();


    final bool isAiTurn = gameController.gameInstance.isAiSideToMove;
    final int timeLimit = isAiTurn
        ? DB().generalSettings.moveTime
        : DB().generalSettings.humanMoveTime;


    if (timeLimit <= 0) {
      return;
    }


    _remainingTime = timeLimit;
    remainingTimeNotifier.value = _remainingTime;
    _isActive = true;


    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }


  void stop() {
    _timer?.cancel();
    _timer = null;
    _isActive = false;
  }


  void reset() {
    stop();
    _remainingTime = 0;
    remainingTimeNotifier.value = 0;
  }


  void _tick(Timer timer) {

    final GameController gameController = GameController();
    final Position position = gameController.position;


    final bool isAIThinking = gameController.gameInstance.isAiSideToMove &&
        gameController.isEngineRunning;


    if (_remainingTime > 0) {
      _remainingTime--;
      remainingTimeNotifier.value = _remainingTime;


      if (isAIThinking) {
        return;
      }
    } else if (_remainingTime <= 0) {

      stop();


      final bool isLanMode =
          gameController.gameInstance.gameMode == GameMode.humanVsLAN;
      final bool isHumanPlayer = !gameController.gameInstance.isAiSideToMove;
      final bool isAIWithUnlimitedTime =
          gameController.gameInstance.isAiSideToMove &&
              DB().generalSettings.moveTime <= 0;

      final bool isHumanWithUnlimitedTime =
          !gameController.gameInstance.isAiSideToMove &&
              DB().generalSettings.humanMoveTime <= 0;




      if (isLanMode ||
          !isHumanPlayer ||
          isAIWithUnlimitedTime ||
          isHumanWithUnlimitedTime) {
        _remainingTime = 0;
        remainingTimeNotifier.value = 0;



        if (!isHumanPlayer && !isAIWithUnlimitedTime && !isLanMode) {

          final int timeLimit = DB().generalSettings.moveTime;
          if (timeLimit > 0) {
            _remainingTime = timeLimit;
            remainingTimeNotifier.value = _remainingTime;
            _isActive = true;
            _timer = Timer.periodic(const Duration(seconds: 1), _tick);
          }
        }

        return;
      }



      position.setGameOver(
        position.sideToMove.opponent,
        GameOverReason.loseTimeout,
      );


      gameController.headerTipNotifier.showTip(
          "Time is over, ${position.sideToMove == PieceColor.white ? 'Player 1' : 'Player 2'} lost.");
      gameController.gameResultNotifier.showResult(force: true);


      SoundManager().playTone(Sound.lose);
    }
  }


  bool get isActive => _isActive;


  int get remainingTime => _remainingTime;
}
