




part of '../mill.dart';

class HeaderTipNotifier with ChangeNotifier {
  HeaderTipNotifier();

  String _message = "";
  bool showSnackBar = false;

  String get message => _message;

  void showTip(String tip, {bool snackBar = true}) {
    logger.i("[tip] $tip");
    showSnackBar = DB().generalSettings.screenReaderSupport && snackBar;
    _message = tip;
    Future<void>.delayed(Duration.zero, () {
      notifyListeners();
    });
  }
}
