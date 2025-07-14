




part of '../game_toolbar.dart';


















@immutable
class ToolbarItemThemeData with Diagnosticable {



  const ToolbarItemThemeData({this.style});








  final ButtonStyle? style;


  static ToolbarItemThemeData? lerp(
    ToolbarItemThemeData? a,
    ToolbarItemThemeData? b,
    double t,
  ) {
    if (a == null && b == null) {
      return null;
    }
    return ToolbarItemThemeData(
      style: ButtonStyle.lerp(a?.style, b?.style, t),
    );
  }

  @override
  int get hashCode => style.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ToolbarItemThemeData && other.style == style;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<ButtonStyle>('style', style, defaultValue: null),
    );
  }
}
