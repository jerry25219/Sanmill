




part of '../mill.dart';

class TapHandler {
  TapHandler({
    required this.context,
  });



  static const String _logTag = "[Tap Handler]";

  final BuildContext context;

  final GameController controller = GameController();


  final void Function(String tip, {bool snackBar}) showTip =
      GameController().headerTipNotifier.showTip;

  bool get _isGameRunning =>
      GameController().position.winner == PieceColor.nobody;

  bool get isAiSideToMove => controller.gameInstance.isAiSideToMove;

  bool get _isBoardEmpty =>
      GameController().position.pieceOnBoardCount[PieceColor.white] == 0 &&
      GameController().position.pieceOnBoardCount[PieceColor.black] == 0;

  Future<EngineResponse> setupPosition(int sq) async {
    if (GameController().position.action == Act.place ||
        GameController().position.action == Act.select) {
      GameController().position.putPieceForSetupPosition(sq);
    } else if (GameController().position.action == Act.remove) {
      GameController().position._removePieceForSetupPosition(sq);
    } else {
      logger.e("$_logTag Invalid action: ${GameController().position.action}");
    }

    GameController().setupPositionNotifier.updateIcons();
    GameController().boardSemanticsNotifier.updateSemantics();
    GameController().headerTipNotifier.showTip(ExtMove.sqToNotation(sq),
        snackBar: false);

    return const EngineResponseHumanOK();
  }

  Future<EngineResponse> onBoardTap(int sq) async {

    if (AnalysisMode.isAnalyzing) {
      logger.i("$_logTag Analysis in progress, ignoring tap.");
      return const EngineResponseSkip();
    }


    AnalysisMode.disable();

    if (!GameController().isControllerReady) {
      logger.i("$_logTag Not ready, ignore tapping.");
      return const EngineResponseSkip();
    }

    if (GameController().gameInstance.gameMode == GameMode.humanVsLAN) {
      if (GameController().isLanOpponentTurn) {
        rootScaffoldMessengerKey.currentState!
            .showSnackBarClear(S.of(context).notYourTurn);
        return const EngineResponseSkip();
      }
      if (GameController().networkService == null ||
          !GameController().networkService!.isConnected) {
        logger.w("$_logTag No active LAN connection");
        showTip(S.of(context).noLanConnection, snackBar: true);
        return const EngineResponseSkip();
      }
    }

    GameController().loadedGameFilenamePrefix = null;

    if (GameController().gameInstance.gameMode == GameMode.setupPosition) {
      logger.t("$_logTag Setup position.");
      await setupPosition(sq);
      return const EngineResponseSkip();
    }

    if (GameController().gameInstance.gameMode == GameMode.testViaLAN) {
      logger.t("$_logTag Engine type is no human, ignore tapping.");
      return const EngineResponseSkip();
    }

    if (GameController().position.phase == Phase.gameOver) {
      logger.t("$_logTag Phase is gameOver, ignore tapping.");
      return const EngineResponseSkip();
    }


    if (GameController().gameInstance.gameMode == GameMode.humanVsLAN) {
      if (GameController().isLanOpponentTurn) {
        rootScaffoldMessengerKey.currentState!
            .showSnackBarClear(S.of(context).notYourTurn);
        return const EngineResponseSkip();
      }
      if (GameController().networkService == null ||
          !GameController().networkService!.isConnected) {
        logger.w("$_logTag No active LAN connection");
        showTip(S.of(context).noLanConnection, snackBar: true);
        return const EngineResponseSkip();
      }
    }


    if ((GameController().position.sideToMove == PieceColor.white ||
            GameController().position.sideToMove == PieceColor.black) ==
        false) {

      return const EngineResponseSkip();
    }


    if (GameController().gameInstance.gameMode != GameMode.humanVsHuman &&
        GameController().position.phase == Phase.placing &&
        _isBoardEmpty) {


      if (isAiSideToMove) {
        logger.i("$_logTag AI is not thinking. AI is to move.");

        return GameController().engineToGo(context, isMoveNow: false);
      }
    }

    if (isAiSideToMove &&
        GameController().gameInstance.gameMode != GameMode.humanVsLAN) {
      logger.i("$_logTag AI's turn, skip tapping.");
      return const EngineResponseSkip();
    }


    bool ret = false;
    switch (GameController().position.action) {
      case Act.place:
        if (GameController().position._putPiece(sq)) {

          PlayerTimer().stop();

          if (GameController().position.action == Act.remove) {
            if (GameController()
                .position
                .isStalemateRemoval(GameController().position.sideToMove)) {
              if (GameController().gameInstance.gameMode ==
                  GameMode.humanVsHuman) {
                final String side =
                    controller.position.sideToMove.playerName(context);
                showTip(
                    "${S.of(context).tipToMove(side)} ${S.of(context).tipRemove}");
              } else {
                showTip(S.of(context).tipRemove);
              }
            } else {
              if ((DB().ruleSettings.boardFullAction ==
                          BoardFullAction.firstAndSecondPlayerRemovePiece ||
                      DB().ruleSettings.boardFullAction ==
                          BoardFullAction.secondAndFirstPlayerRemovePiece ||
                      DB().ruleSettings.boardFullAction ==
                          BoardFullAction.sideToMoveRemovePiece) &&
                  GameController()
                          .position
                          .pieceOnBoardCount[PieceColor.white]! >
                      10 &&
                  GameController()
                          .position
                          .pieceOnBoardCount[PieceColor.black]! >
                      10) {

                if (GameController().gameInstance.gameMode ==
                    GameMode.humanVsHuman) {
                  final String side =
                      controller.position.sideToMove.playerName(context);
                  showTip(
                      "${S.of(context).tipToMove(side)} ${S.of(context).tipRemove}");
                } else {
                  showTip(S.of(context).tipRemove);
                }
              } else {
                if (GameController().gameInstance.gameMode ==
                    GameMode.humanVsHuman) {
                  final String side =
                      controller.position.sideToMove.playerName(context);
                  showTip(
                      "${S.of(context).tipToMove(side)} ${S.of(context).tipMill}");
                } else {
                  showTip(S.of(context).tipMill);
                }
              }
            }
          } else {
            if (GameController().gameInstance.gameMode == GameMode.humanVsAi) {
              if (DB().ruleSettings.millFormationActionInPlacingPhase ==
                  MillFormationActionInPlacingPhase
                      .removeOpponentsPieceFromHandThenYourTurn) {
                showTip(S.of(context).continueToMakeMove, snackBar: false);
              } else {
                if (GameController().position.phase == Phase.placing) {
                  if (GameController().gameInstance.gameMode ==
                      GameMode.humanVsHuman) {
                    final String side =
                        controller.position.sideToMove.playerName(context);
                    if (DB().ruleSettings.mayMoveInPlacingPhase) {
                      showTip(S.of(context).tipToMove(side));
                    } else {
                      showTip(
                          "${S.of(context).tipPlaced} ${S.of(context).tipToMove(side)}");
                    }
                  } else {
                    final String side =
                        controller.position.sideToMove.playerName(context);
                    if (DB().ruleSettings.mayMoveInPlacingPhase) {
                      showTip(S.of(context).tipToMove(side));
                    } else {
                      showTip(S.of(context).tipPlaced);
                    }
                  }
                } else {
                  if (GameController().gameInstance.gameMode ==
                      GameMode.humanVsHuman) {
                    final String side =
                        controller.position.sideToMove.playerName(context);
                    showTip(
                        "${S.of(context).tipToMove(side)} ${S.of(context).tipMove}");
                  } else {
                    showTip(S.of(context).tipMove);
                  }
                }
              }
            } else if (GameController().gameInstance.gameMode ==
                GameMode.humanVsHuman) {
              if (DB().ruleSettings.millFormationActionInPlacingPhase ==
                      MillFormationActionInPlacingPhase
                          .removeOpponentsPieceFromHandThenYourTurn ||
                  DB().ruleSettings.millFormationActionInPlacingPhase ==
                      MillFormationActionInPlacingPhase
                          .removeOpponentsPieceFromHandThenOpponentsTurn) {
                if (GameController().position.phase == Phase.placing) {
                  final String side =
                      controller.position.sideToMove.playerName(context);
                  if (DB().ruleSettings.mayMoveInPlacingPhase) {
                    showTip(S.of(context).tipToMove(side));
                  } else {
                    showTip(
                        "${S.of(context).tipPlaced} ${S.of(context).tipToMove(side)}");
                  }
                } else {
                  final String side =
                      controller.position.sideToMove.playerName(context);
                  showTip(S.of(context).tipToMove(side), snackBar: false);
                }
              } else {
                final String side =
                    controller.position.sideToMove.playerName(context);
                showTip(S.of(context).tipToMove(side), snackBar: false);
              }
            }
          }
          ret = true;
          logger.i("$_logTag putPiece: [$sq]");

          break;
        } else {
          logger.i("$_logTag putPiece: skip [$sq]");
          if (!(GameController().position.phase == Phase.moving &&
              GameController().position._board[sq] ==
                  GameController().position.sideToMove)) {
            if (GameController().gameInstance.gameMode ==
                GameMode.humanVsHuman) {
              final String side =
                  controller.position.sideToMove.playerName(context);
              showTip(
                  "${S.of(context).tipBanPlace} ${S.of(context).tipToMove(side)}");
            } else {
              showTip(S.of(context).tipBanPlace);
            }
          }
        }



        continue select;
      select:
      case Act.select:
        if (GameController().position.phase == Phase.placing) {
          if (GameController().gameInstance.gameMode == GameMode.humanVsHuman) {
            final String side =
                controller.position.sideToMove.playerName(context);
            showTip(
                "${S.of(context).tipCannotPlace} ${S.of(context).tipToMove(side)}");
          } else {
            showTip(S.of(context).tipCannotPlace);
          }
          break;
        }

        final GameResponse selectRet =
            GameController().position._selectPiece(sq);

        switch (selectRet) {
          case GameResponseOK():
            SoundManager().playTone(Sound.select);
            controller.gameInstance._select(squareToIndex[sq]!);
            ret = true;
            logger.i("$_logTag selectPiece: [$sq]");

            final int? pieceOnBoardCount = GameController()
                .position
                .pieceOnBoardCount[controller.position.sideToMove];
            if (GameController().position.phase == Phase.moving &&
                DB().ruleSettings.mayFly &&
                (pieceOnBoardCount! <= DB().ruleSettings.flyPieceCount &&
                    pieceOnBoardCount >= 3)) {
              logger.i("$_logTag May fly.");
              if (GameController().gameInstance.gameMode ==
                  GameMode.humanVsHuman) {
                final String side =
                    controller.position.sideToMove.playerName(context);
                showTip(
                    "${S.of(context).tipCanMoveToAnyPoint} ${S.of(context).tipToMove(side)}");
              } else {
                showTip(S.of(context).tipCanMoveToAnyPoint);
              }
            } else {
              if (GameController().gameInstance.gameMode ==
                  GameMode.humanVsHuman) {
                final String side =
                    controller.position.sideToMove.playerName(context);

                if (DB().ruleSettings.mayMoveInPlacingPhase) {
                  showTip(S.of(context).tipToMove(side));
                } else {
                  showTip(
                      "${S.of(context).tipToMove(side)} ${S.of(context).tipPlace}");
                }
              } else {
                final String side =
                    controller.position.sideToMove.playerName(context);
                if (DB().ruleSettings.mayMoveInPlacingPhase) {
                  showTip(S.of(context).tipToMove(side));
                } else {
                  showTip(S.of(context).tipPlace);
                }
              }
              if (DB().generalSettings.screenReaderSupport) {
                showTip(S.of(context).selected);
              }
            }
            break;
          case IllegalPhase():
            if (GameController().position.phase != Phase.gameOver) {
              if (GameController().gameInstance.gameMode ==
                  GameMode.humanVsHuman) {
                final String side =
                    controller.position.sideToMove.playerName(context);
                showTip(
                    "${S.of(context).tipCannotMove} ${S.of(context).tipToMove(side)}");
              } else {
                showTip(S.of(context).tipCannotMove);
              }
            }
            break;
          case NoPieceSelected():
            break;

          case CanOnlyMoveToAdjacentEmptyPoints():
            if (GameController().gameInstance.gameMode ==
                GameMode.humanVsHuman) {
              final String side =
                  controller.position.sideToMove.playerName(context);
              showTip(
                  "${S.of(context).tipCanMoveOnePoint} ${S.of(context).tipToMove(side)}");
            } else {
              showTip(S.of(context).tipCanMoveOnePoint);
            }
            break;
          case SelectOurPieceToMove():
            if (GameController().gameInstance.gameMode ==
                GameMode.humanVsHuman) {
              final String side =
                  controller.position.sideToMove.playerName(context);
              showTip(
                  "${S.of(context).tipSelectPieceToMove} ${S.of(context).tipToMove(side)}");
            } else {
              showTip(S.of(context).tipSelectPieceToMove);
            }
            break;
          case IllegalAction():
            if (GameController().gameInstance.gameMode ==
                GameMode.humanVsHuman) {
              final String side =
                  controller.position.sideToMove.playerName(context);
              showTip(
                  "${S.of(context).tipSelectWrong} ${S.of(context).tipToMove(side)}");
            } else {
              showTip(S.of(context).tipSelectWrong);
            }
            break;
          default:
            SoundManager().playTone(Sound.illegal);
            logger.i("$_logTag selectPiece: skip [$sq]");
            break;
        }

        break;

      case Act.remove:
        final GameResponse removeRet =
            GameController().position._removePiece(sq);

        switch (removeRet) {
          case GameResponseOK():

            PlayerTimer().stop();

            ret = true;
            logger.i("$_logTag removePiece: [$sq]");



            if (GameController().position.pieceToRemoveCount[
                    GameController().position.sideToMove]! >=
                1) {
              if (GameController().gameInstance.gameMode ==
                  GameMode.humanVsHuman) {
                final String side =
                    controller.position.sideToMove.playerName(context);
                showTip(
                    "${S.of(context).tipToMove(side)} ${S.of(context).tipContinueMill}");
              } else {
                showTip(S.of(context).tipContinueMill);
              }
            } else {
              if (GameController().gameInstance.gameMode ==
                  GameMode.humanVsAi) {
                showTip(S.of(context).tipRemoved, snackBar: false);
              } else if (GameController().gameInstance.gameMode ==
                  GameMode.humanVsHuman) {
                if ((DB().ruleSettings.piecesCount == 12 &&
                        DB().ruleSettings.boardFullAction !=
                            BoardFullAction.firstPlayerLose &&
                        DB().ruleSettings.boardFullAction !=
                            BoardFullAction.agreeToDraw &&
                        GameController().position.phase == Phase.moving &&
                        GameController()
                                .position
                                .pieceOnBoardCount[PieceColor.white] ==
                            11 &&
                        GameController()
                                .position
                                .pieceOnBoardCount[PieceColor.white] ==
                            11) ||
                    GameController().position.isNeedStalemateRemoval == true) {
                  final String side =
                      controller.position.sideToMove.playerName(context);
                  showTip(S.of(context).tipToMove(side), snackBar: false);
                } else {
                  final String side =
                      controller.position.sideToMove.playerName(context);
                  showTip(S.of(context).tipToMove(side), snackBar: false);
                }
              }
            }
            break;
          case CanNotRemoveSelf():
            logger.i(
                "$_logTag removePiece: Cannot Remove our pieces, skip [$sq]");
            if (GameController().gameInstance.gameMode ==
                GameMode.humanVsHuman) {
              final String side =
                  controller.position.sideToMove.playerName(context);
              showTip(
                  "${S.of(context).tipSelectOpponentsPiece} ${S.of(context).tipToMove(side)}");
            } else {
              showTip(S.of(context).tipSelectOpponentsPiece);
            }
            break;
          case ShouldRemoveSelf():
            logger
                .i("$_logTag removePiece: Should Remove our piece, skip [$sq]");
            if (GameController().gameInstance.gameMode ==
                GameMode.humanVsHuman) {
              final String side =
                  controller.position.sideToMove.playerName(context);
              showTip(
                  "${S.of(context).tipSelectOwnPiece} ${S.of(context).tipToMove(side)}");
            } else {
              showTip(S.of(context).tipSelectOwnPiece);
            }
            break;
          case CanNotRemoveMill():
            logger.i(
              "$_logTag removePiece: Cannot remove piece from Mill, skip [$sq]",
            );
            if (GameController().gameInstance.gameMode ==
                GameMode.humanVsHuman) {
              final String side =
                  controller.position.sideToMove.playerName(context);
              showTip(
                  "${S.of(context).tipCannotRemovePieceFromMill} ${S.of(context).tipToMove(side)}");
            } else {
              showTip(S.of(context).tipCannotRemovePieceFromMill);
            }
            break;
          case CanNotRemoveNonadjacent():
            logger.i(
              "$_logTag removePiece: Cannot remove piece nonadjacent, skip [$sq]",
            );

            if (GameController().gameInstance.gameMode ==
                GameMode.humanVsHuman) {
              final String side =
                  controller.position.sideToMove.playerName(context);
              showTip(
                  "${S.of(context).tipCanNotRemoveNonadjacent} ${S.of(context).tipToMove(side)}");
            } else {
              showTip(S.of(context).tipCanNotRemoveNonadjacent);
            }
            break;
          default:
            logger.i("$_logTag removePiece: skip [$sq]");
            if (GameController().position.phase != Phase.gameOver) {
              if (GameController().gameInstance.gameMode ==
                  GameMode.humanVsHuman) {
                final String side =
                    controller.position.sideToMove.playerName(context);
                showTip(
                    "${S.of(context).tipBanRemove} ${S.of(context).tipToMove(side)}");
              } else {
                showTip(S.of(context).tipBanRemove);
              }
            }
            break;
        }
    }

    if (ret) {




      ++GameController().position._gamePly;
      ++GameController().position.st.rule50;
      ++GameController().position.st.pliesFromNull;



      if (GameController().position._record != null &&
          GameController().position._record!.type == MoveType.move) {
        if (posKeyHistory.isEmpty ||
            posKeyHistory.last != GameController().position.st.key) {
          posKeyHistory.add(GameController().position.st.key);
          if (DB().ruleSettings.threefoldRepetitionRule &&
              GameController().position._hasGameCycle) {
            GameController().position.setGameOver(
                  PieceColor.draw,
                  GameOverReason.drawThreefoldRepetition,
                );
          }
        }
      } else {
        posKeyHistory.clear();
      }

      if (GameController().position._record != null) {
        controller.gameRecorder
            .appendMoveIfDifferent(GameController().position._record!);
        if (GameController().position._record!.type == MoveType.remove) {
          controller.gameRecorder.lastPositionWithRemove =
              GameController().position.fen;
        }


        if (GameController().gameInstance.gameMode == GameMode.humanVsLAN) {
          final String moveNotation = GameController().position._record!.move;
          GameController().sendLanMove(moveNotation);
        }


        if (EnvironmentConfig.catcher && !kIsWeb && !Platform.isIOS) {
          final Catcher2Options options = catcher.getCurrentConfig()!;
          options.customParameters["MoveList"] =
              GameController().gameRecorder.moveHistoryText;
        }
      }



      if (_isGameRunning && !GameController().gameInstance.isAiSideToMove) {
        logger.d(
            "$_logTag Starting timer for human opponent after successful move.");
        PlayerTimer().start();
      }


      if (_isGameRunning && GameController().gameInstance.isAiSideToMove) {
        return GameController().engineToGo(context, isMoveNow: false);
      } else {
        return const EngineResponseHumanOK();
      }
    } else {
      SoundManager().playTone(Sound.illegal);
    }

    GameController().headerIconsNotifier.showIcons();
    GameController().boardSemanticsNotifier.updateSemantics();

    return const EngineResponseHumanOK();
  }
}
