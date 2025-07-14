




part of '../mill.dart';

class SetupPositionNotifier with ChangeNotifier {
  SetupPositionNotifier();

  void updateIcons() {
    Future<void>.delayed(Duration.zero, () {
      notifyListeners();
    });
  }
}
