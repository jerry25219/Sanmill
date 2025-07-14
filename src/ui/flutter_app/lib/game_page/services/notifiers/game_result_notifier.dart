




part of '../mill.dart';


class GameResultNotifier extends ChangeNotifier {
  bool _hasResult = false;
  bool _isVisible = false;
  bool _force = false;
  GameOverReason? _reason;
  PieceColor? _winner;


  final EloRatingService _eloService = EloRatingService();


  bool get hasResult => _hasResult;


  bool get isVisible => _isVisible;


  bool get force => _force;


  GameOverReason? get reason => _reason;


  PieceColor? get winner => _winner;




  void showResult({bool force = false}) {
    _force = force;
    final Position position = GameController().position;


    final bool prevHasResult = _hasResult;


    _hasResult = position.hasGameResult;
    _winner = position.winner;
    _reason = position.reason;


    if (_hasResult && !prevHasResult) {
      _updateRatings();
    }


    _isVisible = _hasResult;



    notifyListeners();
  }


  void hideResult() {
    _isVisible = false;
    notifyListeners();
  }


  void clearResult() {
    _hasResult = false;
    _isVisible = false;
    _winner = null;
    _reason = null;
    notifyListeners();
  }


  void _updateRatings() {

    if (!_hasResult ||
        GameController().gameInstance.gameMode == GameMode.setupPosition) {
      return;
    }


    _eloService.updateStats(
        _winner ?? PieceColor.none, GameController().gameInstance.gameMode);
  }
}
