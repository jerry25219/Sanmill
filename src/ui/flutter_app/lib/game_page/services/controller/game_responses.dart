




part of '../mill.dart';


abstract class GameResponse {}

class GameResponseOK implements GameResponse {
  const GameResponseOK();
}

class IllegalAction implements GameResponse {
  const IllegalAction();
}

class IllegalPhase implements GameResponse {
  const IllegalPhase();
}


abstract class SelectResponse implements GameResponse {}

class CanOnlyMoveToAdjacentEmptyPoints implements SelectResponse {
  const CanOnlyMoveToAdjacentEmptyPoints();
}

class NoPieceSelected implements SelectResponse {
  const NoPieceSelected();
}

class SelectOurPieceToMove implements SelectResponse {
  const SelectOurPieceToMove();
}


abstract class RemoveResponse implements GameResponse {}

class NoPieceToRemove implements RemoveResponse {
  const NoPieceToRemove();
}

class CanNotRemoveSelf implements RemoveResponse {
  const CanNotRemoveSelf();
}

class ShouldRemoveSelf implements RemoveResponse {
  const ShouldRemoveSelf();
}

class CanNotRemoveMill implements RemoveResponse {
  const CanNotRemoveMill();
}

class CanNotRemoveNonadjacent implements RemoveResponse {
  const CanNotRemoveNonadjacent();
}


abstract class EngineResponse {}

class EngineResponseOK implements EngineResponse {
  const EngineResponseOK();
}

class EngineResponseHumanOK implements EngineResponse {
  const EngineResponseHumanOK();
}

class EngineResponseSkip implements EngineResponse {
  const EngineResponseSkip();
}

class EngineNoBestMove implements EngineResponse {
  const EngineNoBestMove();
}

class EngineGameIsOver implements EngineResponse {
  const EngineGameIsOver();
}

class EngineTimeOut implements EngineResponse {
  const EngineTimeOut();
}

class EngineDummy implements EngineResponse {
  const EngineDummy();
}


abstract class HistoryResponse {
  static const String tag = "[_HistoryResponse]";
}

class HistoryOK implements HistoryResponse {
  const HistoryOK();

  @override
  String toString() {
    return "${HistoryResponse.tag} History is OK.";
  }
}

class HistoryAbort implements HistoryResponse {
  const HistoryAbort();

  @override
  String toString() {
    return "${HistoryResponse.tag} History aborted.";
  }
}

class HistoryRule implements HistoryResponse {
  const HistoryRule();

  @override
  String toString() {
    return "${HistoryResponse.tag} Moves and rules do not match.";
  }
}

class HistoryRange implements HistoryResponse {
  const HistoryRange();

  @override
  String toString() {
    return "${HistoryResponse.tag} Current is equal to moveIndex.";
  }
}
