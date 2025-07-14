




import '../../../game_page/services/mill.dart';
import '../../general_settings/models/general_settings.dart';
import '../../shared/database/database.dart';
import '../../shared/services/environment_config.dart';
import '../../shared/services/logger.dart';
import '../../statistics/model/stats_settings.dart';

part 'elo_rating_calculation.dart';


enum HumanOutcome {
  playerWin, // Human player wins
  opponentWin, // Opponent (AI or LAN) wins
  draw, // Game ends in a draw
}


class EloRatingService {

  factory EloRatingService() => _instance;
  EloRatingService._();
  static const String _logTag = "[EloService]";
  static final EloRatingService _instance = EloRatingService._();


  static int getFixedAiEloRating(int level) {
    int ret;


    switch (level) {
      case 1:
        ret = 300;
      case 2:
        ret = 500;
      case 3:
        ret = 600;
      case 4:
        ret = 700;
      case 5:
        ret = 800;
      case 6:
        ret = 900;
      case 7:
        ret =
            1000;
      case 8:
        ret =
            1100;
      case 9:
        ret = 1200;
      case 10:
        ret = 1300;
      case 11:
        ret =
            1400;
      case 12:
        ret = 1500;
      case 13:
        ret = 1600;
      case 14:
        ret = 1700;
      case 15:
        ret = 1800;
      case 16:
        ret =
            1900;
      case 17:
        ret =
            2000;
      case 18:
        ret = 2100;
      case 19:
        ret = 2200;
      case 20:
        ret = 2300;
      case 21:
        ret = 2350;
      case 22:
        ret = 2400;
      case 23:
        ret = 2450;
      case 24:
        ret = 2500;
      case 25:
        ret = 2550;
      case 26:
        ret =
            2600;
      case 27:
        ret = 2650;
      case 28:
        ret = 2700;
      case 29:
        ret = 2750;
      case 30:
        ret = 2800;
      default:
        ret = 1400;
    }




    if (DB().ruleSettings.isLikelyNineMensMorris() &&
        DB().generalSettings.aiMovesFirst) {
      ret -= 100;
    }


    if (DB().ruleSettings.isLikelyTwelveMensMorris() &&
        DB().generalSettings.aiMovesFirst) {
      ret += 200;
    }


    if (DB().generalSettings.moveTime != 1 &&
        DB().generalSettings.skillLevel >= 15) {
      final int moveTime = DB().generalSettings.moveTime;
      if (moveTime == 0) {
        ret += 100;
      } else if (moveTime >= 2 && moveTime <= 5) {
        ret += 25;
      } else if (moveTime >= 6 && moveTime <= 10) {
        ret += 50;
      } else if (moveTime >= 10 && moveTime <= 60) {
        ret += 75;
      }
    }


    if (!DB().generalSettings.shufflingEnabled) {
      ret -= 100;
    }


    if (!DB().generalSettings.considerMobility) {
      ret -= 50;
    }


    if (DB().generalSettings.focusOnBlockingPaths) {
      ret -= 100;
    }



    if (DB().generalSettings.usePerfectDatabase) {
      ret +=
          100;
    }


    if (DB().generalSettings.humanMoveTime != 0) {
      final int humanMoveTime = DB().generalSettings.humanMoveTime;
      if (humanMoveTime >= 1 && humanMoveTime <= 5) {
        ret += 100;
      } else if (humanMoveTime >= 6 && humanMoveTime <= 10) {
        ret += 50;
      } else if (humanMoveTime >= 11 && humanMoveTime <= 30) {
        ret += 20;
      } else if (humanMoveTime >= 31 && humanMoveTime <= 60) {
        ret += 10;
      }
    }


    if (DB().generalSettings.aiIsLazy) {
      ret = ret ~/ 2;
    }


    if (DB().generalSettings.searchAlgorithm == SearchAlgorithm.mcts &&
        !DB().generalSettings.usePerfectDatabase) {
      ret = (ret * 0.2)
          .round();
    }


    if (DB().generalSettings.searchAlgorithm == SearchAlgorithm.random &&
        !DB().generalSettings.usePerfectDatabase) {
      ret = 100;
    }


    if (ret < 100) {
      ret = 100;
    }

    return ret;
  }


  PlayerStats getAiDifficultyStats(int level) {

    final StatsSettings settings = DB().statsSettings;
    final PlayerStats aiDifficultyStats = settings.getAiDifficultyStats(level);


    return PlayerStats(
      rating: getFixedAiEloRating(level),
      gamesPlayed: aiDifficultyStats.gamesPlayed,
      wins: aiDifficultyStats.wins,
      losses: aiDifficultyStats.losses,
      draws: aiDifficultyStats.draws,
      lastUpdated: aiDifficultyStats.lastUpdated,
      whiteGamesPlayed: aiDifficultyStats.whiteGamesPlayed,
      whiteWins: aiDifficultyStats.whiteWins,
      whiteLosses: aiDifficultyStats.whiteLosses,
      whiteDraws: aiDifficultyStats.whiteDraws,
      blackGamesPlayed: aiDifficultyStats.blackGamesPlayed,
      blackWins: aiDifficultyStats.blackWins,
      blackLosses: aiDifficultyStats.blackLosses,
      blackDraws: aiDifficultyStats.blackDraws,
    );
  }


  void updateStats(PieceColor winnerColor, GameMode gameMode) {
    try {
      final StatsSettings settings = DB().statsSettings;


      if (!settings.isStatsEnabled) {
        logger.i("$_logTag Stats disabled, not updating");
        return;
      }

      if (!EnvironmentConfig.devMode && GameController().disableStats == true) {
        logger.i(
            "$_logTag Stats disabled because of taking-back etc., not updating");
        return;
      }

      switch (gameMode) {
        case GameMode.humanVsAi:
          _updateHumanVsAiStats(winnerColor, settings);
          break;
        case GameMode.humanVsHuman:

          logger.i("$_logTag Human vs Human game, not updating stats");
          break;
        case GameMode.humanVsLAN:

          logger.i("$_logTag Human vs LAN game, not updating stats");
          break;
        case GameMode.humanVsCloud:

          _updateHumanVsAiStats(winnerColor, settings);
          break;
        case GameMode.aiVsAi:

          logger.i("$_logTag AI vs AI game, not updating stats");
          break;
        case GameMode.setupPosition:

          logger.i("$_logTag Setup position mode, not updating stats");
          break;
        case GameMode.testViaLAN:

          logger.i("$_logTag Test via LAN game, not updating stats");
          break;
      }
    } catch (e) {
      logger.e("$_logTag Error updating stats: $e");
    }
  }


  void _updateHumanVsAiStats(PieceColor winnerColor, StatsSettings settings) {

    final int aiDifficulty = DB().generalSettings.skillLevel;


    final PlayerStats humanStats = settings.humanStats;


    final PlayerStats aiDifficultyStats = getAiDifficultyStats(aiDifficulty);


    final bool isAiWhite = DB().generalSettings.aiMovesFirst;


    HumanOutcome outcome;
    if (winnerColor == PieceColor.draw || winnerColor == PieceColor.none) {
      outcome = HumanOutcome.draw;
    } else if ((winnerColor == PieceColor.white && !isAiWhite) ||
        (winnerColor == PieceColor.black && isAiWhite)) {

      outcome = HumanOutcome.playerWin;
    } else {

      outcome = HumanOutcome.opponentWin;
    }


    double score;
    switch (outcome) {
      case HumanOutcome.playerWin:
        score = 1.0;
        break;
      case HumanOutcome.opponentWin:
        score = 0.0;
        break;
      case HumanOutcome.draw:
        score = 0.5;
        break;
    }


    final List<int> aiRatingsList = <int>[aiDifficultyStats.rating];
    final List<double> resultsList = <double>[score];


    final int gamesAfterThis = humanStats.gamesPlayed + 1;
    int newHumanRating;





    if (gamesAfterThis < 5) {

      newHumanRating = _calculateInitialRating(aiRatingsList, resultsList);
    } else {

      newHumanRating = _updateRating(
        humanStats.rating,
        aiRatingsList,
        resultsList,
        gamesAfterThis,
      );
    }





    int humanWhiteGamesPlayed = humanStats.whiteGamesPlayed;
    int humanWhiteWins = humanStats.whiteWins;
    int humanWhiteLosses = humanStats.whiteLosses;
    int humanWhiteDraws = humanStats.whiteDraws;
    int humanBlackGamesPlayed = humanStats.blackGamesPlayed;
    int humanBlackWins = humanStats.blackWins;
    int humanBlackLosses = humanStats.blackLosses;
    int humanBlackDraws = humanStats.blackDraws;


    int aiWhiteGamesPlayed = aiDifficultyStats.whiteGamesPlayed;
    int aiWhiteWins = aiDifficultyStats.whiteWins;
    int aiWhiteLosses = aiDifficultyStats.whiteLosses;
    int aiWhiteDraws = aiDifficultyStats.whiteDraws;
    int aiBlackGamesPlayed = aiDifficultyStats.blackGamesPlayed;
    int aiBlackWins = aiDifficultyStats.blackWins;
    int aiBlackLosses = aiDifficultyStats.blackLosses;
    int aiBlackDraws = aiDifficultyStats.blackDraws;


    if (isAiWhite) {

      aiWhiteGamesPlayed++;
      humanBlackGamesPlayed++;

      if (outcome == HumanOutcome.playerWin) {

        aiWhiteLosses++;
        humanBlackWins++;
      } else if (outcome == HumanOutcome.opponentWin) {

        aiWhiteWins++;
        humanBlackLosses++;
      } else {

        aiWhiteDraws++;
        humanBlackDraws++;
      }
    } else {

      humanWhiteGamesPlayed++;
      aiBlackGamesPlayed++;

      if (outcome == HumanOutcome.playerWin) {

        humanWhiteWins++;
        aiBlackLosses++;
      } else if (outcome == HumanOutcome.opponentWin) {

        humanWhiteLosses++;
        aiBlackWins++;
      } else {

        humanWhiteDraws++;
        aiBlackDraws++;
      }
    }


    final PlayerStats newHumanStatsObject = humanStats.copyWith(
      rating: newHumanRating,
      gamesPlayed: humanStats.gamesPlayed + 1,
      wins: outcome == HumanOutcome.playerWin
          ? humanStats.wins + 1
          : humanStats.wins,
      losses: outcome == HumanOutcome.opponentWin
          ? humanStats.losses + 1
          : humanStats.losses,
      draws: outcome == HumanOutcome.draw
          ? humanStats.draws + 1
          : humanStats.draws,
      lastUpdated: DateTime.now(),
      whiteGamesPlayed: humanWhiteGamesPlayed,
      whiteWins: humanWhiteWins,
      whiteLosses: humanWhiteLosses,
      whiteDraws: humanWhiteDraws,
      blackGamesPlayed: humanBlackGamesPlayed,
      blackWins: humanBlackWins,
      blackLosses: humanBlackLosses,
      blackDraws: humanBlackDraws,
    );


    final PlayerStats newAiDifficultyStatsObject =
        settings.getAiDifficultyStats(aiDifficulty).copyWith(

              gamesPlayed: aiDifficultyStats.gamesPlayed + 1,
              wins: outcome == HumanOutcome.opponentWin
                  ? aiDifficultyStats.wins + 1
                  : aiDifficultyStats.wins,
              losses: outcome == HumanOutcome.playerWin
                  ? aiDifficultyStats.losses + 1
                  : aiDifficultyStats.losses,
              draws: outcome == HumanOutcome.draw
                  ? aiDifficultyStats.draws + 1
                  : aiDifficultyStats.draws,
              lastUpdated: DateTime.now(),
              whiteGamesPlayed: aiWhiteGamesPlayed,
              whiteWins: aiWhiteWins,
              whiteLosses: aiWhiteLosses,
              whiteDraws: aiWhiteDraws,
              blackGamesPlayed: aiBlackGamesPlayed,
              blackWins: aiBlackWins,
              blackLosses: aiBlackLosses,
              blackDraws: aiBlackDraws,
            );


    final StatsSettings newSettings = settings.copyWith(
      humanStats: newHumanStatsObject,
    );


    DB().statsSettings = newSettings.updateAiDifficultyStats(
        aiDifficulty, newAiDifficultyStatsObject);

    logger.i(
        "$_logTag Updated Human rating: ${humanStats.rating} -> $newHumanRating");
    logger.i(
        "$_logTag AI Level $aiDifficulty rating: ${aiDifficultyStats.rating} (fixed)");
  }
}
