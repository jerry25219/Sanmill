




import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

import '../../appearance_settings/models/display_settings.dart';
import '../../appearance_settings/widgets/appearance_settings_page.dart';
import '../../custom_drawer/custom_drawer.dart';
import '../../game_page/services/mill.dart';
import '../../general_settings/models/general_settings.dart';
import '../../generated/intl/l10n.dart';
import '../../main.dart';
import '../../rule_settings/models/rule_settings.dart';
import '../../rule_settings/widgets/rule_settings_page.dart';
import '../../shared/config/constants.dart';
import '../../shared/database/database.dart';
import '../../shared/services/environment_config.dart';
import '../../shared/services/logger.dart';
import '../../shared/themes/app_theme.dart';
import '../../shared/themes/ui_colors.dart';
import '../../shared/utils/helpers/string_helpers/string_buffer_helper.dart';
import '../../shared/widgets/custom_spacer.dart';
import '../../shared/widgets/snackbars/scaffold_messenger.dart';
import '../pages/board_recognition_debug_page.dart';
import '../services/analysis_mode.dart';
import '../services/animation/animation_manager.dart';
import '../services/annotation/annotation_manager.dart';
import '../services/board_image_recognition.dart';
import '../services/import_export/pgn.dart';
import '../services/painters/animations/piece_effect_animation.dart';
import '../services/painters/painters.dart';
import '../services/player_timer.dart';
import '../widgets/board_recognition_debug_view.dart';
import 'challenge_confetti.dart';
import 'moves_list_page.dart';
import 'play_area.dart';
import 'toolbars/game_toolbar.dart';
import 'vignette_overlay.dart';

part 'board_semantics.dart';
part 'dialogs/game_result_alert_dialog.dart';
part 'dialogs/info_dialog.dart';
part 'dialogs/move_list_dialog.dart';
part 'game_board.dart';
part 'game_header.dart';
part 'game_page_action_sheet.dart';
part 'modals/move_options_modal.dart';



class GamePage extends StatelessWidget {
  GamePage(this.gameMode, {super.key}) {

    Position.resetScore();
  }

  final GameMode gameMode;

  @override
  Widget build(BuildContext context) {
    final GameController controller = GameController();
    controller.gameInstance.gameMode = gameMode;

    return _GamePageInner(controller: controller);
  }
}


class _GamePageInner extends StatefulWidget {
  const _GamePageInner({required this.controller});

  final GameController controller;

  @override
  State<_GamePageInner> createState() => _GamePageInnerState();
}

class _GamePageInnerState extends State<_GamePageInner> {

  final GlobalKey _gameBoardKey = GlobalKey();

  bool _isAnnotationMode = false;
  late final AnnotationManager _annotationManager;

  @override
  void initState() {
    super.initState();

    _annotationManager = widget.controller.annotationManager;


    AnalysisMode.stateNotifier.addListener(_updateAnalysisButton);
  }


  void _updateAnalysisButton() {


    setState(() {


    });
  }

  @override
  void dispose() {

    AnalysisMode.stateNotifier.removeListener(_updateAnalysisButton);
    super.dispose();
  }


  void _toggleAnnotationMode() {
    setState(() {
      if (_isAnnotationMode) {

        _annotationManager.clear();
      }
      _isAnnotationMode = !_isAnnotationMode;
      widget.controller.isAnnotationMode = _isAnnotationMode;
    });
    debugPrint('Annotation mode is now: $_isAnnotationMode');
  }

  @override
  Widget build(BuildContext context) {

    final Widget baseContent = Scaffold(
      key: const Key('game_page_scaffold'),
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {

          final double maxWidth = constraints.maxWidth;
          final double maxHeight = constraints.maxHeight;
          final double boardDimension =
              (maxHeight > 0 && maxHeight < maxWidth) ? maxHeight : maxWidth;
          final Rect gameBoardRect = Rect.fromLTWH(
            (constraints.maxWidth - boardDimension) / 2,
            0, // Top alignment.
            boardDimension,
            boardDimension,
          );

          return Stack(
            key: const Key('game_page_stack'),
            children: <Widget>[

              _buildBackground(),

              _buildGameBoard(context, widget.controller),

              Align(
                key: const Key('game_page_drawer_icon_align'),
                alignment: AlignmentDirectional.topStart,
                child: SafeArea(
                  child: CustomDrawerIcon.of(context)!.drawerIcon,
                ),
              ),

              if (GameController().gameInstance.gameMode ==
                  GameMode.humanVsHuman)
                Align(
                  key: const Key('game_page_analysis_button_align'),
                  alignment: AlignmentDirectional.topEnd,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        color: Colors.transparent,
                        child: IconButton(
                          key: const Key('game_page_analysis_button'),
                          icon: Icon(
                            AnalysisMode.isEnabled
                                ? FluentIcons.eye_off_24_regular
                                : FluentIcons.eye_24_regular,
                            color: Colors.white,
                          ),
                          tooltip: S.of(context).analysis,
                          onPressed: () => _analyzePosition(context),
                        ),
                      ),
                    ),
                  ),
                ),

              if (GameController().gameInstance.gameMode ==
                  GameMode.setupPosition)
                Align(
                  key: const Key('game_page_image_recognition_button_align'),
                  alignment: AlignmentDirectional.topEnd,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        color: Colors.transparent,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[

                            if (EnvironmentConfig.devMode)
                              IconButton(
                                key: const Key(
                                    'game_page_recognition_params_button'),
                                icon: const Icon(
                                  FluentIcons.settings_24_regular,
                                  color: Colors.white,
                                ),
                                tooltip: S.of(context).recognitionParameters,
                                onPressed: () =>
                                    _showRecognitionParamsDialog(context),
                              ),

                            IconButton(
                              key: const Key(
                                  'game_page_image_recognition_button'),
                              icon: const Icon(
                                FluentIcons.camera_24_regular,
                                color: Colors.white,
                              ),
                              tooltip: S.of(context).recognizeBoardFromImage,

                              onPressed: () =>
                                  _recognizeBoardFromImage(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              if (DB().displaySettings.vignetteEffectEnabled)
                VignetteOverlay(
                  key: const Key('game_page_vignette_overlay'),
                  gameBoardRect: gameBoardRect,
                ),
            ],
          );
        },
      ),
    );



    final Widget annotationOverlay = Offstage(
      offstage: !_isAnnotationMode,
      child: AnnotationOverlay(
        annotationManager: _annotationManager,

        gameBoardKey: _gameBoardKey,
        child: const SizedBox(width: double.infinity, height: double.infinity),
      ),
    );


    Widget toolbar = Container();
    if (DB().displaySettings.isAnnotationToolbarShown) {
      toolbar = Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: AnnotationToolbar(
          annotationManager: _annotationManager,
          isAnnotationMode: _isAnnotationMode,
          onToggleAnnotationMode: _toggleAnnotationMode,
        ),
      );
    }


    return Stack(
      children: <Widget>[
        baseContent,
        annotationOverlay,
        toolbar,
      ],
    );
  }


  Widget _buildBackground() {
    final DisplaySettings displaySettings = DB().displaySettings;

    final ImageProvider? backgroundImage =
        getBackgroundImageProvider(displaySettings);

    if (backgroundImage == null) {

      return Container(
        key: const Key('game_page_background_container'),
        color: DB().colorSettings.darkBackgroundColor,
      );
    } else {

      return Image(
        key: const Key('game_page_background_image'),
        image: backgroundImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {

          return Container(
            key: const Key('game_page_background_error_container'),
            color: DB().colorSettings.darkBackgroundColor,
          );
        },
      );
    }
  }


  Widget _buildGameBoard(BuildContext context, GameController controller) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        final bool isLandscape = orientation == Orientation.landscape;

        return Align(
          key: const Key('game_page_align_gameboard'),
          alignment: isLandscape ? Alignment.center : Alignment.topCenter,
          child: FutureBuilder<void>(
            key: const Key('game_page_future_builder'),
            future: controller.startController(),
            builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  key: Key('game_page_center_loading'),

                );
              }

              return Padding(
                key: const Key('game_page_padding'),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.boardMargin),
                child: LayoutBuilder(
                  key: const Key('game_page_inner_layout_builder'),
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double toolbarHeight =
                        _calculateToolbarHeight(context);
                    final double maxWidth = constraints.maxWidth;
                    final double maxHeight =
                        constraints.maxHeight - toolbarHeight;
                    final BoxConstraints constraint = BoxConstraints(
                      maxWidth: (maxHeight > 0 && maxHeight < maxWidth)
                          ? maxHeight
                          : maxWidth,
                    );

                    return ConstrainedBox(
                      key: const Key('game_page_constrained_box'),
                      constraints: constraint,
                      child: ValueListenableBuilder<Box<DisplaySettings>>(
                        key: const Key('game_page_value_listenable_builder'),
                        valueListenable: DB().listenDisplaySettings,
                        builder: (BuildContext context,
                            Box<DisplaySettings> box, Widget? child) {
                          final DisplaySettings displaySettings = box.get(
                            DB.displaySettingsKey,
                            defaultValue: const DisplaySettings(),
                          )!;
                          return PlayArea(
                            boardImage: getBoardImageProvider(displaySettings),

                            child: GameBoard(
                              key: _gameBoardKey,
                              boardImage:
                                  getBoardImageProvider(displaySettings),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }


  double _calculateToolbarHeight(BuildContext context) {
    double toolbarHeight =
        GamePageToolbar.height + ButtonTheme.of(context).height;
    if (DB().displaySettings.isHistoryNavigationToolbarShown) {
      toolbarHeight *= 2;
    } else if (DB().displaySettings.isAnnotationToolbarShown) {
      toolbarHeight *= 4;
    } else if (DB().displaySettings.isAnalysisToolbarShown) {
      toolbarHeight *= 5;
    }
    return toolbarHeight;
  }


  Future<void> _analyzePosition(BuildContext context) async {

    if (AnalysisMode.isEnabled) {
      AnalysisMode.disable();

      return;
    }


    final PositionAnalysisResult result =
        await GameController().engine.analyzePosition();

    if (!result.isValid) {
      return;
    }


    AnalysisMode.enable(result.possibleMoves);



    if (mounted) {
      setState(() {});
    }
  }


  void _recognizeBoardFromImage(BuildContext context) {
    try {

      _pickAndRecognizeImage(context);
    } catch (e) {

      rootScaffoldMessengerKey.currentState?.showSnackBarClear(
          S.of(context).unableToStartImageRecognition(e.toString()));
      logger.e("Error initiating board recognition: $e");
    }
  }



  void _showRecognitionParamsDialog(BuildContext context) {

    double contrastEnhancementFactor =
        BoardImageRecognitionService.contrastEnhancementFactor;
    double pieceThreshold = BoardImageRecognitionService.pieceThreshold;
    double boardColorDistanceThreshold =
        BoardImageRecognitionService.boardColorDistanceThreshold;
    double pieceColorMatchThreshold =
        BoardImageRecognitionService.pieceColorMatchThreshold;
    int whiteBrightnessThreshold =
        BoardImageRecognitionService.whiteBrightnessThreshold;
    int blackBrightnessThreshold =
        BoardImageRecognitionService.blackBrightnessThreshold;
    double blackSaturationThreshold =
        BoardImageRecognitionService.blackSaturationThreshold;
    int blackColorVarianceThreshold =
        BoardImageRecognitionService.blackColorVarianceThreshold;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {

            Widget buildParameterSlider({
              required String label,
              required double value,
              required double min,
              required double max,
              required int divisions,
              required Function(double) onChanged,
            }) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          flex: 3,
                          child: Text(
                            label,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            value.toStringAsFixed(2),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Slider(
                    value: value,
                    min: min,
                    max: max,
                    divisions: divisions,
                    onChanged: (double newValue) {
                      setState(() {
                        onChanged(newValue);
                      });
                    },
                  ),
                  const Divider(height: 8),
                ],
              );
            }

            return AlertDialog(
              title: Text(S.of(context).recognitionParameters),
              content: SingleChildScrollView(
                child: Container(
                  width: 350,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        S.of(context).adjustParamsDesc,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 16),


                      buildParameterSlider(
                        label: "Contrast Enhancement",
                        value: contrastEnhancementFactor,
                        min: 1.0,
                        max: 3.0,
                        divisions: 20,
                        onChanged: (double value) {
                          contrastEnhancementFactor = value;
                        },
                      ),


                      buildParameterSlider(
                        label: "Piece Detection Threshold",
                        value: pieceThreshold,
                        min: 0.1,
                        max: 0.5,
                        divisions: 20,
                        onChanged: (double value) {
                          pieceThreshold = value;
                        },
                      ),


                      buildParameterSlider(
                        label: "Board Color Distance",
                        value: boardColorDistanceThreshold,
                        min: 10.0,
                        max: 50.0,
                        divisions: 40,
                        onChanged: (double value) {
                          boardColorDistanceThreshold = value;
                        },
                      ),


                      buildParameterSlider(
                        label: "Piece Color Match Threshold",
                        value: pieceColorMatchThreshold,
                        min: 10.0,
                        max: 50.0,
                        divisions: 40,
                        onChanged: (double value) {
                          pieceColorMatchThreshold = value;
                        },
                      ),


                      buildParameterSlider(
                        label: "White Brightness Threshold",
                        value: whiteBrightnessThreshold.toDouble(),
                        min: 120.0,
                        max: 220.0,
                        divisions: 100,
                        onChanged: (double value) {
                          whiteBrightnessThreshold = value.round();
                        },
                      ),


                      buildParameterSlider(
                        label: "Black Brightness Threshold",
                        value: blackBrightnessThreshold.toDouble(),
                        min: 80.0,
                        max: 180.0,
                        divisions: 100,
                        onChanged: (double value) {
                          blackBrightnessThreshold = value.round();
                        },
                      ),


                      buildParameterSlider(
                        label: "Black Saturation Threshold",
                        value: blackSaturationThreshold,
                        min: 0.05,
                        max: 0.5,
                        divisions: 15,
                        onChanged: (double value) {
                          blackSaturationThreshold = value;
                        },
                      ),


                      buildParameterSlider(
                        label: "Black Color Variance",
                        value: blackColorVarianceThreshold.toDouble(),
                        min: 10.0,
                        max: 80.0,
                        divisions: 35,
                        onChanged: (double value) {
                          blackColorVarianceThreshold = value.round();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {

                    setState(() {
                      contrastEnhancementFactor = 1.8;
                      pieceThreshold = 0.25;
                      boardColorDistanceThreshold = 28.0;
                      pieceColorMatchThreshold = 30.0;
                      whiteBrightnessThreshold = 170;
                      blackBrightnessThreshold = 135;
                      blackSaturationThreshold = 0.25;
                      blackColorVarianceThreshold = 40;
                    });
                  },
                  child: Text(S.of(context).resetToDefaults),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).cancel),
                ),
                ElevatedButton(
                  onPressed: () {

                    BoardImageRecognitionService.updateParameters(
                      contrastEnhancementFactor: contrastEnhancementFactor,
                      pieceThreshold: pieceThreshold,
                      boardColorDistanceThreshold: boardColorDistanceThreshold,
                      pieceColorMatchThreshold: pieceColorMatchThreshold,
                      whiteBrightnessThreshold: whiteBrightnessThreshold,
                      blackBrightnessThreshold: blackBrightnessThreshold,
                      blackSaturationThreshold: blackSaturationThreshold,
                      blackColorVarianceThreshold: blackColorVarianceThreshold,
                    );


                    Navigator.of(context).pop();


                    rootScaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content:
                            Text(S.of(context).recognitionParametersUpdated),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text(S.of(context).saveParameters),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _pickAndRecognizeImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();


    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );


    if (pickedFile == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }


    final NavigatorState currentNavigator = Navigator.of(context);
    final ScaffoldMessengerState currentMessenger =
        ScaffoldMessenger.of(context);
    final BuildContext currentContext = context;
    final S strings = S.of(context);


    final AlertDialog dialogContent = AlertDialog(
      title: Text(strings.waiting),
      content: Row(
        children: <Widget>[
          const CircularProgressIndicator(),
          const SizedBox(width: 20),
          Expanded(
            child: Text(strings.analyzingGameBoardImage),
          ),
        ],
      ),
    );

    bool isDialogShowing = true;

    showDialog(
      context: currentContext, // Use captured context for the initial dialog
      barrierDismissible: false,
      builder: (_) => dialogContent,
    );

    try {

      final Uint8List imageData = await pickedFile.readAsBytes();
      final Map<int, PieceColor> recognizedPieces =
          await BoardImageRecognitionService.recognizeBoardFromImage(imageData);


      if (!context.mounted) {

        if (isDialogShowing) {
          try {
            currentNavigator.pop();
          } catch (_) {}
          isDialogShowing = false;
        }
        return;
      }


      if (isDialogShowing) {
        currentNavigator.pop();
        isDialogShowing = false;
      }


      if (EnvironmentConfig.devMode) {

        final Size screenSize = MediaQuery.of(currentContext).size;

        showDialog<bool>(
          context: currentContext, // Use captured context after the async gap
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {

            final NavigatorState dialogNavigator = Navigator.of(dialogContext);
            return Dialog(

              insetPadding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.height * 0.1,
              ),
              child: BoardRecognitionDebugPage.createRecognitionResultDialog(
                imageBytes: imageData,
                result: recognizedPieces,
                boardPoints: BoardImageRecognitionService.lastDetectedPoints,
                processedWidth:
                    BoardImageRecognitionService.processedImageWidth,
                processedHeight:
                    BoardImageRecognitionService.processedImageHeight,
                debugInfo: BoardImageRecognitionService.lastDebugInfo,
                context: dialogContext,
                onResult: (bool shouldApply) {

                  dialogNavigator.pop(shouldApply);


                  if (!context.mounted) {
                    return;
                  }


                  if (shouldApply) {

                    _applyRecognizedBoardState(
                        recognizedPieces, currentMessenger, context);
                  }
                },
              ),
            );
          },
        );
      } else {

        if (recognizedPieces.isNotEmpty) {

          _applyRecognizedBoardState(
              recognizedPieces, currentMessenger, context);
        } else {

          currentMessenger.showSnackBar(
            SnackBar(
                content: Text(
                    strings.noPiecesWereRecognizedInTheImagePleaseTryAgain)),
          );
        }
      }
    } catch (e) {

      if (isDialogShowing) {
        try {
          currentNavigator.pop();
        } catch (_) {}
        isDialogShowing = false;
      }


      if (!context.mounted) {
        return;
      }


      currentMessenger.showSnackBar(SnackBar(
          content: Text(strings.imageRecognitionFailed(e.toString()))));
      logger.e("Error during board recognition: $e");
    }
  }


  void _applyRecognizedBoardState(Map<int, PieceColor> recognizedPieces,
      ScaffoldMessengerState? messenger, BuildContext context) {
    final S strings = S.of(context);

    try {

      final String? fen =
          BoardRecognitionDebugView.generateTempFenString(recognizedPieces);

      if (fen == null) {
        messenger
            ?.showSnackBarClear(strings.failedToGenerateFenFromRecognizedBoard);
        return;
      }


      GameController().position.reset();


      if (GameController().position.setFen(fen)) {


        logger.i("Successfully applied FEN from image recognition: $fen");


        GameController().setupPositionNotifier.updateIcons();
        GameController().boardSemanticsNotifier.updateSemantics();


        final int whiteCount =
            GameController().position.countPieceOnBoard(PieceColor.white);
        final int blackCount =
            GameController().position.countPieceOnBoard(PieceColor.black);


        final String message = strings.appliedPositionDetails(
          whiteCount,
          blackCount,
        );
        final String next =
            GameController().position.sideToMove == PieceColor.white
                ? strings.whiteSMove
                : strings.blackSMove;
        final String fenCopiedMsg = strings.fenCopiedToClipboard;


        GameController().gameRecorder =
            GameRecorder(lastPositionWithRemove: fen, setupPosition: fen);


        Clipboard.setData(ClipboardData(text: fen));


        messenger?.showSnackBarClear('$message, $next $fenCopiedMsg');
      } else {

        messenger
            ?.showSnackBarClear(strings.failedToApplyRecognizedBoardPosition);
        logger.e("Failed to set FEN: $fen");
      }
    } catch (e) {
      logger.e("Error applying recognized board state: $e");
      messenger?.showSnackBarClear(strings.recognitionFailed(e.toString()));
    }
  }
}
