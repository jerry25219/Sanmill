




part of '../game_toolbar.dart';

class GamePageToolbar extends StatelessWidget {
  const GamePageToolbar({
    super.key,
    required this.children,
    this.backgroundColor,
    this.itemColor,
  });

  final List<Widget> children;
  final Color? backgroundColor;
  final Color? itemColor;

  static const EdgeInsets _padding = EdgeInsets.symmetric(vertical: 2);
  static const EdgeInsets _margin = EdgeInsets.symmetric(vertical: 0.5);



  static double get height => (_padding.vertical + _margin.vertical) * 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('game_page_toolbar_container'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: backgroundColor,
      ),
      margin: _margin,
      padding: _padding,
      child: ToolbarItemTheme(
        key: const Key('toolbar_item_theme'),
        data: ToolbarItemThemeData(
          style: ToolbarItem.styleFrom(primary: itemColor),
        ),
        child: Directionality(
          key: const Key('toolbar_directionality'),
          textDirection: TextDirection.ltr,
          child: Row(
            key: const Key('toolbar_row'),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          ),
        ),
      ),
    );
  }
}
