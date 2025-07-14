




part of '../mill.dart';


class LoadService {
  LoadService._();

  static const String _logTag = "[Loader]";


  static Future<String?> getFilePath(BuildContext context) async {
    Directory? dir = (!kIsWeb && Platform.isAndroid)
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    final String path = '${dir?.path ?? ""}/records';


    dir = Directory(path);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    if (!context.mounted) {
      return null;
    }

    String? resultLabel = await _showTextInputDialog(context);

    if (resultLabel == null) {
      return null;
    }

    GameController().loadedGameFilenamePrefix = resultLabel;

    if (resultLabel.endsWith(".pgn") == false) {
      resultLabel = "$resultLabel.pgn";
    }

    final String filePath =
        resultLabel.startsWith(path) ? resultLabel : "$path/$resultLabel";

    return filePath;
  }


  static Future<String?> pickFile(BuildContext context) async {
    late Directory? dir;

    dir = (!kIsWeb && Platform.isAndroid)
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    final String path = '${dir?.path ?? ""}/records';


    dir = Directory(path);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }




    if (!kIsWeb && Platform.isAndroid) {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;
      final List<FileSystemEntity> entities =
          appDocDir.listSync(recursive: true);

      for (final FileSystemEntity entity in entities) {
        if (entity is File && entity.path.endsWith('.pgn')) {
          final String newPath = entity.path.replaceAll(appDocPath, path);
          final File newFile = File(newPath);

          if (!newFile.existsSync()) {
            await newFile.create(recursive: true);
            await entity.copy(newPath);
          }

          await entity.delete();
        }
      }
    }

    if (!context.mounted) {
      return null;
    }

    final String? result = await FilesystemPicker.openDialog(
      context: context,
      rootDirectory: dir,
      rootName: S.of(context).gameFiles,
      fsType: FilesystemType.file,
      showGoUp: !kIsWeb && !Platform.isLinux,
      allowedExtensions: <String>[".pgn"],
      fileTileSelectMode: FileTileSelectMode.checkButton,

      theme: const FilesystemPickerTheme(
        backgroundColor: Colors.greenAccent,
      ),
    );

    if (result == null) {
      return null;
    }

    return result;
  }


  static Future<String?> saveGame(BuildContext context,
      {bool shouldPop = true}) async {
    if (EnvironmentConfig.test == true) {
      return null;
    }

    final String strGameSavedTo = S.of(context).gameSavedTo;

    if (!(GameController().gameRecorder.activeNode?.parent != null ||
        GameController().isPositionSetup == true)) {
      if (shouldPop) {
        Navigator.pop(context);
      }
      return null;
    }

    final String? filename = await getFilePath(context);

    if (filename == null) {
      safePop();
      return null;
    }

    final File file = File(filename);
    file.writeAsString(ImportService.addTagPairs(
        GameController().gameRecorder.moveHistoryText));

    rootScaffoldMessengerKey.currentState!
        .showSnackBarClear("$strGameSavedTo $filename");

    if (shouldPop) {
      safePop();
    }


    Future<void>.delayed(const Duration(milliseconds: 500), () {
      ScreenshotService.takeScreenshot("records", "$filename.jpg");

      if (GameController().loadedGameFilenamePrefix != null) {
        GameController()
            .headerTipNotifier
            .showTip(GameController().loadedGameFilenamePrefix!);
      }
    });

    return filename;
  }


  static Future<void> loadGame(BuildContext context, String? filePath,
      {required bool isRunning, bool shouldPop = true}) async {
    filePath ??= await pickFileIfNeeded(context);

    if (filePath == null) {
      logger.e('$_logTag File path is null');
      return;
    }

    try {

      if (filePath.startsWith('content') || filePath.startsWith('file://')) {
        final String? fileContent =
            await readFileContentFromUri(Uri.parse(filePath));
        if (fileContent == null) {
          final Directory? dir = await getExternalStorageDirectory();
          rootScaffoldMessengerKey.currentState!.showSnackBarClear(
              "You should put files in the right place: $dir");
          return;
        }
        GameController().initialSharingMoveList = fileContent;
        if (isRunning == true) {

          Future<void>.delayed(const Duration(seconds: 1), () {
            GameController().headerIconsNotifier.showIcons();
            GameController().boardSemanticsNotifier.updateSemantics();
          });
        }
      } else {

        final String fileContent = await readFileContent(filePath);
        logger.t('$_logTag File Content: $fileContent');
        if (!context.mounted) {
          return;
        }
        final bool importSuccess = await importGameData(context, fileContent);
        if (importSuccess) {
          if (!context.mounted) {
            return;
          }
          await handleHistoryNavigation(context);
        }
        if (!context.mounted) {
          return;
        }
        if (shouldPop) {
          Navigator.pop(context);
        }
      }
    } catch (exception) {
      if (!context.mounted) {
        return;
      }
      GameController().headerTipNotifier.showTip(S.of(context).loadFailed);
      if (!context.mounted) {
        return;
      }
      if (shouldPop) {
        Navigator.pop(context);
      }
      return;
    }
    GameController().loadedGameFilenamePrefix =
        extractPgnFilenamePrefix(filePath);


    if (GameController().loadedGameFilenamePrefix != null) {
      final String loadedGameFilenamePrefix =
          GameController().loadedGameFilenamePrefix!;
      Future<void>.delayed(Duration.zero, () {
        GameController().headerTipNotifier.showTip(loadedGameFilenamePrefix);
      });
    }
  }

  static String? extractPgnFilenamePrefix(String path) {

    if (path.endsWith('.pgn')) {
      try {

        final String decodedPath;
        if (path.startsWith("/")) {
          decodedPath = path;
        } else {
          decodedPath = Uri.decodeComponent(path);
        }


        final int lastIndex = decodedPath.lastIndexOf('/');
        if (lastIndex == -1) {
          return null;
        }

        return decodedPath.substring(lastIndex + 1, decodedPath.length - 4);
      } catch (e) {

        return null;
      }
    } else {


      return null;
    }
  }


  static Future<String?> pickFileIfNeeded(BuildContext context) async {
    if (EnvironmentConfig.test == true) {
      return null;
    }

    rootScaffoldMessengerKey.currentState!.clearSnackBars();
    return pickFile(context);
  }


  static Future<String> readFileContent(String filePath) async {
    final File file = File(filePath);
    return file.readAsString();
  }


  static Future<bool> importGameData(
      BuildContext context, String fileContent) async {
    try {
      ImportService.import(fileContent);
      logger.t('$_logTag File Content: $fileContent');
      final String tagPairs = getTagPairs(fileContent);

      if (tagPairs.isNotEmpty) {
        rootScaffoldMessengerKey.currentState!
            .showSnackBar(CustomSnackBar(tagPairs));
      }

      return true;
    } catch (exception) {

      final String errorMessage = exception.toString();
      final String tip = S.of(context).cannotImport(errorMessage);
      rootScaffoldMessengerKey.currentState?.showSnackBarClear(tip);
      GameController().headerTipNotifier.showTip(tip);

      return false;
    }
  }


  static Future<void> handleHistoryNavigation(BuildContext context) async {
    await HistoryNavigator.takeBackAll(context, pop: false);

    if (!context.mounted) {
      return;
    }

    if (await HistoryNavigator.stepForwardAll(context, pop: false) ==
        const HistoryOK()) {
      if (!context.mounted) {
        return;
      }

      rootScaffoldMessengerKey.currentState
          ?.showSnackBarClear(S.of(context).done);
      GameController()
          .headerTipNotifier
          .showTip(S.of(context).done);
    } else {
      if (!context.mounted) {
        return;
      }


      String errorMessage;
      if (HistoryNavigator.importFailedStr.isNotEmpty) {

        errorMessage = HistoryNavigator.importFailedStr;
      } else {

        errorMessage = "❌";
      }

      final String tip = S.of(context).cannotImport(errorMessage);
      rootScaffoldMessengerKey.currentState?.showSnackBarClear(tip);
      GameController().headerTipNotifier.showTip(tip);

      HistoryNavigator.importFailedStr = "";
    }
  }


  static Future<String?> readFileContentFromUri(Uri uri) async {
    String? str;
    try {
      str = await readContentUri(uri);
    } catch (e) {
      logger.e('Error reading file at $uri: $e');
      rethrow;
    }
    return str;
  }

  static Future<String?> _showTextInputDialog(BuildContext context) async {
    final TextEditingController textFieldController = TextEditingController();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            S.of(context).filename,
            style: TextStyle(
                fontSize: AppTheme.textScaler.scale(AppTheme.defaultFontSize)),
          ),
          content: TextField(
            controller: textFieldController,
            decoration: const InputDecoration(
              suffixText: ".pgn",
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
                child: Text(
                  S.of(context).browse,
                  style: TextStyle(
                      fontSize:
                          AppTheme.textScaler.scale(AppTheme.defaultFontSize)),
                ),
                onPressed: () async {
                  final String? result = await pickFile(context);
                  if (result == null) {
                    return;
                  }
                  textFieldController.text = result;
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.pop(context, textFieldController.text);
                }),
            ElevatedButton(
              child: Text(
                S.of(context).cancel,
                style: TextStyle(
                    fontSize:
                        AppTheme.textScaler.scale(AppTheme.defaultFontSize)),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text(
                S.of(context).ok,
                style: TextStyle(
                    fontSize:
                        AppTheme.textScaler.scale(AppTheme.defaultFontSize)),
              ),
              onPressed: () => Navigator.pop(context, textFieldController.text),
            ),
          ],
        );
      },
      barrierDismissible: false,
    );
  }
}
