




part of '../../custom_drawer/custom_drawer.dart';




class CustomDrawerIcon extends InheritedWidget {
  const CustomDrawerIcon({
    super.key,
    required this.drawerIcon,
    required super.child,
  });

  final Widget drawerIcon;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  static CustomDrawerIcon? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CustomDrawerIcon>();
}
