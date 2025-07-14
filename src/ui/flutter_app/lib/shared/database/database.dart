




import 'dart:convert' show jsonDecode;
import 'dart:io' show Directory, File, Platform;

import 'package:flutter/foundation.dart'
    show ValueListenable, kIsWeb, visibleForTesting;
import 'package:flutter/material.dart' show Color, Locale;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../appearance_settings/models/color_settings.dart';
import '../../appearance_settings/models/display_settings.dart';
import '../../game_page/services/mill.dart';
import '../../general_settings/models/general_settings.dart';
import '../../rule_settings/models/rule_settings.dart';
import '../../statistics/model/stats_settings.dart';
import '../config/constants.dart';
import '../services/logger.dart';
import 'adapters/adapters.dart';

part 'database_migration.dart';

typedef DB = Database;




class Database {



  factory Database([Locale? locale]) => instance ??= Database._(locale);


  Database._([this.locale]);

  @visibleForTesting
  static Database? instance;


  final Locale? locale;


  static late final Box<GeneralSettings> _generalSettingsBox;


  static const String generalSettingsKey = "settings";


  static const String _generalSettingsBoxName = "generalSettings";


  static late final Box<RuleSettings> _ruleSettingsBox;


  static const String ruleSettingsKey = "settings";


  static const String _ruleSettingsBoxName = "ruleSettings";


  static late final Box<DisplaySettings> _displaySettingsBox;


  static const String displaySettingsKey = "settings";


  static const String _displaySettingsBoxName = "displaySettings";


  static late final Box<ColorSettings> _colorSettingsBox;


  static const String colorSettingsKey = "settings";


  static const String _colorSettingsBoxName = "colorSettings";


  static late final Box<dynamic> _customThemesBox;
  static const String _customThemesBoxName = "customThemes";
  static const String customThemesKey = "customThemes";


  static late final Box<StatsSettings> _statsSettingsBox;


  static const String statsSettingsKey = "settings";


  static const String _statsSettingsBoxName = "statsSettings";


  static Future<void> init() async {
    await Hive.initFlutter("Sanmill");

    await _initGeneralSettings();
    await _initRuleSettings();
    await _initDisplaySettings();
    await _initColorSettings();
    await _initCustomThemes();
    await _initStatsSettings();

    if (await _DatabaseMigration.migrate() == true) {
      DB().generalSettings = DB().generalSettings.copyWith(firstRun: false);
    }
  }


  static Future<void> reset() async {
    await _generalSettingsBox.delete(generalSettingsKey);
    await _ruleSettingsBox.delete(ruleSettingsKey);
    await _colorSettingsBox.delete(colorSettingsKey);
    await _displaySettingsBox.delete(displaySettingsKey);
    await _customThemesBox.delete(customThemesKey);
    await _statsSettingsBox.delete(statsSettingsKey);
  }




  static Future<void> _initGeneralSettings() async {
    Hive.registerAdapter<SearchAlgorithm>(SearchAlgorithmAdapter());
    Hive.registerAdapter<SoundTheme>(SoundThemeAdapter());
    Hive.registerAdapter<LlmProvider>(LlmProviderAdapter());
    Hive.registerAdapter<GeneralSettings>(GeneralSettingsAdapter());
    _generalSettingsBox =
        await Hive.openBox<GeneralSettings>(_generalSettingsBoxName);
  }


  ValueListenable<Box<GeneralSettings>> get listenGeneralSettings =>
      _generalSettingsBox.listenable(keys: <String>[generalSettingsKey]);


  set generalSettings(GeneralSettings generalSettings) {
    _generalSettingsBox.put(generalSettingsKey, generalSettings);
    GameController().engine.setGeneralOptions();
  }


  GeneralSettings get generalSettings =>
      _generalSettingsBox.get(generalSettingsKey) ?? const GeneralSettings();




  static Future<void> _initRuleSettings() async {
    Hive.registerAdapter<MillFormationActionInPlacingPhase>(
        MillFormationActionInPlacingPhaseAdapter());
    Hive.registerAdapter<BoardFullAction>(BoardFullActionAdapter());
    Hive.registerAdapter<StalemateAction>(StalemateActionAdapter());
    Hive.registerAdapter<RuleSettings>(RuleSettingsAdapter());
    _ruleSettingsBox = await Hive.openBox<RuleSettings>(_ruleSettingsBoxName);
  }


  ValueListenable<Box<RuleSettings>> get listenRuleSettings =>
      _ruleSettingsBox.listenable(keys: <String>[ruleSettingsKey]);


  set _ruleSettings(RuleSettings? ruleSettings) {
    if (ruleSettings != null) {
      _ruleSettingsBox.put(ruleSettingsKey, ruleSettings);
      GameController().engine.setRuleOptions();
    }
  }


  RuleSettings? get _ruleSettings => _ruleSettingsBox.get(ruleSettingsKey);


  set ruleSettings(RuleSettings ruleSettings) => _ruleSettings = ruleSettings;







  RuleSettings get ruleSettings =>
      _ruleSettings ??= RuleSettings.fromLocale(locale);




  static Future<void> _initDisplaySettings() async {
    Hive.registerAdapter<Locale?>(LocaleAdapter());
    Hive.registerAdapter<PointPaintingStyle>(PointPaintingStyleAdapter());
    Hive.registerAdapter<MovesViewLayout>(MovesViewLayoutAdapter());
    Hive.registerAdapter<DisplaySettings>(DisplaySettingsAdapter());
    _displaySettingsBox =
        await Hive.openBox<DisplaySettings>(_displaySettingsBoxName);
  }


  ValueListenable<Box<DisplaySettings>> get listenDisplaySettings =>
      _displaySettingsBox.listenable(keys: <String>[displaySettingsKey]);


  set displaySettings(DisplaySettings displaySettings) =>
      _displaySettingsBox.put(displaySettingsKey, displaySettings);


  DisplaySettings get displaySettings =>
      _displaySettingsBox.get(displaySettingsKey) ?? const DisplaySettings();


  static Future<void> _initColorSettings() async {
    Hive.registerAdapter<Color>(ColorAdapter());
    Hive.registerAdapter<ColorSettings>(ColorSettingsAdapter());

    try {
      _colorSettingsBox =
          await Hive.openBox<ColorSettings>(_colorSettingsBoxName);
    } catch (e) {
      logger.e('Initialization failed: $e');

      await _deleteAndRecreateColorSettingsBox();
    }
  }

  static Future<void> _deleteAndRecreateColorSettingsBox() async {
    try {

      if (Hive.isBoxOpen(_colorSettingsBoxName)) {
        final Box<ColorSettings> box =
            Hive.box<ColorSettings>(_colorSettingsBoxName);
        await box.close();
        logger.i('Box closed successfully.');
      }

      await Future<void>.delayed(const Duration(seconds: 1));


      await Hive.deleteBoxFromDisk(_colorSettingsBoxName);
      logger.i('Box deleted from disk.');


      await Future<void>.delayed(const Duration(seconds: 1));


      _colorSettingsBox =
          await Hive.openBox<ColorSettings>(_colorSettingsBoxName);
      logger.i('Box has been recreated successfully.');
    } catch (e) {
      logger.e('Failed to delete or recreate box: $e');
    }
  }


  ValueListenable<Box<ColorSettings>> get listenColorSettings =>
      _colorSettingsBox.listenable(keys: <String>[colorSettingsKey]);


  set colorSettings(ColorSettings colorSettings) =>
      _colorSettingsBox.put(colorSettingsKey, colorSettings);


  ColorSettings get colorSettings =>
      _colorSettingsBox.get(colorSettingsKey) ?? const ColorSettings();


  static Future<void> _initCustomThemes() async {
    _customThemesBox = await Hive.openBox<dynamic>(_customThemesBoxName);
  }


  List<ColorSettings> get customThemes {
    final dynamic rawData = _customThemesBox.get(customThemesKey);

    if (rawData == null) {
      return <ColorSettings>[];
    }


    if (rawData is List) {
      return rawData.map<ColorSettings>((dynamic item) {
        if (item is ColorSettings) {
          return item;
        } else {
          return const ColorSettings();
        }
      }).toList();
    }

    return <ColorSettings>[];
  }


  set customThemes(List<ColorSettings> themes) {
    _customThemesBox.put(customThemesKey, themes);
  }




  static Future<void> _initStatsSettings() async {
    Hive.registerAdapter<PlayerStats>(PlayerStatsAdapter());
    Hive.registerAdapter<StatsSettings>(StatsSettingsAdapter());
    _statsSettingsBox =
        await Hive.openBox<StatsSettings>(_statsSettingsBoxName);
  }


  ValueListenable<Box<StatsSettings>> get listenStatsSettings =>
      _statsSettingsBox.listenable(keys: <String>[statsSettingsKey]);


  set statsSettings(StatsSettings settings) =>
      _statsSettingsBox.put(statsSettingsKey, settings);


  StatsSettings get statsSettings =>
      _statsSettingsBox.get(statsSettingsKey) ?? const StatsSettings();
}
