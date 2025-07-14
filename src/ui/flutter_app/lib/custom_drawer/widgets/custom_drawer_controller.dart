




part of '../../custom_drawer/custom_drawer.dart';




class CustomDrawerController extends ValueNotifier<CustomDrawerValue> {

  CustomDrawerController([CustomDrawerValue? value])
      : super(value ?? CustomDrawerValue.hidden());


  void showDrawer() => value = CustomDrawerValue.visible();


  void hideDrawer() => value = CustomDrawerValue.hidden();


  void toggleDrawer() => value.isDrawerVisible ? hideDrawer() : showDrawer();
}
