




part of '../mill.dart';

class HeaderIconsNotifier with ChangeNotifier {
  HeaderIconsNotifier();

  void showIcons() {
    Future<void>.delayed(Duration.zero, () {
      Future<void>.delayed(Duration.zero, () {
        notifyListeners();
      });
    });
  }
}
