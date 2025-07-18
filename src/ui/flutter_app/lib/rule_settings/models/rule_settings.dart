




import 'dart:ui';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:hive_flutter/adapters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rule_settings.g.dart';

@HiveType(typeId: 4)
enum BoardFullAction {
  @HiveField(0)
  firstPlayerLose,
  @HiveField(1)
  firstAndSecondPlayerRemovePiece,
  @HiveField(2)
  secondAndFirstPlayerRemovePiece,
  @HiveField(3)
  sideToMoveRemovePiece,
  @HiveField(4)
  agreeToDraw,
}

@HiveType(typeId: 10)
enum MillFormationActionInPlacingPhase {
  @HiveField(0)
  removeOpponentsPieceFromBoard,
  @HiveField(1)
  removeOpponentsPieceFromHandThenOpponentsTurn,
  @HiveField(2)
  removeOpponentsPieceFromHandThenYourTurn,
  @HiveField(3)
  opponentRemovesOwnPiece,
  @HiveField(4)
  markAndDelayRemovingPieces,
  @HiveField(5)
  removalBasedOnMillCounts,
}

@HiveType(typeId: 8)
enum StalemateAction {
  @HiveField(0)
  endWithStalemateLoss,
  @HiveField(1)
  changeSideToMove,
  @HiveField(2)
  removeOpponentsPieceAndMakeNextMove,
  @HiveField(3)
  removeOpponentsPieceAndChangeSideToMove,
  @HiveField(4)
  endWithStalemateDraw,
}


String enumName(Object enumEntry) {
  final Map<Object, String> nameMap = <Object, String>{
    BoardFullAction.firstPlayerLose: "0-1",
    BoardFullAction.firstAndSecondPlayerRemovePiece: 'W->B',
    BoardFullAction.secondAndFirstPlayerRemovePiece: 'B->W',
    BoardFullAction.sideToMoveRemovePiece: 'X',
    BoardFullAction.agreeToDraw: '=',
    StalemateAction.endWithStalemateLoss: "0-1",
    StalemateAction.changeSideToMove: '->',
    StalemateAction.removeOpponentsPieceAndMakeNextMove: 'XM',
    StalemateAction.removeOpponentsPieceAndChangeSideToMove: 'X ->',
    StalemateAction.endWithStalemateDraw: '=',
  };

  return nameMap[enumEntry] ?? '';
}






@HiveType(typeId: 3)
@JsonSerializable()
@CopyWith()
@immutable
class RuleSettings {
  const RuleSettings({
    this.piecesCount = 9,
    this.flyPieceCount = 3,
    this.piecesAtLeastCount = 3,
    this.hasDiagonalLines = false,
    @Deprecated('Use [millFormationActionInPlacingPhase] instead')
    this.hasBannedLocations = false,
    this.mayMoveInPlacingPhase = false,
    this.isDefenderMoveFirst = false,
    this.mayRemoveMultiple = false,
    this.mayRemoveFromMillsAlways = false,
    @Deprecated('Use [millFormationActionInPlacingPhase] instead')
    this.mayOnlyRemoveUnplacedPieceInPlacingPhase = false,
    @Deprecated('Use [boardFullAction] instead')
    this.isWhiteLoseButNotDrawWhenBoardFull = true,
    this.boardFullAction = BoardFullAction.firstPlayerLose,
    @Deprecated('Use [StalemateAction] instead')
    this.isLoseButNotChangeSideWhenNoWay = true,
    this.stalemateAction = StalemateAction.endWithStalemateLoss,
    this.mayFly = true,
    this.nMoveRule = 100,
    this.endgameNMoveRule = 100,
    this.threefoldRepetitionRule = true,
    this.millFormationActionInPlacingPhase =
        MillFormationActionInPlacingPhase.removeOpponentsPieceFromBoard,
    this.restrictRepeatedMillsFormation = false,
    this.oneTimeUseMill = false,
  });


  factory RuleSettings.fromJson(Map<String, dynamic> json) =>
      _$RuleSettingsFromJson(json);


  factory RuleSettings.fromLocale(Locale? locale) {
    switch (locale?.languageCode) {
      case "af": // Afrikaans
      case "zu": // Zulu
        return const MorabarabaRuleSettings();
      case "fa": // Iran
      case "si": // Sri Lanka
        return const TwelveMensMorrisRuleSettings();
      case "ru": // Russia
        return const OneTimeMillRuleSettings();
      case "ko": // Korea
        return const ChamGonuRuleSettings();
      default:
        return const RuleSettings();
    }
  }

  @HiveField(0, defaultValue: 9)
  final int piecesCount;
  @HiveField(1, defaultValue: 3)
  final int flyPieceCount;
  @HiveField(2, defaultValue: 3)
  final int piecesAtLeastCount;
  @HiveField(3, defaultValue: false)
  final bool hasDiagonalLines;
  @Deprecated('Use [millFormationActionInPlacingPhase] instead')
  @HiveField(4, defaultValue: false)
  final bool hasBannedLocations;
  @HiveField(5, defaultValue: false)
  final bool mayMoveInPlacingPhase;
  @HiveField(6, defaultValue: false)
  final bool isDefenderMoveFirst;
  @HiveField(7, defaultValue: false)
  final bool mayRemoveMultiple;
  @HiveField(8, defaultValue: false)
  final bool mayRemoveFromMillsAlways;
  @Deprecated('Use [millFormationActionInPlacingPhase] instead')
  @HiveField(9, defaultValue: false)
  final bool mayOnlyRemoveUnplacedPieceInPlacingPhase;
  @Deprecated('Use [boardFullAction] instead')
  @HiveField(10, defaultValue: true)
  final bool isWhiteLoseButNotDrawWhenBoardFull;
  @Deprecated('Use [StalemateAction] instead')
  @HiveField(11, defaultValue: true)
  final bool isLoseButNotChangeSideWhenNoWay;
  @HiveField(12, defaultValue: true)
  final bool mayFly;
  @HiveField(13, defaultValue: 100)
  final int nMoveRule;
  @HiveField(14, defaultValue: 100)
  final int endgameNMoveRule;
  @HiveField(15, defaultValue: true)
  final bool threefoldRepetitionRule;
  @HiveField(16, defaultValue: BoardFullAction.firstPlayerLose)
  final BoardFullAction? boardFullAction;
  @HiveField(17, defaultValue: StalemateAction.endWithStalemateLoss)
  final StalemateAction? stalemateAction;
  @HiveField(18,
      defaultValue:
          MillFormationActionInPlacingPhase.removeOpponentsPieceFromBoard)
  final MillFormationActionInPlacingPhase? millFormationActionInPlacingPhase;
  @HiveField(19, defaultValue: false)
  final bool restrictRepeatedMillsFormation;
  @HiveField(20, defaultValue: false)
  final bool oneTimeUseMill;


  Map<String, dynamic> toJson() => _$RuleSettingsToJson(this);

  bool isLikelyNineMensMorris() {
    return piecesCount == 9 &&
        !hasDiagonalLines &&
        !isDefenderMoveFirst &&
        !mayMoveInPlacingPhase &&
        !mayOnlyRemoveUnplacedPieceInPlacingPhase &&
        !oneTimeUseMill;
  }

  bool isLikelyTwelveMensMorris() {
    return piecesCount == 12 &&
        hasDiagonalLines &&
        !isDefenderMoveFirst &&
        !mayMoveInPlacingPhase &&
        !mayOnlyRemoveUnplacedPieceInPlacingPhase &&
        !oneTimeUseMill;
  }

  bool isLikelyElFilja() {
    return piecesCount == 12 &&
        !hasDiagonalLines &&
        !hasBannedLocations &&
        !mayMoveInPlacingPhase &&
        !isDefenderMoveFirst &&
        !mayRemoveMultiple &&
        !mayOnlyRemoveUnplacedPieceInPlacingPhase &&
        !mayFly &&
        millFormationActionInPlacingPhase ==
            MillFormationActionInPlacingPhase.removalBasedOnMillCounts &&
        !restrictRepeatedMillsFormation &&
        !oneTimeUseMill;
  }
}


enum RuleSet {
  current,
  nineMensMorris,
  twelveMensMorris,
  morabaraba,
  dooz,
  laskerMorris,
  oneTimeMill,
  chamGonu,
  zhiQi,
  chengSanQi,
  daSanQi,
  mulMulan,
  nerenchi,
  elfilja
}




class NineMensMorrisRuleSettings extends RuleSettings {
  const NineMensMorrisRuleSettings()
      : super(
          piecesCount: 9,
          hasDiagonalLines: false,
        );
}




class TwelveMensMorrisRuleSettings extends RuleSettings {
  const TwelveMensMorrisRuleSettings()
      : super(
          piecesCount: 12,
          hasDiagonalLines: true,
        );
}





class MorabarabaRuleSettings extends RuleSettings {
  const MorabarabaRuleSettings()
      : super(
          piecesCount: 12,
          hasDiagonalLines: true,
          boardFullAction: BoardFullAction.agreeToDraw,
          endgameNMoveRule: 10,
          restrictRepeatedMillsFormation: true,
        );
}







class DoozRuleSettings extends RuleSettings {
  const DoozRuleSettings()
      : super(
          piecesCount: 12,
          hasDiagonalLines: true,
          millFormationActionInPlacingPhase: MillFormationActionInPlacingPhase
              .removeOpponentsPieceFromHandThenOpponentsTurn,
          boardFullAction: BoardFullAction.sideToMoveRemovePiece,
          mayRemoveFromMillsAlways: true,
        );
}




class LaskerMorrisSettings extends RuleSettings {
  const LaskerMorrisSettings()
      : super(
          piecesCount: 10,
          mayMoveInPlacingPhase: true,
        );
}




class OneTimeMillRuleSettings extends RuleSettings {
  const OneTimeMillRuleSettings()
      : super(
          oneTimeUseMill: true,
          mayRemoveFromMillsAlways: true,
        );
}




class ChamGonuRuleSettings extends RuleSettings {
  const ChamGonuRuleSettings()
      : super(
          piecesCount: 12,
          hasDiagonalLines: true,
          millFormationActionInPlacingPhase:
              MillFormationActionInPlacingPhase.markAndDelayRemovingPieces,
          mayFly: false,
          mayRemoveFromMillsAlways: true,
        );
}




class ZhiQiRuleSettings extends RuleSettings {
  const ZhiQiRuleSettings()
      : super(
          piecesCount: 12,
          hasDiagonalLines: true,
          millFormationActionInPlacingPhase:
              MillFormationActionInPlacingPhase.markAndDelayRemovingPieces,
          boardFullAction: BoardFullAction.firstAndSecondPlayerRemovePiece,
          mayFly: false,
          mayRemoveFromMillsAlways: true,
        );
}





class ChengSanQiRuleSettings extends RuleSettings {
  const ChengSanQiRuleSettings()
      : super(
          millFormationActionInPlacingPhase:
              MillFormationActionInPlacingPhase.markAndDelayRemovingPieces,
          mayFly: false,
        );
}





class DaSanQiRuleSettings extends RuleSettings {
  const DaSanQiRuleSettings()
      : super(
          piecesCount: 12,
          hasDiagonalLines: true,
          millFormationActionInPlacingPhase:
              MillFormationActionInPlacingPhase.markAndDelayRemovingPieces,
          boardFullAction: BoardFullAction.firstPlayerLose,
          isDefenderMoveFirst: true,
          mayFly: false,
          mayRemoveFromMillsAlways: true,
          mayRemoveMultiple: true,
        );
}







class MulMulanRuleSettings extends RuleSettings {
  const MulMulanRuleSettings()
      : super(
          hasDiagonalLines: true,
          mayFly: false,
          mayRemoveFromMillsAlways: true,
        );
}










class NerenchiRuleSettings extends RuleSettings {
  const NerenchiRuleSettings()
      : super(
          piecesCount: 12,
          hasDiagonalLines: true,
          isDefenderMoveFirst: true,
          mayRemoveFromMillsAlways: true, // TODO: Right?
        );
}




class ELFiljaRuleSettings extends RuleSettings {
  const ELFiljaRuleSettings()
      : super(
          piecesCount: 12,
          millFormationActionInPlacingPhase:
              MillFormationActionInPlacingPhase.removalBasedOnMillCounts,
          boardFullAction: BoardFullAction.firstAndSecondPlayerRemovePiece,
          mayFly: false,
          mayRemoveFromMillsAlways: true,
        );
}


const Map<RuleSet, String> ruleSetDescriptions = <RuleSet, String>{
  RuleSet.current: 'Use the current game settings.',
  RuleSet.nineMensMorris: "Classic Nine Men's Morris game.",
  RuleSet.twelveMensMorris: 'Extended version with twelve pieces per player.',
  RuleSet.morabaraba: 'Traditional South African variant, Morabaraba.',
  RuleSet.dooz: 'Persian variant called Dooz.',
  RuleSet.laskerMorris: 'A variation introduced by Emanuel Lasker.',
  RuleSet.oneTimeMill: 'A one-time mill challenge.',
  RuleSet.chamGonu: 'Cham Gonu, a traditional Korean board game.',
  RuleSet.zhiQi: 'Zhi Qi, a historical Chinese mill variant.',
  RuleSet.chengSanQi: 'Cheng San Qi, another Chinese strategic variant.',
  RuleSet.daSanQi: 'Da San Qi, another Chinese strategic variant.',
  RuleSet.mulMulan: 'Mul-Mulan, a Indonesian variation of the game.',
  RuleSet.nerenchi: 'Nerenchi, a Sri Lankan adaptation of the game.',
  RuleSet.elfilja:
      'El Filja, a variant played in Algeria and parts of Morocco.',
};


const Map<RuleSet, RuleSettings> ruleSetProperties = <RuleSet, RuleSettings>{
  RuleSet.current: RuleSettings(),
  RuleSet.nineMensMorris: NineMensMorrisRuleSettings(),
  RuleSet.twelveMensMorris: TwelveMensMorrisRuleSettings(),
  RuleSet.morabaraba: MorabarabaRuleSettings(),
  RuleSet.dooz: DoozRuleSettings(),
  RuleSet.laskerMorris: LaskerMorrisSettings(),
  RuleSet.oneTimeMill: OneTimeMillRuleSettings(),
  RuleSet.chamGonu: ChamGonuRuleSettings(),
  RuleSet.zhiQi: ZhiQiRuleSettings(),
  RuleSet.chengSanQi: ChengSanQiRuleSettings(),
  RuleSet.daSanQi: DaSanQiRuleSettings(),
  RuleSet.mulMulan: MulMulanRuleSettings(),
  RuleSet.nerenchi: NerenchiRuleSettings(),
  RuleSet.elfilja: ELFiljaRuleSettings(),
};
