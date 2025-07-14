




part of 'game_page.dart';

@visibleForTesting
class GameHeader extends StatefulWidget implements PreferredSizeWidget {
  GameHeader({super.key});

  @override
  final Size preferredSize = Size.fromHeight(
    kToolbarHeight + DB().displaySettings.boardTop + AppTheme.boardMargin,
  );

  @override
  State<GameHeader> createState() => _GameHeaderState();
}

class _GameHeaderState extends State<GameHeader> {
  ScrollNotificationObserverState? _scrollNotificationObserver;
  bool _scrolledUnder = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateScrollObserver();
    _validatePosition();
  }

  void _updateScrollObserver() {
    if (_scrollNotificationObserver != null) {
      _scrollNotificationObserver!.removeListener(_handleScrollNotification);
    }
    _scrollNotificationObserver = ScrollNotificationObserver.of(context);
    if (_scrollNotificationObserver != null) {
      _scrollNotificationObserver!.addListener(_handleScrollNotification);
    }
  }

  void _validatePosition() {
    final String? fen = GameController().position.fen;
    if (fen == null || !GameController().position.validateFen(fen)) {
      GameController().headerTipNotifier.showTip(S.of(context).invalidPosition);
    }
  }

  @override
  void dispose() {
    _removeScrollObserver();
    super.dispose();
  }

  void _removeScrollObserver() {
    if (_scrollNotificationObserver != null) {
      _scrollNotificationObserver!.removeListener(_handleScrollNotification);
      _scrollNotificationObserver = null;
    }
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final bool oldScrolledUnder = _scrolledUnder;
      _scrolledUnder = notification.depth == 0 &&
          notification.metrics.extentBefore > 0 &&
          notification.metrics.axis == Axis.vertical;
      if (_scrolledUnder != oldScrolledUnder) {
        setState(() {

        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      key: const Key('game_header_align'),
      alignment: Alignment.topCenter,
      child: BlockSemantics(
        key: const Key('game_header_block_semantics'),
        child: Center(
          key: const Key('game_header_center'),
          child: Padding(
            key: const Key('game_header_padding'),
            padding: EdgeInsets.only(top: DB().displaySettings.boardTop),
            child: Column(
              key: const Key('game_header_column'),
              children: <Widget>[
                const HeaderIcons(key: Key('header_icons')),
                _buildDivider(),
                const HeaderTip(key: Key('header_tip')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    if (DB().displaySettings.isPositionalAdvantageIndicatorShown) {
      return _buildPositionalAdvantageDivider();
    } else {
      return _buildDefaultDivider();
    }
  }

  Widget _buildPositionalAdvantageDivider() {
    int value =
        GameController().value == null ? 0 : int.parse(GameController().value!);
    const double opacity = 1;
    const int valueLimit = 100;

    if ((value == valueUnique || value == -valueUnique) ||
        GameController().gameInstance.gameMode == GameMode.humanVsHuman) {
      value = valueEachPiece * GameController().position.pieceCountDiff();
    }

    value = (value * 2).clamp(-valueLimit, valueLimit);

    final num dividerWhiteLength = valueLimit + value;
    final num dividerBlackLength = valueLimit - value;

    return Container(
      key: const Key('positional_advantage_divider'),
      height: 2,
      width: valueLimit * 2,
      margin: const EdgeInsets.only(bottom: AppTheme.boardMargin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        key: const Key('positional_advantage_row'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            key: const Key('divider_white_container'),
            height: 2,
            width: dividerWhiteLength.toDouble(),
            color:
                DB().colorSettings.whitePieceColor.withValues(alpha: opacity),
          ),
          Container(
            key: const Key('divider_black_container'),
            height: 2,
            width: dividerBlackLength.toDouble(),
            color:
                DB().colorSettings.blackPieceColor.withValues(alpha: opacity),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultDivider() {
    const double opacity = 1;
    return Container(
      key: const Key('default_divider'),
      height: 2,
      width: 180,
      margin: const EdgeInsets.only(bottom: AppTheme.boardMargin),
      decoration: BoxDecoration(
        color: (DB().colorSettings.darkBackgroundColor == Colors.white ||
                DB().colorSettings.darkBackgroundColor ==
                    const Color.fromARGB(1, 255, 255, 255))
            ? DB().colorSettings.messageColor.withValues(alpha: opacity)
            : DB()
                .colorSettings
                .boardBackgroundColor
                .withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

@visibleForTesting
class HeaderTip extends StatefulWidget {
  const HeaderTip({super.key});

  @override
  HeaderTipState createState() => HeaderTipState();
}

class HeaderTipState extends State<HeaderTip> {
  final ValueNotifier<String> _messageNotifier = ValueNotifier<String>("");


  bool _isEditing = false;


  late final FocusNode _focusNode;


  late final TextEditingController _editingController;

  @override
  void initState() {
    super.initState();
    GameController().headerTipNotifier.addListener(_showTip);


    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _editingController = TextEditingController(text: _messageNotifier.value);
  }


  void _showTip() {
    final HeaderTipNotifier headerTipNotifier =
        GameController().headerTipNotifier;

    if (headerTipNotifier.showSnackBar) {
      rootScaffoldMessengerKey.currentState!
          .showSnackBarClear(headerTipNotifier.message);
    }


    _messageNotifier.value = headerTipNotifier.message;

    if (_isEditing) {
      _editingController.text = headerTipNotifier.message;
    }
  }


  void _handleFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _finalizeEditing();
    }
  }



  void _finalizeEditing() {
    setState(() {
      _isEditing = false;
      final String rawText = _editingController.text;


      _messageNotifier.value = rawText;


      final PgnNode<ExtMove>? activeNode =
          GameController().gameRecorder.activeNode;
      if (activeNode?.data != null) {
        activeNode!.data!.comments ??= <String>[];
        activeNode.data!.comments!.clear();

        activeNode.data!.comments!.add(rawText);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      key: const Key('header_tip_value_listenable_builder'),
      valueListenable: _messageNotifier,
      builder: (BuildContext context, String currentDisplay, Widget? child) {

        final PgnNode<ExtMove>? activeNode =
            GameController().gameRecorder.activeNode;

        final String nodeComment =
            (activeNode?.data?.comments?.isNotEmpty ?? false)
                ? activeNode!.data!.comments!.join(' ')
                : "";



        final bool hasNodeComment = nodeComment.isNotEmpty;
        final String textToShow = hasNodeComment
            ? nodeComment // **Do not add braces**
            : (currentDisplay.isEmpty ? S.of(context).welcome : currentDisplay);


        final Color displayColor =
            hasNodeComment ? Colors.yellow : DB().colorSettings.messageColor;


        return Semantics(
          key: const Key('header_tip_semantics'),
          enabled: true,
          child: GestureDetector(
            onTap: () {

              if (!_isEditing) {
                setState(() {
                  _isEditing = true;


                  final String visibleRaw = textToShow;
                  if (visibleRaw != nodeComment) {

                    _editingController.text = "";
                  } else {

                    _editingController.text = nodeComment;
                  }
                });
              }
            },
            child: SizedBox(
              key: const Key('header_tip_sized_box'),
              height: 24 * DB().displaySettings.fontScale,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  if (_isEditing) {

                    return TextField(
                      key: const Key('header_tip_textfield'),
                      controller: _editingController,
                      focusNode: _focusNode,
                      style: TextStyle(
                        color: displayColor,
                        fontSize:
                            AppTheme.textScaler.scale(AppTheme.defaultFontSize),
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures()
                        ],
                      ),
                      onEditingComplete: () {
                        _finalizeEditing();

                        FocusScope.of(context).unfocus();
                      },
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                    );
                  } else {

                    final TextSpan span = TextSpan(
                      text: textToShow,
                      style: TextStyle(
                        color: displayColor,
                        fontSize:
                            AppTheme.textScaler.scale(AppTheme.defaultFontSize),
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures()
                        ],
                      ),
                    );
                    final TextPainter tp = TextPainter(
                      text: span,
                      maxLines: 1,
                      textDirection: TextDirection.ltr,
                    );
                    tp.layout(maxWidth: constraints.maxWidth);


                    final bool fits = !tp.didExceedMaxLines;

                    return Text(
                      textToShow,
                      key: const Key('header_tip_text'),
                      maxLines: 1,
                      textAlign: fits ? TextAlign.center : TextAlign.left,
                      style: TextStyle(
                        color: displayColor,
                        fontSize:
                            AppTheme.textScaler.scale(AppTheme.defaultFontSize),
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures()
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    GameController().headerTipNotifier.removeListener(_showTip);
    _focusNode.dispose();
    _editingController.dispose();
    super.dispose();
  }
}

@visibleForTesting
class HeaderIcons extends StatefulWidget {
  const HeaderIcons({super.key});

  @override
  HeaderStateIcons createState() => HeaderStateIcons();
}

class HeaderStateIcons extends State<HeaderIcons> {
  final ValueNotifier<IconData> _iconDataNotifier =
      ValueNotifier<IconData>(GameController().position.sideToMove.icon);


  final ValueNotifier<bool?> _lanHostPlaysWhiteNotifier =
      ValueNotifier<bool?>(GameController().lanHostPlaysWhite);


  final ValueNotifier<int> _player1TimeNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _player2TimeNotifier = ValueNotifier<int>(0);


  bool _isFirstMove = true;

  @override
  void initState() {
    super.initState();
    GameController().headerIconsNotifier.addListener(_updateIcons);

    _refreshLanHostPlaysWhite();


    final PlayerTimer playerTimer = PlayerTimer();
    playerTimer.remainingTimeNotifier.addListener(_updateTimers);


    _isFirstMove = GameController().gameRecorder.mainlineMoves.isEmpty;
  }

  void _updateTimers() {

    final PlayerTimer playerTimer = PlayerTimer();
    final int remainingTime = playerTimer.remainingTimeNotifier.value;


    final GameController controller = GameController();
    final bool isPlayer1Turn =
        controller.position.sideToMove == PieceColor.white;


    if (_isFirstMove && controller.gameRecorder.mainlineMoves.isEmpty) {
      return;
    }




    if (isPlayer1Turn) {

      if (controller.gameInstance.getPlayerByColor(PieceColor.white).isAi) {

        final int aiMoveTime = DB().generalSettings.moveTime;
        _player1TimeNotifier.value = aiMoveTime <= 0 ? 0 : remainingTime;
      } else {

        _player1TimeNotifier.value = remainingTime;
      }
    } else {

      if (controller.gameInstance.getPlayerByColor(PieceColor.black).isAi) {

        final int aiMoveTime = DB().generalSettings.moveTime;
        _player2TimeNotifier.value = aiMoveTime <= 0 ? 0 : remainingTime;
      } else {

        _player2TimeNotifier.value = remainingTime;
      }
    }
  }

  void _updateIcons() {
    _iconDataNotifier.value = GameController().position.sideToMove.icon;
    _refreshLanHostPlaysWhite();


    _isFirstMove = GameController().gameRecorder.mainlineMoves.isEmpty;
  }

  void _refreshLanHostPlaysWhite() {
    _lanHostPlaysWhiteNotifier.value = GameController().lanHostPlaysWhite;
  }


  (IconData, IconData) _getLanModeIcons() {
    final GameController controller = GameController();
    if (controller.gameInstance.gameMode == GameMode.humanVsLAN) {
      const IconData humanIcon = FluentIcons.person_24_filled;
      const IconData wifiIcon = FluentIcons.wifi_1_24_filled;
      final bool amIHost = controller.networkService?.isHost ?? false;

      if (amIHost) {

        return (humanIcon, wifiIcon);
      } else {

        return (wifiIcon, humanIcon);
      }
    }


    return (
      controller.gameInstance.gameMode.leftHeaderIcon,
      controller.gameInstance.gameMode.rightHeaderIcon
    );
  }


  String _formatTime(int seconds, bool isAI) {

    final int aiMoveTime = DB().generalSettings.moveTime;
    if (isAI && aiMoveTime <= 0) {
      return "--";
    }


    if (seconds <= 60) {

      return seconds.toString().padLeft(2, '0');
    }


    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }


  bool _shouldShowTimers() {
    final GameMode currentMode = GameController().gameInstance.gameMode;


    if (currentMode == GameMode.aiVsAi || currentMode == GameMode.humanVsLAN) {
      return false;
    }

    return DB().generalSettings.humanMoveTime > 0;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<IconData>(
      key: const Key('header_icons_value_listenable_builder'),
      valueListenable: _iconDataNotifier,
      builder: (BuildContext context, IconData turnIcon, Widget? child) {

        final (IconData leftIcon, IconData rightIcon) = _getLanModeIcons();


        final bool showTimers = _shouldShowTimers();


        final GameController controller = GameController();
        final bool isAILeft =
            controller.gameInstance.gameMode != GameMode.humanVsHuman &&
                controller.gameInstance.gameMode != GameMode.humanVsLAN &&
                controller.gameInstance.getPlayerByColor(PieceColor.white).isAi;
        final bool isAIRight =
            controller.gameInstance.gameMode != GameMode.humanVsHuman &&
                controller.gameInstance.gameMode != GameMode.humanVsLAN &&
                controller.gameInstance.getPlayerByColor(PieceColor.black).isAi;


        final TextDirection textDirection = Directionality.of(context);

        return IconTheme(
          key: const Key('header_icons_icon_theme'),
          data: IconThemeData(color: DB().colorSettings.messageColor),
          child: Row(
            key: const Key('header_icon_row'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              if (showTimers)
                ValueListenableBuilder<int>(
                  valueListenable: _player1TimeNotifier,
                  builder: (BuildContext context, int time, Widget? child) {
                    return Container(
                      width: 40,
                      alignment: textDirection == TextDirection.rtl
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      margin: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        _formatTime(time, isAILeft),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          color: DB().colorSettings.messageColor,
                          fontFeatures: const <ui.FontFeature>[
                            FontFeature.tabularFigures()
                          ],
                        ),
                      ),
                    );
                  },
                ),

              Icon(leftIcon, key: const Key('left_header_icon')),
              Padding(
                padding: EdgeInsets.zero, // Spacing around the center icon
                child: Icon(turnIcon, key: const Key('current_side_icon')),
              ),
              Icon(rightIcon, key: const Key('right_header_icon')),


              if (showTimers)
                ValueListenableBuilder<int>(
                  valueListenable: _player2TimeNotifier,
                  builder: (BuildContext context, int time, Widget? child) {
                    return Container(
                      width: 40,
                      alignment: textDirection == TextDirection.rtl
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      margin: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        _formatTime(time, isAIRight),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          color: DB().colorSettings.messageColor,
                          fontFeatures: const <ui.FontFeature>[
                            FontFeature.tabularFigures()
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    GameController().headerIconsNotifier.removeListener(_updateIcons);

    final PlayerTimer playerTimer = PlayerTimer();
    playerTimer.remainingTimeNotifier.removeListener(_updateTimers);
    super.dispose();
  }
}
