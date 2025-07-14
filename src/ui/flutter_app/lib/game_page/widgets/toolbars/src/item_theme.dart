




part of '../game_toolbar.dart';










class ToolbarItemTheme extends InheritedTheme {



  const ToolbarItemTheme({
    super.key,
    required this.data,
    required super.child,
  });


  final ToolbarItemThemeData data;











  static ToolbarItemThemeData of(BuildContext context) {
    final ToolbarItemTheme? buttonTheme =
        context.dependOnInheritedWidgetOfExactType<ToolbarItemTheme>();
    return buttonTheme?.data ?? const ToolbarItemThemeData();
  }

  @override
  Widget wrap(BuildContext context, Widget child) => ToolbarItemTheme(
        key: const Key('toolbar_item_theme_wrap'),
        data: data,
        child: child,
      );

  @override
  bool updateShouldNotify(ToolbarItemTheme oldWidget) => data != oldWidget.data;
}
