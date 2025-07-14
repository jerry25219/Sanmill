




part of 'adapters.dart';





class ColorAdapter extends TypeAdapter<Color> {
  @override
  final int typeId = 6;

  @override
  Color read(BinaryReader reader) {
    final int value = reader.readInt();
    return Color(value);
  }

  @override
  void write(BinaryWriter writer, Color obj) {
    final int alpha = Color.getAlphaFromOpacity(obj.a) & 0xFF;
    final int red = (obj.r * 255).round() & 0xFF;
    final int green = (obj.g * 255).round() & 0xFF;
    final int blue = (obj.b * 255).round() & 0xFF;

    final int combinedValue = (alpha << 24) | (red << 16) | (green << 8) | blue;

    writer.writeInt(combinedValue);
  }

  static int colorToJson(Color color) {
    final int alpha = Color.getAlphaFromOpacity(color.a) & 0xFF;
    final int red = (color.r * 255).round() & 0xFF;
    final int green = (color.g * 255).round() & 0xFF;
    final int blue = (color.b * 255).round() & 0xFF;

    return (alpha << 24) | (red << 16) | (green << 8) | blue;
  }

  static Color colorFromJson(int value) {
    return Color(value);
  }
}
