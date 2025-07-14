




part of '../game_page.dart';


class TempMove {
  String moveText = "";
  final List<String> nags = <String>[];
  final List<String> comments = <String>[];
  bool hasX = false;
}

class MoveListDialog extends StatelessWidget {
  const MoveListDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController controller = GameController();
    String? fen;
    List<String> mergedMoves = getMergedMoves(controller);
    if (mergedMoves.isNotEmpty) {

      if (mergedMoves[0].isNotEmpty) {
        final String firstMove = mergedMoves[0];
        if (firstMove.startsWith('[')) {
          fen = firstMove;
          mergedMoves = mergedMoves.sublist(1);
        }
      }
    }
    final int movesCount = (mergedMoves.length + 1) ~/ 2;
    final int fenHeight = fen == null ? 2 : 14;

    final bool globalHasComment =
        mergedMoves.any((String move) => move.contains('{'));

    if (DB().generalSettings.screenReaderSupport) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (rootScaffoldMessengerKey.currentState != null) {
          rootScaffoldMessengerKey.currentState!.clearSnackBars();
        }
      });
    }


    final ValueNotifier<int?> selectedIndex = ValueNotifier<int?>(null);

    return GamePageActionSheet(
      child: AlertDialog(
        key: const Key('move_list_dialog_alert_dialog'),
        backgroundColor: UIColors.semiTransparentBlack,
        title: Text(
          S.of(context).moveList,
          key: const Key('move_list_dialog_title_text'),
          style: _getTitleTextStyle(context),
        ),
        content: SizedBox(
          key: const Key('move_list_dialog_content_sized_box'),
          width: calculateNCharWidth(context, 32),
          height:
              calculateNCharWidth(context, mergedMoves.length * 2 + fenHeight),
          child: ListView(
            key: const Key('move_list_dialog_list_view'),
            physics: const AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              if (fen != null)
                InkWell(
                  key: const Key('move_list_dialog_fen_inkwell'),
                  onTap: () => _importGame(context, mergedMoves, fen, -1),
                  child: Padding(
                    key: const Key('move_list_dialog_fen_padding'),
                    padding: const EdgeInsets.only(right: 24.0),
                    child: Text.rich(
                      TextSpan(
                        text: "$fen\r\n",
                        style: _getTitleTextStyle(context),
                      ),
                      key: const Key('move_list_dialog_fen_text'),
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                ),
              ...List<Widget>.generate(
                movesCount,
                (int index) => _buildMoveListItem(
                  context,
                  mergedMoves,
                  fen,
                  index,
                  selectedIndex,
                  globalHasComment,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Row(
            key: const Key('move_list_dialog_actions_row'),
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: TextButton(
                  key: const Key('move_list_dialog_copy_button'),
                  child: Text(
                    S.of(context).copy,
                    style: _getButtonTextStyle(context),
                  ),
                  onPressed: () {
                    GameController.export(context);
                    if (DB().displaySettings.isHistoryNavigationToolbarShown) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              Expanded(
                child: TextButton(
                  key: const Key('move_list_dialog_paste_button'),
                  child: Text(
                    S.of(context).paste,
                    style: _getButtonTextStyle(context),
                  ),
                  onPressed: () {
                    GameController.import(context);
                    if (DB().displaySettings.isHistoryNavigationToolbarShown) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              Expanded(
                child: TextButton(
                  key: const Key('move_list_dialog_cancel_button'),
                  child: Text(
                    S.of(context).cancel,
                    style: _getButtonTextStyle(context),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    if (DB().displaySettings.isHistoryNavigationToolbarShown) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  TextStyle _getMoveTextStyle(BuildContext context, bool hasComment) {
    final TextStyle baseStyle = _getTitleTextStyle(context);
    if (hasComment) {
      return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 0.8);
    }
    return baseStyle;
  }

  Widget _buildMoveListItem(
    BuildContext context,
    List<String> mergedMoves,
    String? fen,
    int index,
    ValueNotifier<int?> selectedIndex,
    bool globalHasComment,
  ) {

    final int whiteIndex = index * 2;
    final int blackIndex = whiteIndex + 1;


    if (whiteIndex >= mergedMoves.length) {
      return const SizedBox.shrink();
    }

    final String whiteMove = mergedMoves[whiteIndex];

    final String? blackMove =
        (blackIndex < mergedMoves.length) ? mergedMoves[blackIndex] : null;


    if (whiteMove.isEmpty && (blackMove?.isEmpty ?? true)) {
      return const SizedBox.shrink();
    }


    final bool isParenWhite = whiteMove == '(' || whiteMove == ')';
    final bool isParenBlack = blackMove == '(' || blackMove == ')';





    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(
        '${index + 1}.',
        style: _getTitleTextStyle(context),
      ),
      title: Row(
        children: <Widget>[

          Expanded(
            child: ValueListenableBuilder<int?>(
              valueListenable: selectedIndex,
              builder: (BuildContext context, int? value, Widget? child) {
                final bool isSelected = (value == whiteIndex);
                return InkWell(
                  onTap: () {
                    selectedIndex.value = whiteIndex;
                    _importGame(context, mergedMoves, fen, whiteIndex);
                  },
                  child: Container(
                    color: isSelected
                        ? AppTheme.gamePageActionSheetTextBackgroundColor
                        : null,
                    padding: const EdgeInsets.only(right: 24.0),
                    child: Text(
                      whiteMove,
                      style:
                          _getMoveTextStyle(context, globalHasComment).copyWith(
                        color: AppTheme.gamePageActionSheetTextColor,
                        fontStyle:
                            isParenWhite ? FontStyle.italic : FontStyle.normal,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                );
              },
            ),
          ),


          if (blackMove != null)
            Expanded(
              child: ValueListenableBuilder<int?>(
                valueListenable: selectedIndex,
                builder: (BuildContext context, int? value, Widget? child) {
                  final bool isSelected = (value == blackIndex);
                  return InkWell(
                    onTap: () {
                      selectedIndex.value = blackIndex;
                      _importGame(context, mergedMoves, fen, blackIndex);
                    },
                    child: Container(
                      color: isSelected
                          ? AppTheme.gamePageActionSheetTextBackgroundColor
                          : null,
                      padding: const EdgeInsets.only(right: 24.0),
                      child: Text(
                        blackMove,
                        style: _getMoveTextStyle(context, globalHasComment)
                            .copyWith(
                          color: AppTheme.gamePageActionSheetTextColor,
                          fontStyle: isParenBlack
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _importGame(BuildContext context, List<String> mergedMoves,
      String? fen, int clickedIndex) async {
    String ml = mergedMoves.sublist(0, clickedIndex + 1).join(' ');
    if (fen != null) {
      ml = '$fen $ml';
    }
    final SnackBar snackBar = SnackBar(
      key: const Key('move_list_dialog_import_snack_bar'),
      content: Text(ml),
      duration: const Duration(seconds: 2),
    );
    if (!ScaffoldMessenger.of(context).mounted) {
      return;
    }
    if (EnvironmentConfig.devMode) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    try {
      ImportService.import(ml);
    } catch (exception) {
      if (!context.mounted) {
        return;
      }
      final String tip = S.of(context).cannotImport(ml);
      GameController().headerTipNotifier.showTip(tip);
      Navigator.pop(context);
      return;
    }
    if (!context.mounted) {
      return;
    }
    await HistoryNavigator.takeBackAll(context, pop: false);
    if (!context.mounted) {
      return;
    }
    if (await HistoryNavigator.stepForwardAll(context, pop: false) ==
        const HistoryOK()) {
      if (!context.mounted) {
        return;
      }
    } else {
      if (!context.mounted) {
        return;
      }
      final String tip =
          S.of(context).cannotImport(HistoryNavigator.importFailedStr);
      GameController().headerTipNotifier.showTip(tip);
      HistoryNavigator.importFailedStr = "";
    }
  }

  TextStyle _getTitleTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
          color: AppTheme.gamePageActionSheetTextColor,
          fontSize: AppTheme.textScaler.scale(AppTheme.largeFontSize),
          fontFamily: getMonospaceTitleTextStyle(context).fontFamily,
        );
  }

  TextStyle _getButtonTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
          color: AppTheme.gamePageActionSheetTextColor,
          fontSize: AppTheme.textScaler.scale(AppTheme.defaultFontSize),
        );
  }
}





List<String> lexTokens(String moveHistoryText) {
  final List<String> tokens = <String>[];
  int i = 0;

  while (i < moveHistoryText.length) {
    final String c = moveHistoryText[i];


    if (c == '{') {
      final int start = i;
      i++;
      int braceLevel = 1;
      while (i < moveHistoryText.length && braceLevel > 0) {
        if (moveHistoryText[i] == '{') {
          braceLevel++;
        } else if (moveHistoryText[i] == '}') {
          braceLevel--;
        }
        i++;
      }
      final String block = moveHistoryText.substring(start, i).trim();
      if (block.isNotEmpty) {
        tokens.add(block);
      }
      continue;
    }


    if (RegExp(r'\s').hasMatch(c)) {
      i++;
      continue;
    }



    if (c == '(' || c == ')') {
      tokens.add(c);
      i++;
      continue;
    }


    final int start = i;
    while (i < moveHistoryText.length) {
      final String cc = moveHistoryText[i];

      if (cc == '{' || cc == '(' || cc == ')' || RegExp(r'\s').hasMatch(cc)) {
        break;
      }
      i++;
    }


    final String rawToken = moveHistoryText.substring(start, i);
    final String trimmed = rawToken.trim();


    if (trimmed.isEmpty) {
      continue;
    }


    if (RegExp(r'^\d+\.\s*$').hasMatch(trimmed)) {
      continue;
    }


    tokens.add(trimmed);
  }

  return tokens;
}


String stripBraces(String text) {
  return text.replaceAll('{', '').replaceAll('}', '');
}


String stripOuterBraces(String block) {
  if (block.startsWith('{') && block.endsWith('}') && block.length >= 2) {
    return block.substring(1, block.length - 1);
  }
  return block;
}







List<String> mergeMoves(List<String> tokens) {
  final List<String> results = <String>[];

  TempMove? current;


  void finalizeCurrent() {
    if (current != null && current!.moveText.isNotEmpty) {

      final StringBuffer sb = StringBuffer(current!.moveText);



      if (current!.nags.isNotEmpty) {
        sb.write(current!.nags.join());
      }


      if (current!.comments.isNotEmpty) {
        final String joinedComments =
            current!.comments.map(stripBraces).join(' ');
        sb.write(' {$joinedComments}');
      }

      results.add(sb.toString());
    }
    current = null;
  }


  bool isNAG(String token) {
    const List<String> nagTokens = <String>['!', '?', '!!', '??', '!?', '?!'];
    return nagTokens.contains(token);
  }

  for (final String token in tokens) {

    if (token.startsWith('{') && token.endsWith('}')) {
      current ??= TempMove();
      final String inside = stripOuterBraces(token).trim();
      current!.comments.add(inside);
      continue;
    }



    if (isNAG(token)) {
      current ??= TempMove();
      current!.nags.add(token);
      continue;
    }


    if (token.startsWith('x')) {
      if (current == null) {
        current = TempMove()
          ..moveText = token
          ..hasX = true;
      } else {

        if (!current!.hasX) {
          current!.comments.clear();
          current!.nags.clear();
        }

        current!.moveText += token;
        current!.hasX = true;
      }
      continue;
    }



    if (token == '(' || token == ')') {
      finalizeCurrent();

      results.add(token);
      continue;
    }


    finalizeCurrent();
    current = TempMove()..moveText = token;
  }


  finalizeCurrent();
  return results;
}


List<String> getMergedMoves(GameController controller) {
  final String moveHistoryText = controller.gameRecorder.moveHistoryText;
  final List<String> mergedMoves = <String>[];
  String remainingText = moveHistoryText;


  if (remainingText.startsWith('[')) {
    final int bracketEnd = remainingText.lastIndexOf(']') + 1;
    if (bracketEnd > 0) {
      mergedMoves.add(remainingText.substring(0, bracketEnd));
      remainingText = remainingText.substring(bracketEnd).trim();
    }
  }


  final List<String> rawTokens = lexTokens(remainingText);


  final List<String> moves = mergeMoves(rawTokens);

  mergedMoves.addAll(moves);
  return mergedMoves;
}
