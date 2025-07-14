




part of '../../custom_drawer/custom_drawer.dart';




class CustomDrawerValue {
  const CustomDrawerValue({
    this.isDrawerVisible = false,
  });


  factory CustomDrawerValue.hidden() => const CustomDrawerValue();


  factory CustomDrawerValue.visible() => const CustomDrawerValue(
        isDrawerVisible: true,
      );


  final bool isDrawerVisible;
}
