




part of 'adapters.dart';





class LocaleAdapter extends TypeAdapter<Locale?> {
  @override
  final int typeId = 7;

  @override
  Locale read(BinaryReader reader) {
    final String value = reader.readString();
    return Locale(value);
  }

  @override
  void write(BinaryWriter writer, Locale? obj) {
    if (obj != null) {
      writer.writeString(obj.languageCode);
    }
  }

  static String? localeToJson(Locale? locale) => locale?.languageCode;
  static Locale? localeFromJson(String? value) {
    if (value != null && value != "Default") {
      return Locale(value);
    }
    return null;
  }
}
