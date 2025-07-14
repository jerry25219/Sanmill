




part of 'adapters.dart';






class PlayerStatsAdapter extends TypeAdapter<PlayerStats> {
  @override
  final int typeId =
      kPlayerStatsTypeId;

  @override
  PlayerStats read(BinaryReader reader) {
    final String jsonStr = reader.readString();
    final Map<String, dynamic> map =
        convert.jsonDecode(jsonStr) as Map<String, dynamic>;
    return PlayerStats.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, PlayerStats obj) {
    writer.writeString(convert.jsonEncode(obj.toJson()));
  }
}



class StatsSettingsAdapter extends TypeAdapter<StatsSettings> {
  @override
  final int typeId =
      kStatsSettingsTypeId;

  @override
  StatsSettings read(BinaryReader reader) {
    final String jsonStr = reader.readString();
    final Map<String, dynamic> map =
        convert.jsonDecode(jsonStr) as Map<String, dynamic>;
    return StatsSettings.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, StatsSettings obj) {
    writer.writeString(convert.jsonEncode(obj.toJson()));
  }
}
