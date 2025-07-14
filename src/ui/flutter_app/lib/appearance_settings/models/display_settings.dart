




import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../shared/database/adapters/adapters.dart';

part 'display_settings.g.dart';


@HiveType(typeId: 9)
enum PointPaintingStyle {
  @HiveField(0)
  none,
  @HiveField(1)
  fill,
  @HiveField(2)
  stroke,
}


@HiveType(typeId: 12)
enum MovesViewLayout {
  @HiveField(0)
  large,
  @HiveField(1)
  medium,
  @HiveField(2)
  small,
  @HiveField(3)
  list,
  @HiveField(4)
  details,
}




@HiveType(typeId: 1)
@JsonSerializable()
@CopyWith(copyWithNull: true)
@immutable
class DisplaySettings {
  const DisplaySettings({
    @Deprecated("Use [locale] instead.") this.languageCode = "Default",
    this.locale,
    this.isFullScreen = false,
    @Deprecated(
        "Until other export options are implemented this setting shouldn't be used.")
    this.standardNotationEnabled = true,
    this.isPieceCountInHandShown = true,
    this.isUnplacedAndRemovedPiecesShown = true,
    this.isNotationsShown = true,
    this.isHistoryNavigationToolbarShown = true,
    this.boardBorderLineWidth = 2.0,
    this.boardInnerLineWidth = 2.0,
    @Deprecated("Use [pointPaintingStyle] instead.") this.pointStyle = 0,
    this.pointPaintingStyle = PointPaintingStyle.none,
    this.pointWidth = 10.0,
    this.pieceWidth = 0.9,
    @Deprecated("Use [fontScale] instead.") this.fontSize = 16.0,
    this.fontScale = 1.0,
    this.boardTop = kToolbarHeight,
    this.animationDuration = 1.0,
    @Deprecated("Deprecated.") this.aiResponseDelayTime = 0.0,
    this.isPositionalAdvantageIndicatorShown = true,
    this.backgroundImagePath = 'assets/images/background_image_1.jpg',
    this.isNumbersOnPiecesShown = false,
    this.isAnalysisToolbarShown = false,
    this.whitePieceImagePath = 'assets/images/white_piece_image_2.png',
    this.blackPieceImagePath = 'assets/images/black_piece_image_2.png',
    this.markedPieceImagePath = '',
    this.boardImagePath = '',
    this.vignetteEffectEnabled = false,
    this.placeEffectAnimation = 'Default',
    this.removeEffectAnimation = 'Default',
    this.isToolbarAtBottom = true,
    this.customBackgroundImagePath,
    this.customBoardImagePath,
    this.customWhitePieceImagePath,
    this.customBlackPieceImagePath,
    this.boardCornerRadius = 5.0,
    this.isAdvantageGraphShown = false,
    this.isAnnotationToolbarShown = false,
    this.movesViewLayout = MovesViewLayout.medium,
    this.swipeToRevealTheDrawer = true,
    this.isScreenshotGameInfoShown = true,
  });


  factory DisplaySettings.fromJson(Map<String, dynamic> json) =>
      _$DisplaySettingsFromJson(json);

  @Deprecated("Use [locale] instead.")
  @HiveField(0, defaultValue: "Default")
  final String languageCode;

  @Deprecated(
    "Until other export options are implemented this setting shouldn't be used",
  )
  @HiveField(1, defaultValue: true)
  final bool standardNotationEnabled;

  @HiveField(2, defaultValue: true)
  final bool isPieceCountInHandShown;

  @HiveField(3, defaultValue: true)
  final bool isNotationsShown;

  @HiveField(4, defaultValue: true)
  final bool isHistoryNavigationToolbarShown;

  @HiveField(5, defaultValue: 2.0)
  final double boardBorderLineWidth;

  @HiveField(6, defaultValue: 2.0)
  final double boardInnerLineWidth;

  @Deprecated("Use [pointPaintingStyle] instead.")
  @HiveField(7, defaultValue: 0)
  final int pointStyle;

  @HiveField(8, defaultValue: 10.0)
  final double pointWidth;

  @HiveField(9, defaultValue: 0.9)
  final double pieceWidth;

  @Deprecated("Use [fontScale] instead.")
  @HiveField(10, defaultValue: 16.0)
  final double fontSize;

  @HiveField(11, defaultValue: kToolbarHeight + 100)
  final double boardTop;

  @HiveField(12, defaultValue: 1.0)
  final double animationDuration;

  @HiveField(13, defaultValue: null)
  @JsonKey(
    fromJson: LocaleAdapter.localeFromJson,
    toJson: LocaleAdapter.localeToJson,
  )
  final Locale? locale;

  @HiveField(14, defaultValue: PointPaintingStyle.none)
  final PointPaintingStyle pointPaintingStyle;

  @HiveField(15, defaultValue: 1.0)
  final double fontScale;

  @HiveField(16, defaultValue: true)
  final bool isUnplacedAndRemovedPiecesShown;

  @HiveField(17, defaultValue: false)
  final bool isFullScreen;

  @Deprecated("Deprecated.")
  @HiveField(18, defaultValue: 0.0)
  final double aiResponseDelayTime;

  @HiveField(19, defaultValue: true)
  final bool isPositionalAdvantageIndicatorShown;

  @HiveField(20, defaultValue: 'assets/images/background_image_1.jpg')
  final String backgroundImagePath;

  @HiveField(21, defaultValue: false)
  final bool isNumbersOnPiecesShown;

  @HiveField(22, defaultValue: false)
  final bool isAnalysisToolbarShown;

  @HiveField(23, defaultValue: 'assets/images/white_piece_image_2.png')
  final String whitePieceImagePath;

  @HiveField(24, defaultValue: 'assets/images/black_piece_image_2.png')
  final String blackPieceImagePath;

  @HiveField(25, defaultValue: '')
  final String markedPieceImagePath;

  @HiveField(26, defaultValue: '')
  final String boardImagePath;

  @HiveField(27, defaultValue: true)
  final bool vignetteEffectEnabled;

  @HiveField(28, defaultValue: 'Default')
  final String placeEffectAnimation;

  @HiveField(29, defaultValue: 'Default')
  final String removeEffectAnimation;

  @HiveField(30, defaultValue: true)
  final bool isToolbarAtBottom;

  @HiveField(31, defaultValue: null)
  final String? customBackgroundImagePath;

  @HiveField(32, defaultValue: null)
  final String? customBoardImagePath;

  @HiveField(33, defaultValue: null)
  final String? customWhitePieceImagePath;

  @HiveField(34, defaultValue: null)
  final String? customBlackPieceImagePath;

  @HiveField(35, defaultValue: 5.0)
  final double boardCornerRadius;

  @HiveField(36, defaultValue: false)
  final bool isAdvantageGraphShown;

  @HiveField(37, defaultValue: false)
  final bool isAnnotationToolbarShown;

  @HiveField(38, defaultValue: MovesViewLayout.medium)
  final MovesViewLayout movesViewLayout;

  @HiveField(39, defaultValue: true)
  final bool swipeToRevealTheDrawer;

  @HiveField(40, defaultValue: true)
  final bool isScreenshotGameInfoShown;


  Map<String, dynamic> toJson() => _$DisplaySettingsToJson(this);
}
