




















part of 'database.dart';




class _DatabaseMigration {
  const _DatabaseMigration._();

  static const String _logTag = "[Database Migration]";


  static const int _newVersion = 2;



  static late int? _currentVersion;


  static const List<Future<void> Function()> _migrations =
      <Future<void> Function()>[
    _migrateToHive,
    _migrateFromV1,
  ];


  static late Box<dynamic> _databaseBox;


  static const String _databaseBoxName = "database";


  static const String _versionKey = "version";





  static Future<bool> migrate() async {
    if (kIsWeb) {
      return false;
    }

    bool migrated = false;


    assert(_migrations.length == _newVersion);

    _databaseBox = await Hive.openBox(_databaseBoxName);

    _currentVersion = _databaseBox.get(_versionKey) as int?;

    if (_currentVersion == null) {
      if (await _DatabaseV1.usesV1) {
        _currentVersion = 0;
      } else if (DB().generalSettings.usesHiveDB) {
        _currentVersion = 1;
      }
      logger.t("$_logTag: Current version is $_currentVersion");

      if (_currentVersion != null) {
        for (int i = _currentVersion!; i < _newVersion; i++) {
          await _migrations[i].call();
        }

        migrated = true;
      }
    }

    await _databaseBox.put(_versionKey, _newVersion);
    _databaseBox.close();

    await _migrateFromDeprecation();

    return migrated;
  }




  static Future<void> _migrateToHive() async {
    assert(_currentVersion! <= 0);

    await _DatabaseV1.migrateDB();
    logger.i("$_logTag Migrated from KV to DB");
  }









  static Future<void> _migrateFromV1() async {
    assert(_currentVersion! <= 1);

    final GeneralSettings generalSettings = DB().generalSettings;
    DB().generalSettings = generalSettings.copyWith(
      searchAlgorithm: SearchAlgorithm.values[generalSettings.algorithm],
    );

    final DisplaySettings displaySettings = DB().displaySettings;
    DB().displaySettings = displaySettings.copyWith(
      locale: DB().displaySettings.languageCode == "Default"
          ? null
          : Locale(DB().displaySettings.languageCode),
      pointPaintingStyle: PointPaintingStyle.values[displaySettings.pointStyle],
      fontScale: displaySettings.fontSize / 16,
    );

    final ColorSettings colorSettings = DB().colorSettings;
    final Color? lerpedColor = Color.lerp(
      colorSettings.drawerColor,
      colorSettings.drawerBackgroundColor,
      0.5,
    );

    if (lerpedColor == null) {
      logger.w("Color.lerp returned null. Using default drawerColor.");
    }

    DB().colorSettings = colorSettings.copyWith(
      drawerColor: lerpedColor?.withAlpha(0xFF) ??
          colorSettings.drawerColor.withAlpha(0xFF),
    );

    logger.t("$_logTag Migrated from v1");
  }





  static Future<void> _migrateFromDeprecation() async {

    if (DB().ruleSettings.isWhiteLoseButNotDrawWhenBoardFull == false) {
      DB().ruleSettings = DB().ruleSettings.copyWith(
            boardFullAction: BoardFullAction.agreeToDraw,
          );
      DB().ruleSettings = DB().ruleSettings.copyWith(
            isWhiteLoseButNotDrawWhenBoardFull: true,
          );
      logger.t(
          "$_logTag Migrated from isWhiteLoseButNotDrawWhenBoardFull to boardFullAction.");
    }


    if (DB().ruleSettings.isLoseButNotChangeSideWhenNoWay == false) {
      DB().ruleSettings = DB().ruleSettings.copyWith(
            stalemateAction: StalemateAction.changeSideToMove,
          );
      DB().ruleSettings = DB().ruleSettings.copyWith(
            isLoseButNotChangeSideWhenNoWay: true,
          );
      logger.t(
          "$_logTag Migrated from isLoseButNotChangeSideWhenNoWay to stalemateAction.");
    }


    if (DB().ruleSettings.mayOnlyRemoveUnplacedPieceInPlacingPhase == true) {
      DB().ruleSettings = DB().ruleSettings.copyWith(
            millFormationActionInPlacingPhase: MillFormationActionInPlacingPhase
                .removeOpponentsPieceFromHandThenYourTurn,
          );
      DB().ruleSettings = DB().ruleSettings.copyWith(
            mayOnlyRemoveUnplacedPieceInPlacingPhase: false,
          );
      logger.t(
          "$_logTag Migrated from mayOnlyRemoveUnplacedPieceInPlacingPhase to millFormationActionInPlacingPhase.");
    }
    if (DB().ruleSettings.hasBannedLocations == true) {
      DB().ruleSettings = DB().ruleSettings.copyWith(
            millFormationActionInPlacingPhase:
                MillFormationActionInPlacingPhase.markAndDelayRemovingPieces,
          );
      DB().ruleSettings = DB().ruleSettings.copyWith(
            hasBannedLocations: false,
          );
      logger.t(
          "$_logTag Migrated from hasBannedLocations to millFormationActionInPlacingPhase.");
    }
  }
}




class _DatabaseV1 {
  const _DatabaseV1._();

  static const String _logTag = "[KV store Migration]";

  static Future<File?> _getFile() async {
    final String fileName = Constants.settingsFile;
    final Directory docDir = await getApplicationDocumentsDirectory();

    final File file = File("${docDir.path}/$fileName");
    return _checkFileExists(file);
  }

  static Future<File?> _checkFileExists(File file) async {
    return file.existsSync() ? file : null;
  }


  static Future<bool> get usesV1 async {
    final File? file = await _getFile();
    logger.i("$_logTag still uses v1: ${file != null}");
    return file != null;
  }


  static Future<Map<String, dynamic>?> _loadFile(File file) async {
    assert(await usesV1);
    logger.t("$_logTag Loading $file ...");

    try {
      final String contents = await file.readAsString();
      final Map<String, dynamic>? values =
          jsonDecode(contents) as Map<String, dynamic>?;
      logger.t(values.toString());
      return values;
    } catch (e) {
      logger.e("$_logTag error loading file $e");
    }
    return null;
  }



  static Future<void> migrateDB() async {
    logger.i("$_logTag migrate from KV to DB");
    final File? file = await _getFile();
    assert(file != null);

    final Map<String, dynamic>? json = await _loadFile(file!);
    if (json != null) {
      DB().generalSettings = GeneralSettings.fromJson(json);
      DB().ruleSettings = RuleSettings.fromJson(json);
      DB().displaySettings = DisplaySettings.fromJson(json);
      DB().colorSettings = ColorSettings.fromJson(json);
    }
    await _deleteFile(file);
  }


  static Future<void> _deleteFile(File file) async {
    assert(await usesV1);
    logger.t("$_logTag Deleting old settings file...");

    await file.delete();
    logger.i("$_logTag $file Deleted");
  }
}
