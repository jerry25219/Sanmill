




part of '../mill.dart';

class Engine {
  Engine();

  static const MethodChannel _platform =
      MethodChannel("com.calcitem.sanmill/engine");

  bool get _isPlatformChannelAvailable => !kIsWeb;

  static const String _logTag = "[engine]";

  Future<void> startup() async {
    await setOptions();

    if (!_isPlatformChannelAvailable) {
      return;
    }

    await _platform.invokeMethod("startup");
    await _waitResponse(<String>["uciok"]);
  }

  Future<void> _send(String command) async {
    if (!_isPlatformChannelAvailable) {
      return;
    }

    logger.t("$_logTag send: $command");
    await _platform.invokeMethod("send", command);
  }

  Future<void> _sendOptions(String name, dynamic option) async {
    if (!_isPlatformChannelAvailable) {
      return;
    }

    final String command = "setoption name $name value $option";
    await _send(command);

    if (EnvironmentConfig.catcher && !kIsWeb && !Platform.isIOS) {
      final Catcher2Options options = catcher.getCurrentConfig()!;
      options.customParameters[name] = command;
    }
  }

  Future<String?> _read() async {
    if (!_isPlatformChannelAvailable) {
      return "";
    }

    return _platform.invokeMethod("read");
  }

  Future<void> shutdown() async {
    if (!_isPlatformChannelAvailable) {
      return;
    }

    await _platform.invokeMethod("shutdown");
  }









  FutureOr<bool> isThinking() async {
    if (!_isPlatformChannelAvailable) {
      return false;
    }

    final bool? isThinking = await _platform.invokeMethod<bool>("isThinking");

    if (isThinking is bool) {
      return isThinking;
    } else {

      throw "Invalid platform response. Expected a value of type bool";
    }
  }



  Future<void> _saveFenToFile(String fen) async {
    try {

      final Directory directory = await getApplicationDocumentsDirectory();


      final String path = '${directory.path}/fen.txt';

      final File file = File(path);


      await file.writeAsString('$fen\n', mode: FileMode.append);

      logger.i("Successfully saved FEN to $path");
    } catch (e) {
      logger.e("Failed to save FEN to file: $e");

    }
  }

  Future<EngineRet> search({bool moveNow = false}) async {

    AnalysisMode.disable();

    String? fen;
    final String normalizedFen;

    if (await isThinking()) {
      await stopSearching();
    } else if (moveNow) {

      await stopSearching();
      final String? fen = _getPositionFen();
      if (fen == null) {

        throw const EngineNoBestMove();
      }
      await _send(fen);
      await _send("go");
      await stopSearching();
    }

    if (!moveNow) {
      fen = GameController().position.fen;
      if (fen == null) {

        throw const EngineNoBestMove();
      }

      final List<String> fenFields = fen.split(' ');
      if (fenFields.length < 2) {
        normalizedFen = fen;
      } else {

        fenFields[fenFields.length - 2] = '0';

        fenFields[fenFields.length - 3] = '0';
        normalizedFen = fenFields.join(' ');
      }

      logger.i("FEN = $normalizedFen");


      if (isRuleSupportingOpeningBook() &&
          DB().generalSettings.useOpeningBook &&
          (nineMensMorrisFenToBestMoves.containsKey(normalizedFen) ||
              elFiljaFenToBestMoves.containsKey(normalizedFen))) {
        final List<String> bestMoves;

        if (DB().ruleSettings.isLikelyNineMensMorris()) {
          bestMoves = nineMensMorrisFenToBestMoves[normalizedFen]!;
        } else if (DB().ruleSettings.isLikelyElFilja()) {
          bestMoves = elFiljaFenToBestMoves[normalizedFen]!;
        } else {
          bestMoves = nineMensMorrisFenToBestMoves[normalizedFen]!;
        }


        final bool shufflingEnabled = DB().generalSettings.shufflingEnabled;

        String selectedMove;

        if (shufflingEnabled) {

          final int seed = DateTime.now().millisecondsSinceEpoch;
          final Random random = Random(seed);
          selectedMove = bestMoves[random.nextInt(bestMoves.length)];
        } else {

          selectedMove = bestMoves.first;
        }


        if (selectedMove.startsWith('x')) {
          await Future<void>.delayed(const Duration(milliseconds: 100));

          return EngineRet(
            "0", // Default score
            AiMoveType.openingBook,
            ExtMove(
              selectedMove,
              side: GameController().position.sideToMove,
            ),
          );
        } else {
          await Future<void>.delayed(const Duration(milliseconds: 100));

          return EngineRet(
            "0", // Default score
            AiMoveType.openingBook,
            ExtMove(
              selectedMove,
              side: GameController().position.sideToMove,
            ),
          );
        }
      } else {

        fen = _getPositionFen();
        if (fen == null) {

          throw const EngineNoBestMove();
        }
        await _send(fen);
        await _send("go");
      }
    } else {
      logger.t("$_logTag Move now");
    }

    final String? response =
        await _waitResponse(<String>["bestmove", "nobestmove"]);

    if (response == null) {

      throw const EngineTimeOut();
    }

    logger.t("$_logTag response: $response");

    if (response.contains("bestmove")) {
      final RegExp regex =
          RegExp(r"info score (-?\d+)(?: aimovetype (\w+))? bestmove (.*)");
      final Match? match = regex.firstMatch(response);
      String value = "";
      String aiMoveTypeStr = "";
      String best = "";
      AiMoveType aiMoveType = AiMoveType.unknown;

      if (match != null) {
        value = match.group(1)!;
        aiMoveTypeStr = match.group(2) ?? "";
        best = match.group(3)!.trim();
      }

      if (aiMoveTypeStr == "" || aiMoveTypeStr == "traditional") {
        aiMoveType = AiMoveType.traditional;
      } else if (aiMoveTypeStr == "perfect") {
        aiMoveType = AiMoveType.perfect;
        if (EnvironmentConfig.devMode == true) {
          final String? saveFen = GameController().position.fen;


          if (saveFen != null) {
            if (!saveFen.contains(" m ")) {
              await _saveFenToFile(saveFen);
            } else {
              logger.w("$_logTag saveFen contains ' m ', not saving to file.");
            }
          } else {
            logger.w("$_logTag saveFen is null, cannot save to file.");
          }
        }
      } else if (aiMoveTypeStr == "consensus") {
        aiMoveType = AiMoveType.consensus;
      }

      return EngineRet(
          value,
          aiMoveType,
          ExtMove(
            best,
            side: GameController().position.sideToMove.opponent,
          ));
    }

    if (response.contains("nobestmove")) {

      throw const EngineNoBestMove();
    }


    throw const EngineTimeOut();
  }

  Future<String?> _waitResponse(
    List<String> prefixes, {
    int sleep = 100,
    int times = 0,
  }) async {
    final GeneralSettings settings = DB().generalSettings;

    int timeLimit = EnvironmentConfig.devMode ? 100 : 6000;

    if (settings.moveTime > 0) {

      timeLimit = settings.moveTime * 10 * 64 + 10;
    }

    if (times > timeLimit) {
      logger.t("$_logTag Timeout. sleep = $sleep, times = $times");






      if (EnvironmentConfig.devMode) {
        throw TimeoutException("$_logTag waitResponse timeout.");
      }
      return null;
    }

    final String? response = await _read();

    if (response != null) {
      for (final String prefix in prefixes) {
        if (response.contains(prefix)) {
          return response;
        } else {
          if (response == "") {
            if (EnvironmentConfig.devMode) {
              logger.w("$_logTag Empty response");
            }
          } else {
            logger.w("$_logTag Unexpected engine response: $response");
          }
        }
      }
    }

    return Future<String?>.delayed(
      Duration(milliseconds: sleep),
      () => _waitResponse(prefixes, times: times + 1),
    );
  }

  Future<void> stopSearching() async {
    logger.w("$_logTag Stop current thinking...");
    await _send("stop");
  }

  Future<void> setGeneralOptions() async {
    if (kIsWeb) {
      return;
    }

    final GeneralSettings generalSettings = DB().generalSettings;





    await _sendOptions("SkillLevel", generalSettings.skillLevel);
    await _sendOptions("MoveTime", generalSettings.moveTime);


    await _sendOptions(
        "Algorithm",
        generalSettings.searchAlgorithm?.index ??
            SearchAlgorithm.mtdf.index);

    bool usePerfectDatabase = false;

    if (isRuleSupportingPerfectDatabase()) {
      usePerfectDatabase = generalSettings.usePerfectDatabase;
    } else {
      usePerfectDatabase = false;
      if (generalSettings.usePerfectDatabase) {
        DB().generalSettings =
            generalSettings.copyWith(usePerfectDatabase: false);
      }
    }

    await _sendOptions(
      "UsePerfectDatabase",
      usePerfectDatabase,
    );

    final Directory? dir = (!kIsWeb && Platform.isAndroid)
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    final String perfectDatabasePath = '${dir?.path ?? ""}/strong';
    await _sendOptions(
      "PerfectDatabasePath",
      perfectDatabasePath,
    );
    await _sendOptions(
      "DrawOnHumanExperience",
      generalSettings.drawOnHumanExperience,
    );
    await _sendOptions("ConsiderMobility", generalSettings.considerMobility);
    await _sendOptions(
        "FocusOnBlockingPaths", generalSettings.focusOnBlockingPaths);
    await _sendOptions("AiIsLazy", generalSettings.aiIsLazy);
    await _sendOptions("Shuffling", generalSettings.shufflingEnabled);


    await _sendOptions("DeveloperMode", EnvironmentConfig.devMode);
  }

  Future<void> setRuleOptions() async {
    final RuleSettings ruleSettings = DB().ruleSettings;


    await _sendOptions("PiecesCount", ruleSettings.piecesCount);
    await _sendOptions("HasDiagonalLines", ruleSettings.hasDiagonalLines);
    await _sendOptions("NMoveRule", ruleSettings.nMoveRule);
    await _sendOptions("EndgameNMoveRule", ruleSettings.endgameNMoveRule);
    await _sendOptions(
      "ThreefoldRepetitionRule",
      ruleSettings.threefoldRepetitionRule,
    );

    await _sendOptions("PiecesAtLeastCount", ruleSettings.piecesAtLeastCount);


    await _sendOptions(
        "BoardFullAction",
        ruleSettings.boardFullAction?.index ??
            BoardFullAction.firstPlayerLose.index);
    await _sendOptions(
        "MillFormationActionInPlacingPhase",
        ruleSettings.millFormationActionInPlacingPhase?.index ??
            MillFormationActionInPlacingPhase
                .removeOpponentsPieceFromBoard.index);
    await _sendOptions(
      "MayMoveInPlacingPhase",
      ruleSettings.mayMoveInPlacingPhase,
    );


    await _sendOptions(
      "IsDefenderMoveFirst",
      ruleSettings.isDefenderMoveFirst,
    );
    await _sendOptions(
      "RestrictRepeatedMillsFormation",
      ruleSettings.restrictRepeatedMillsFormation,
    );
    await _sendOptions(
        "StalemateAction",
        ruleSettings.stalemateAction?.index ??
            StalemateAction.endWithStalemateLoss.index);


    await _sendOptions("MayFly", ruleSettings.mayFly);
    await _sendOptions("FlyPieceCount", ruleSettings.flyPieceCount);


    await _sendOptions(
      "MayRemoveFromMillsAlways",
      ruleSettings.mayRemoveFromMillsAlways,
    );
    await _sendOptions("MayRemoveMultiple", ruleSettings.mayRemoveMultiple);
    await _sendOptions("OneTimeUseMill", ruleSettings.oneTimeUseMill);
  }

  Future<void> setOptions() async {
    logger.i("$_logTag reloaded engine options");

    await setGeneralOptions();
    await setRuleOptions();
  }

  static bool isRuleSupportingOpeningBook() {
    final RuleSettings ruleSettings = DB().ruleSettings;

    if (ruleSettings.isLikelyNineMensMorris() ||
        ruleSettings.isLikelyElFilja()) {
      return true;
    } else {
      return false;
    }
  }

  String? _getPositionFen() {
    final String? startPosition =
        GameController().gameRecorder.lastPositionWithRemove;

    if (startPosition == null ||
        GameController().position.validateFen(startPosition) == false) {
      logger.e("Invalid FEN: $startPosition");
      return null;
    }

    final String? moves = GameController().position.movesSinceLastRemove;

    final StringBuffer posFenStr = StringBuffer("position fen $startPosition");

    if (moves != null) {
      posFenStr.write(" moves $moves");
    }

    final String ret = posFenStr.toString();


    if (GameController().gameRecorder.lastPositionWithRemove ==
        GameController().gameRecorder.setupPosition) {
      if (GameController().position.action == Act.remove) {



      }
    }

    if (EnvironmentConfig.catcher && !kIsWeb && !Platform.isIOS) {
      final Catcher2Options options = catcher.getCurrentConfig()!;
      options.customParameters["PositionFen"] = ret;
    }

    return ret;
  }


  Future<PositionAnalysisResult> analyzePosition() async {
    final String? fen = GameController().position.fen;
    if (fen == null) {
      return PositionAnalysisResult.error("Invalid board position");
    }


    final String command = "analyze fen $fen";

    try {

      await _send(command);


      final String? response = await _waitResponse(<String>["info analysis"]);
      if (response == null) {
        return PositionAnalysisResult.error("Engine did not respond");
      }




      final List<MoveAnalysisResult> results = <MoveAnalysisResult>[];


      if (EnvironmentConfig.devMode) {
        logger.i("$_logTag Raw analysis response: $response");
      }

      final List<String> rawParts =
          response.replaceFirst("info analysis ", "").split(" ");


      final List<String> parts = <String>[];
      String buffer = "";
      for (final String token in rawParts) {
        if (buffer.isEmpty) {
          buffer = token;
        } else {
          buffer += " $token";
        }


        if (buffer.contains('=') && buffer.trim().endsWith(')')) {
          parts.add(buffer.trim());
          buffer = "";
        }
      }


      if (buffer.isNotEmpty && buffer.contains('=')) {
        parts.add(buffer.trim());
      }

      for (final String part in parts) {
        if (part.contains("=")) {
          final List<String> moveAndOutcome = part.split("=");
          if (moveAndOutcome.length == 2) {
            final String moveStr = moveAndOutcome[0];
            final GameOutcome outcome = _parseOutcome(moveAndOutcome[1]);


            if (EnvironmentConfig.devMode) {
              logger.i(
                  "$_logTag Parsed move: $moveStr, outcome: ${outcome.name}, "
                  "value: ${outcome.valueStr}, steps: ${outcome.stepCount}");
            }


            if (moveStr.startsWith('x') && moveStr.length == 3) {

              final String squareName =
                  moveStr.substring(1);

              results.add(MoveAnalysisResult(
                move: moveStr,
                outcome: outcome,
                toSquare: pgn.Square(squareName),
              ));
            } else if (moveStr.contains('-') && moveStr.length == 5) {

              final List<String> squares = moveStr.split('-');
              if (squares.length == 2) {
                final String fromSquare = squares[0];
                final String toSquare = squares[1];

                results.add(MoveAnalysisResult(
                  move: moveStr,
                  outcome: outcome,
                  fromSquare: pgn.Square(fromSquare),
                  toSquare: pgn.Square(toSquare),
                ));
              }
            } else if (moveStr.length == 2 &&
                RegExp(r'^[a-g][1-8]$').hasMatch(moveStr)) {

              results.add(MoveAnalysisResult(
                move: moveStr,
                outcome: outcome,
                toSquare: pgn.Square(moveStr),
              ));
            } else {
              logger.w("$_logTag Unrecognized move format: $moveStr");
            }
          }
        }
      }

      if (results.isEmpty) {
        return PositionAnalysisResult.error("No analysis results available");
      }

      return PositionAnalysisResult(possibleMoves: results);
    } catch (e) {
      logger.e("$_logTag Error during analysis: $e");
      return PositionAnalysisResult.error("Error during analysis: $e");
    }
  }


  static GameOutcome _parseOutcome(String outcomeStr) {

    if (EnvironmentConfig.devMode) {
      logger.i("Parsing outcome string: '$outcomeStr'");
    }



    String value = "";
    int? stepCount;

    final RegExp valuePattern = RegExp(r'([a-z]+)\(([^)]+)\)');
    final Match? valueMatch = valuePattern.firstMatch(outcomeStr);

    if (valueMatch != null && valueMatch.groupCount >= 2) {
      outcomeStr = valueMatch.group(1)!;
      final String valueStr = valueMatch.group(2)!;


      if (EnvironmentConfig.devMode) {
        logger.i("Extracted outcome: '$outcomeStr', value part: '$valueStr'");
      }


      final RegExp stepPattern = RegExp(r'(-?\d+)\s+in\s+(\d+)\s+steps?');
      final Match? stepMatch = stepPattern.firstMatch(valueStr);

      if (stepMatch != null && stepMatch.groupCount >= 2) {
        value = stepMatch.group(1)!;
        stepCount = int.tryParse(stepMatch.group(2)!);


        if (EnvironmentConfig.devMode) {
          logger.i("Extracted step count: $stepCount from value: $value");
        }
      } else {

        final RegExp numPattern = RegExp(r'(-?\d+)');
        final Match? numMatch = numPattern.firstMatch(valueStr);
        if (numMatch != null) {
          value = numMatch.group(1)!;
        }


        if (EnvironmentConfig.devMode) {
          logger.i("No step count found, extracted value: '$value'");
        }
      }
    } else {

      if (EnvironmentConfig.devMode) {
        logger.i(
            "Failed to match value pattern in outcome string: '$outcomeStr'");
      }
    }


    GameOutcome baseOutcome;
    switch (outcomeStr.toLowerCase()) {
      case "win":
        baseOutcome = GameOutcome.win;
        break;
      case "draw":
        baseOutcome = GameOutcome.draw;
        break;
      case "loss":
        baseOutcome = GameOutcome.loss;
        break;
      case "advantage":
        baseOutcome = GameOutcome.advantage;
        break;
      case "disadvantage":
        baseOutcome = GameOutcome.disadvantage;
        break;
      case "unknown":
      default:
        baseOutcome = GameOutcome.unknown;
        break;
    }


    GameOutcome result;
    if (value.isNotEmpty && stepCount != null) {
      result = GameOutcome.withValueAndSteps(baseOutcome, value, stepCount);
      if (EnvironmentConfig.devMode) {
        logger.i(
            "Created outcome with steps: ${result.name}, value: ${result.valueStr}, steps: ${result.stepCount}");
      }
    } else if (value.isNotEmpty) {
      result = GameOutcome.withValue(baseOutcome, value);
      if (EnvironmentConfig.devMode) {
        logger.i(
            "Created outcome without steps: ${result.name}, value: ${result.valueStr}");
      }
    } else {
      result = baseOutcome;
      if (EnvironmentConfig.devMode) {
        logger.i("Created basic outcome: ${result.name}");
      }
    }

    return result;
  }
}

enum GameMode {
  humanVsAi,
  humanVsHuman,
  aiVsAi,
  setupPosition,
  humanVsCloud, // Not Implemented
  humanVsLAN,
  testViaLAN, // Not Implemented
}

Map<AiMoveType, IconData> aiMoveTypeIcons = <AiMoveType, IconData>{
  AiMoveType.traditional: FluentIcons.bot_24_filled,
  AiMoveType.perfect: FluentIcons.database_24_filled,
  AiMoveType.consensus: FluentIcons.bot_add_24_filled,
  AiMoveType.openingBook: FluentIcons.book_24_filled,
  AiMoveType.unknown: FluentIcons.bot_24_filled,
};

extension GameModeExtension on GameMode {
  IconData get leftHeaderIcon {
    final IconData botIcon = aiMoveTypeIcons[GameController().aiMoveType] ??
        FluentIcons.bot_24_filled;

    switch (this) {
      case GameMode.humanVsAi:
        if (DB().generalSettings.aiMovesFirst) {
          return botIcon;
        } else {
          return FluentIcons.person_24_filled;
        }
      case GameMode.humanVsHuman:
        return FluentIcons.person_24_filled;
      case GameMode.aiVsAi:
        return botIcon;
      case GameMode.setupPosition:
        if (DB().generalSettings.aiMovesFirst) {
          return FluentIcons.bot_24_regular;
        } else {
          return FluentIcons.person_24_regular;
        }
      case GameMode.humanVsCloud:
        return FluentIcons.person_24_filled;
      case GameMode.humanVsLAN:
        return FluentIcons.person_24_filled;
      case GameMode.testViaLAN:
        return FluentIcons.wifi_1_24_filled;
    }
  }

  IconData get rightHeaderIcon {
    final IconData botIcon = aiMoveTypeIcons[GameController().aiMoveType] ??
        FluentIcons.bot_24_filled;

    switch (this) {
      case GameMode.humanVsAi:
        if (DB().generalSettings.aiMovesFirst) {
          return FluentIcons.person_24_filled;
        } else {
          return botIcon;
        }
      case GameMode.humanVsHuman:
        return FluentIcons.person_24_filled;
      case GameMode.aiVsAi:
        return botIcon;
      case GameMode.setupPosition:
        if (DB().generalSettings.aiMovesFirst) {
          return FluentIcons.person_24_regular;
        } else {
          return FluentIcons.bot_24_regular;
        }
      case GameMode.humanVsCloud:
        return FluentIcons.cloud_24_filled;
      case GameMode.humanVsLAN:
        return FluentIcons.wifi_1_24_filled;
      case GameMode.testViaLAN:
        return FluentIcons.wifi_1_24_filled;
    }
  }

  Map<PieceColor, bool> get whoIsAI {
    switch (this) {
      case GameMode.humanVsAi:
      case GameMode.testViaLAN:
        return <PieceColor, bool>{
          PieceColor.white: DB().generalSettings.aiMovesFirst,
          PieceColor.black: !DB().generalSettings.aiMovesFirst,
        };
      case GameMode.setupPosition:
      case GameMode.humanVsHuman:
      case GameMode.humanVsLAN:
      case GameMode.humanVsCloud:
        return <PieceColor, bool>{
          PieceColor.white: false,
          PieceColor.black: false,
        };
      case GameMode.aiVsAi:
        return <PieceColor, bool>{
          PieceColor.white: true,
          PieceColor.black: true,
        };
    }
  }
}


class MoveAnalysisResult {
  MoveAnalysisResult({
    required this.move,
    required this.outcome,
    this.fromSquare,
    required this.toSquare,
  });

  final String move;
  final GameOutcome outcome;
  final pgn.Square? fromSquare;
  final pgn.Square toSquare;
}


class PositionAnalysisResult {
  PositionAnalysisResult({
    required this.possibleMoves,
    this.isValid = true,
    this.errorMessage,
  });

  factory PositionAnalysisResult.error(String message) {
    return PositionAnalysisResult(
      possibleMoves: <MoveAnalysisResult>[],
      isValid: false,
      errorMessage: message,
    );
  }

  final List<MoveAnalysisResult> possibleMoves;
  final bool isValid;
  final String? errorMessage;
}


@immutable
class GameOutcome {
  const GameOutcome(this.name, {this.valueStr, this.stepCount});

  final String name;


  final String? valueStr;


  final int? stepCount;


  static const GameOutcome win = GameOutcome('win');
  static const GameOutcome draw = GameOutcome('draw');
  static const GameOutcome loss = GameOutcome('loss');
  static const GameOutcome advantage = GameOutcome('advantage');
  static const GameOutcome disadvantage = GameOutcome('disadvantage');
  static const GameOutcome unknown = GameOutcome('unknown');


  static GameOutcome withValue(GameOutcome baseOutcome, String value) {
    return GameOutcome(baseOutcome.name, valueStr: value);
  }


  static GameOutcome withValueAndSteps(
      GameOutcome baseOutcome, String value, int? steps) {
    return GameOutcome(baseOutcome.name, valueStr: value, stepCount: steps);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is GameOutcome && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;


  String get displayString {
    final StringBuffer buffer = StringBuffer(name);

    if (valueStr != null && valueStr!.isNotEmpty) {
      buffer.write(' ($valueStr');
      if (stepCount != null && stepCount! > 0) {
        buffer.write(' in $stepCount steps');
      }
      buffer.write(')');
    } else if (stepCount != null && stepCount! > 0) {
      buffer.write(' (in $stepCount steps)');
    }

    return buffer.toString();
  }
}
