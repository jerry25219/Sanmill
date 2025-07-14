




import 'package:hive_flutter/hive_flutter.dart';
import 'package:meta/meta.dart';






const int kPlayerStatsTypeId = 50;
const int kStatsSettingsTypeId = 51;










@immutable
@HiveType(typeId: kPlayerStatsTypeId)
class PlayerStats {
  const PlayerStats({
    this.rating = 1400,
    this.gamesPlayed = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.lastUpdated,

    this.whiteGamesPlayed = 0,
    this.whiteWins = 0,
    this.whiteLosses = 0,
    this.whiteDraws = 0,
    this.blackGamesPlayed = 0,
    this.blackWins = 0,
    this.blackLosses = 0,
    this.blackDraws = 0,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      rating: json['rating'] as int? ?? 1400,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastUpdated'] as int)
          : null,
      whiteGamesPlayed: json['whiteGamesPlayed'] as int? ?? 0,
      whiteWins: json['whiteWins'] as int? ?? 0,
      whiteLosses: json['whiteLosses'] as int? ?? 0,
      whiteDraws: json['whiteDraws'] as int? ?? 0,
      blackGamesPlayed: json['blackGamesPlayed'] as int? ?? 0,
      blackWins: json['blackWins'] as int? ?? 0,
      blackLosses: json['blackLosses'] as int? ?? 0,
      blackDraws: json['blackDraws'] as int? ?? 0,
    );
  }


  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'rating': rating,
      'gamesPlayed': gamesPlayed,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'lastUpdated': lastUpdated?.millisecondsSinceEpoch,
      'whiteGamesPlayed': whiteGamesPlayed,
      'whiteWins': whiteWins,
      'whiteLosses': whiteLosses,
      'whiteDraws': whiteDraws,
      'blackGamesPlayed': blackGamesPlayed,
      'blackWins': blackWins,
      'blackLosses': blackLosses,
      'blackDraws': blackDraws,
    };
  }

  @HiveField(0)
  final int rating;
  @HiveField(1)
  final int gamesPlayed;
  @HiveField(2)
  final int wins;
  @HiveField(3)
  final int losses;
  @HiveField(4)
  final int draws;
  @HiveField(5)
  final DateTime? lastUpdated;


  @HiveField(6)
  final int whiteGamesPlayed;
  @HiveField(7)
  final int whiteWins;
  @HiveField(8)
  final int whiteLosses;
  @HiveField(9)
  final int whiteDraws;
  @HiveField(10)
  final int blackGamesPlayed;
  @HiveField(11)
  final int blackWins;
  @HiveField(12)
  final int blackLosses;
  @HiveField(13)
  final int blackDraws;

  PlayerStats copyWith({
    int? rating,
    int? gamesPlayed,
    int? wins,
    int? losses,
    int? draws,
    DateTime? lastUpdated,
    int? whiteGamesPlayed,
    int? whiteWins,
    int? whiteLosses,
    int? whiteDraws,
    int? blackGamesPlayed,
    int? blackWins,
    int? blackLosses,
    int? blackDraws,
  }) {
    return PlayerStats(
      rating: rating ?? this.rating,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      whiteGamesPlayed: whiteGamesPlayed ?? this.whiteGamesPlayed,
      whiteWins: whiteWins ?? this.whiteWins,
      whiteLosses: whiteLosses ?? this.whiteLosses,
      whiteDraws: whiteDraws ?? this.whiteDraws,
      blackGamesPlayed: blackGamesPlayed ?? this.blackGamesPlayed,
      blackWins: blackWins ?? this.blackWins,
      blackLosses: blackLosses ?? this.blackLosses,
      blackDraws: blackDraws ?? this.blackDraws,
    );
  }
}


@immutable
@HiveType(typeId: kStatsSettingsTypeId)
class StatsSettings {
  const StatsSettings({
    this.isStatsEnabled = true,
    this.humanStats = const PlayerStats(),
    Map<int, PlayerStats>? aiDifficultyStatsMap,
  }) : aiDifficultyStatsMap =
            aiDifficultyStatsMap ?? const <int, PlayerStats>{};

  factory StatsSettings.fromJson(Map<String, dynamic> json) {
    final Map<int, PlayerStats> levelStatsMap = <int, PlayerStats>{};

    if (json['aiDifficultyStatsMap'] is Map) {
      (json['aiDifficultyStatsMap'] as Map<String, dynamic>)
          .forEach((String key, dynamic value) {
        final int lvl = int.tryParse(key) ?? 0;
        if (value is Map<String, dynamic>) {
          levelStatsMap[lvl] = PlayerStats.fromJson(value);
        }
      });
    }
    return StatsSettings(
      isStatsEnabled: json['isStatsEnabled'] as bool? ?? true,
      humanStats: json['humanStats'] != null
          ? PlayerStats.fromJson(json['humanStats'] as Map<String, dynamic>)
          : const PlayerStats(),
      aiDifficultyStatsMap: levelStatsMap,
    );
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = <String, dynamic>{};
    aiDifficultyStatsMap.forEach((int key, PlayerStats value) {
      jsonMap[key.toString()] = value.toJson();
    });
    return <String, dynamic>{
      'isStatsEnabled': isStatsEnabled,
      'humanStats': humanStats.toJson(),
      'aiDifficultyStatsMap': jsonMap,
    };
  }


  @HiveField(0, defaultValue: true)
  final bool isStatsEnabled;


  @HiveField(1)
  final PlayerStats humanStats;


  @HiveField(2)
  final Map<int, PlayerStats> aiDifficultyStatsMap;





  PlayerStats getAiDifficultyStats(int level) =>
      aiDifficultyStatsMap[level] ?? const PlayerStats();






  StatsSettings updateAiDifficultyStats(int level, PlayerStats stats) {
    final Map<int, PlayerStats> updated =
        Map<int, PlayerStats>.from(aiDifficultyStatsMap)..[level] = stats;
    return copyWith(aiDifficultyStatsMap: updated);
  }

  StatsSettings copyWith({
    bool? isStatsEnabled,
    PlayerStats? humanStats,
    Map<int, PlayerStats>? aiDifficultyStatsMap,
  }) {
    return StatsSettings(
      isStatsEnabled: isStatsEnabled ?? this.isStatsEnabled,
      humanStats: humanStats ?? this.humanStats,
      aiDifficultyStatsMap: aiDifficultyStatsMap ?? this.aiDifficultyStatsMap,
    );
  }
}
