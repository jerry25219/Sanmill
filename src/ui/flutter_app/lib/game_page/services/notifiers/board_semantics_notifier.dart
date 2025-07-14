




part of '../mill.dart';

class BoardSemanticsNotifier with ChangeNotifier {
  BoardSemanticsNotifier();

  void updateSemantics() {
    if (DB().generalSettings.screenReaderSupport) {
      notifyListeners();
    }
  }
}
