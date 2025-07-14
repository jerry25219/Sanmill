




import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';

import '../../appearance_settings/models/color_settings.dart';
import '../database/database.dart';
import 'ui_colors.dart';





















@immutable
class AppTheme {
  const AppTheme._();

  static final ColorScheme _colorScheme = ColorScheme(

    brightness: Brightness.light,
    primary: _appPrimaryColor,

    onPrimary: Colors.white,

    primaryContainer: Colors.green.shade700,

    onPrimaryContainer: Colors.white,

    secondary: UIColors.spruce,

    onSecondary: Colors.black,

    secondaryContainer: UIColors.spruce,

    onSecondaryContainer: Colors.white,

    surface: Colors.white,

    onSurface: Colors.black,

    error: Colors.red,

    onError: Colors.white, // Text or icon color in error state

  );


  static final ThemeData lightThemeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: _colorScheme,

    sliderTheme: _sliderThemeData.copyWith(
      activeTrackColor: _colorScheme.primary, // Use colors in ColorScheme
      inactiveTrackColor: _colorScheme.onSurface.withValues(alpha: 0.5),
      thumbColor: _colorScheme.primary,

    ),
    cardTheme: _cardThemeData,
    appBarTheme: appBarTheme.copyWith(
      backgroundColor: _colorScheme.primary, // Use colors from ColorScheme
      titleTextStyle: TextStyle(color: _colorScheme.onSecondary),

      centerTitle: true, // Center the title
    ),
    textTheme: _textTheme,

    dividerTheme: _dividerTheme,
    switchTheme: _lightSwitchTheme,

  );


  static final ColorScheme _darkColorScheme = _colorScheme.copyWith(
    brightness: Brightness.dark,


  );

  static final ThemeData darkThemeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: _darkColorScheme,

    sliderTheme: _sliderThemeData.copyWith(
      activeTrackColor: _darkColorScheme.primary,
      inactiveTrackColor: _darkColorScheme.onSurface.withValues(alpha: 0.5),
      thumbColor: _colorScheme.primary,

    ),
    cardTheme: _cardThemeData,
    appBarTheme: appBarTheme.copyWith(
      backgroundColor: _darkColorScheme.primary,
      titleTextStyle: TextStyle(color: _darkColorScheme.onSecondary),

      centerTitle: true, // Center the title
    ),
    textTheme: _textTheme,

    dividerTheme: _dividerTheme,
    switchTheme: _darkSwitchTheme,

  );

  static MaterialColor createMaterialColor(Color color) {
    final List<double> strengths = <double>[.05];
    final Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (final double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }


  static const MaterialColor _appPrimaryColor = Colors.teal;


  static final SliderThemeData _sliderThemeData = SliderThemeData(
    trackHeight: 20,

    activeTrackColor: _colorScheme.primary,

    inactiveTrackColor: _colorScheme.onSurface.withValues(alpha: 0.5),

    thumbColor: _colorScheme.primary,

    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 1.0),

    overlayColor: _colorScheme.primary.withValues(alpha: 0.12),

    overlayShape: const RoundSliderOverlayShape(overlayRadius: 1.0),

    valueIndicatorShape: const PaddleSliderValueIndicatorShape(),

    valueIndicatorColor: _colorScheme.primary,

    valueIndicatorTextStyle: const TextStyle(
      color: Colors.white, // Text color of numeric indicator
      fontSize: 24, // text size
    ),
  );

  static final DividerThemeData _dividerTheme = DividerThemeData(
    indent: 16,
    endIndent: 16,
    space: 1.0,
    thickness: 1.0,
    color: _colorScheme.onSurface.withValues(
        alpha:
            0.12), //Adjust color transparency according to theme surface color
  );

  static final CardThemeData _cardThemeData = CardThemeData(
    margin: const EdgeInsets.symmetric(vertical: 4.0),
    color: cardColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // rounded corner design
    ),
    elevation: 1, // slight shadow effect
  );

  static final CardTheme _cardTheme = CardTheme(
    margin: const EdgeInsets.symmetric(vertical: 4.0),
    color: cardColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // rounded corner design
    ),
    elevation: 1, // slight shadow effect
  );

  static final SwitchThemeData _lightSwitchTheme = SwitchThemeData(
    thumbColor:
        WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return _colorScheme.primary;
      }
      return _colorScheme.onSurface
          .withValues(alpha: 0.5);
    }),
    trackColor:
        WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return _colorScheme.primary.withValues(
            alpha: 0.5);
      }
      return _colorScheme.onSurface.withValues(
          alpha: 0.3);
    }),
    trackOutlineColor:
        WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return _colorScheme.onSurface
            .withValues(alpha: 0.5);
      }
      return Colors.transparent;
    }),
  );

  static final SwitchThemeData _darkSwitchTheme = SwitchThemeData(
    thumbColor:
        WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return _darkColorScheme.onSurface
            .withValues(alpha: 0.5);
      }
      if (states.contains(WidgetState.selected)) {
        return _darkColorScheme
            .primary;
      }
      return _darkColorScheme.onSurface
          .withValues(alpha: 0.5);
    }),
    trackColor:
        WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return _darkColorScheme.onSurface
            .withValues(alpha: 0.3);
      }
      if (states.contains(WidgetState.selected)) {
        return _darkColorScheme.primary
            .withValues(alpha: 0.5);
      }
      return _darkColorScheme.onSurface
          .withValues(alpha: 0.1);
    }),
    trackOutlineColor:
        WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return _darkColorScheme.onSurface
            .withValues(alpha: 0.5);
      }
      return Colors
          .transparent;
    }),
  );

  static final AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor:
        _colorScheme.primary, // Use the primary color of ColorScheme
    titleTextStyle: TextStyle(
      color: _colorScheme
          .onPrimary, // Select color based on primary color contrast
      fontSize: 20.0, // font size
      fontWeight: FontWeight.bold,
    ),
    elevation: 0, // Reduce or remove shadows for a flatter design
    iconTheme: IconThemeData(
      color: _colorScheme
          .onPrimary, // Make the icon the same color as the title text
    ),

  );

  static const TextTheme _textTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.25, // Add appropriate letter spacing
    ),
    titleMedium: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15, // Add appropriate letter spacing
    ),
    bodyMedium: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w400, // Consider using regular font weights
      letterSpacing: 0.5, // Add appropriate letter spacing
    ),

  );

  static FeedbackThemeData feedbackTheme = FeedbackThemeData(
    activeFeedbackModeColor: _appPrimaryColor,
  );

  static const BoxDecoration dialogDecoration = BoxDecoration(
    color: UIColors.semiTransparentBlack,
    borderRadius: BorderRadius.all(Radius.circular(28)), // Rounded corners
  );

  static TextStyle dialogTitleTextStyle = TextStyle(
    color: _appPrimaryColor,
  );

  static const TextStyle listTileSubtitleStyle = TextStyle(
    color: listTileSubtitleColor,
    fontSize: 16,
  );

  static const TextStyle listTileTitleStyle = TextStyle(
    color: _switchListTileTitleColor,
  );

  static final TextStyle mainToolbarTextStyle = TextStyle(
    color: DB().colorSettings.mainToolbarIconColor,
  );

  static const TextStyle helpTextStyle = TextStyle(
    color: helpTextColor,
    fontSize: 20,
  );

  static const double smallFontSize = 14.0;
  static const double defaultFontSize = 16.0;
  static const double largeFontSize = 20.0;
  static const double extraLargeFontSize = 24.0;
  static const double hugeFontSize = 28.0;
  static const double giantFontSize = 32.0;

  static TextScaler textScaler =
      TextScaler.linear(DB().displaySettings.fontScale);

  static const double boardMargin = 10.0;
  static double boardCornerRadius = DB().displaySettings.boardCornerRadius;
  static late double boardPadding;
  static const double sizedBoxHeight = 16.0;

  static const double drawerItemHeight = 46.0;
  static const double drawerItemPadding = 8.0;
  static const double drawerItemPaddingSmallScreen = 3.0;


  static const Color whitePieceBorderColor = UIColors.rosewood;
  static const Color blackPieceBorderColor = UIColors.darkJungleGreen;
  static const Color moveHistoryDialogBackgroundColor = Colors.transparent;
  static const Color infoDialogBackgroundColor = Colors.transparent;
  static const Color modalBottomSheetBackgroundColor = Colors.transparent;
  static const Color gamePageActionSheetTextColor = Colors.yellow;
  static Color gamePageActionSheetTextBackgroundColor =
      Colors.deepPurple.withValues(alpha: 0.8);


  static const Color listItemDividerColor = UIColors.rosewood20;
  static const Color _switchListTileTitleColor = UIColors.spruce;
  static const Color cardColor = UIColors.floralWhite;
  static const Color settingsHeaderTextColor = UIColors.spruce;
  static const Color lightBackgroundColor = UIColors.papayaWhip;
  static const Color listTileSubtitleColor = UIColors.cocoaBean60;


  static const Color helpTextColor = Colors.black;


  static const Color aboutPageBackgroundColor = UIColors.floralWhite;


  static const Color drawerDividerColor = UIColors.riverBed60;
  static const Color drawerBoxerShadowColor = UIColors.riverBed60;

  static const Color drawerAnimationIconColor = UIColors.seashell;
  static const Color drawerSplashColor = UIColors.starDust10;



  static final Map<ColorTheme, ColorSettings> colorThemes =
      <ColorTheme, ColorSettings>{
    ColorTheme.light: const ColorSettings(),
    ColorTheme.dark: const ColorSettings(
      boardLineColor: UIColors.osloGrey,
      darkBackgroundColor: Colors.black,
      boardBackgroundColor: Colors.black,
      whitePieceColor: UIColors.citrus,
      blackPieceColor: UIColors.butterflyBlue,
      pieceHighlightColor: Colors.white,
      messageColor: UIColors.tahitiGold,
      drawerColor: Colors.black,
      drawerTextColor: Colors.white,
      drawerHighlightItemColor: UIColors.highlighterGreen20,
      mainToolbarBackgroundColor: Colors.black,
      mainToolbarIconColor: UIColors.tahitiGold60,
      navigationToolbarBackgroundColor: Colors.black,
      navigationToolbarIconColor: UIColors.tahitiGold60,
      analysisToolbarBackgroundColor: Colors.black,
      analysisToolbarIconColor: UIColors.tahitiGold60,
      annotationToolbarBackgroundColor: Colors.black,
      annotationToolbarIconColor: UIColors.tahitiGold60,
    ),
    ColorTheme.monochrome: const ColorSettings(
      boardLineColor: Colors.black,
      darkBackgroundColor: Colors.white,
      boardBackgroundColor: Colors.white,
      whitePieceColor: Colors.white,
      blackPieceColor: Colors.black,
      pieceHighlightColor: Colors.black,
      messageColor: Colors.black,
      drawerColor: Colors.black,
      drawerTextColor: Colors.white,
      drawerHighlightItemColor: Color(0xFFA4A293),
      mainToolbarBackgroundColor: Colors.white,
      mainToolbarIconColor: Colors.black,
      navigationToolbarBackgroundColor: Colors.white,
      navigationToolbarIconColor: Colors.black,
      analysisToolbarBackgroundColor: Colors.white,
      analysisToolbarIconColor: Colors.black,
      annotationToolbarBackgroundColor: Colors.white,
      annotationToolbarIconColor: Colors.black,
    ),
    ColorTheme.transparentCanvas: const ColorSettings(
      boardLineColor: Colors.black,


      darkBackgroundColor: Color.fromARGB(1, 255, 255, 255),
      boardBackgroundColor: Color.fromARGB(1, 255, 255, 255),
      messageColor: Colors.black,
      mainToolbarBackgroundColor: Color.fromARGB(0, 255, 255, 255),
      mainToolbarIconColor: Colors.black,
      navigationToolbarBackgroundColor: Color.fromARGB(0, 255, 255, 255),
      navigationToolbarIconColor: Colors.black,
      analysisToolbarBackgroundColor: Color.fromARGB(0, 255, 255, 255),
      analysisToolbarIconColor: Colors.black,
      annotationToolbarBackgroundColor: Color.fromARGB(0, 255, 255, 255),
      annotationToolbarIconColor: Colors.black,
    ),
    ColorTheme.autumnLeaves: const ColorSettings(
      boardLineColor: Color(0xFF000000),

      darkBackgroundColor: Color(0xFF284B3A),

      boardBackgroundColor: Color(0xD78B5A3C),

      whitePieceColor: Color(0xFFEAE6C1),

      blackPieceColor: Color(0xFF3C3B3F),

      pieceHighlightColor: Color(0x88F08080),

      messageColor: Color(0xFF000000),

      drawerColor: Color(0xFF000000),

      drawerTextColor: Color(0xFFFFFFFF),

      drawerHighlightItemColor: Color(0x33FFB6C1),

      mainToolbarBackgroundColor: Color(0xD88B5A3C),

      mainToolbarIconColor: Color(0xFF000000),

      navigationToolbarBackgroundColor: Color(0xD58B5A3C),

      navigationToolbarIconColor: Color(0xFF000000),

      analysisToolbarBackgroundColor: Color(0xFF8B5A2B),

      analysisToolbarIconColor: Color(0xFFA4A293),

      annotationToolbarBackgroundColor: Color(0xFF8B5A2B),
      annotationToolbarIconColor: Color(0xFFA4A293),
    ),
    ColorTheme.legendaryLand: const ColorSettings(
      boardLineColor: Color(0xFF8FBC8F),

      darkBackgroundColor: Color(0xFF8B7355),

      boardBackgroundColor: Color(0xFF8B5A2B),

      whitePieceColor: Color(0xFFB2D8B2),

      blackPieceColor: Color(0xFF1A4D6E),

      pieceHighlightColor: Color(0xFFCD853F),

      messageColor: Color(0xFFF0FFF0),

      drawerColor: Color(0xFF2E4D40),

      drawerTextColor: Color(0xFFE0EEE0),

      drawerHighlightItemColor: Color(0x88355E3B),

      mainToolbarBackgroundColor: Color(0xFF8B7355),

      mainToolbarIconColor: Color(0xFFF0FFF0),

      navigationToolbarBackgroundColor: Color(0xFF8B7355),

      navigationToolbarIconColor: Color(0xFFF0FFF0),

      analysisToolbarBackgroundColor: Color(0xFF8B7355),

      analysisToolbarIconColor: Color(0xFFF0FFF0),

      annotationToolbarBackgroundColor: Color(0xFF8B7355),
      annotationToolbarIconColor: Color(0xFFF0FFF0),
    ),
    ColorTheme.goldenJade: const ColorSettings(
      boardBackgroundColor: Color(0xFFC89B42),

      darkBackgroundColor: Color(0xFFE9E7D7),

      boardLineColor: Color(0xFF496D88),

      whitePieceColor: Color(0xFFF8F3F6),

      blackPieceColor: Color(0xFF7FE3AF),

      pieceHighlightColor: Color(0xB3009600),

      messageColor: Color(0x62000000),

      drawerColor: Color(0xFF1C352D),

      drawerTextColor: Color(0xFFFFFFFF),

      drawerHighlightItemColor: Color(0x331BFC06),

      mainToolbarBackgroundColor: Color(0xFFE9E7D7),

      mainToolbarIconColor: Color(0xFFA4A293),

      navigationToolbarBackgroundColor: Color(0xFFE9E7D7),

      navigationToolbarIconColor: Color(0xFFA4A293),

      analysisToolbarBackgroundColor: Color(0xFFE9E7D7),

      analysisToolbarIconColor: Color(0xFFA4A293),

      annotationToolbarBackgroundColor: Color(0xFFE9E7D7),
      annotationToolbarIconColor: Color(0xFFA4A293),
    ),
    ColorTheme.forestWood: const ColorSettings(
      boardBackgroundColor: Color(0xFFC19A6B),

      darkBackgroundColor: Color(0xFF8B5A2B),

      boardLineColor: Color(0xFF4B5320),

      whitePieceColor: Color(0xFFEAE6C1),

      blackPieceColor: Color(0xFF3C3B3F),

      pieceHighlightColor: Color(0x88F08080),

      messageColor: Color(0x88000000),

      drawerColor: Color(0xFF8B5A2B),

      drawerTextColor: Color(0xFFFFFFFF),

      drawerHighlightItemColor: Color(0x33FFB6C1),

      mainToolbarBackgroundColor: Color(0xFF8B5A2B),

      mainToolbarIconColor: Color(0xFFA4A293),

      navigationToolbarBackgroundColor: Color(0xFF8B5A2B),

      navigationToolbarIconColor: Color(0xFFA4A293),

      analysisToolbarBackgroundColor: Color(0xFF8B5A2B),

      analysisToolbarIconColor: Color(0xFFA4A293),

      annotationToolbarBackgroundColor: Color(0xFF8B5A2B),
      annotationToolbarIconColor: Color(0xFFA4A293),
    ),
    ColorTheme.greenMeadow: const ColorSettings(
      boardBackgroundColor: Color(0xFF9ACD32),

      darkBackgroundColor: Color(0xFF006400),

      boardLineColor: Color(0xFF6B8E23),

      whitePieceColor: Color(0xFFF8F8FF),

      blackPieceColor: Color(0xFF2F4F4F),

      pieceHighlightColor: Color(0xFF70C1B3),

      messageColor: Color(0xFFA4A293),

      drawerColor: Color(0xFF006400),

      drawerTextColor: Color(0xFFFFFFFF),

      drawerHighlightItemColor: Color(0x33B0C4DE),

      mainToolbarBackgroundColor: Color(0xFF006400),

      mainToolbarIconColor: Color(0xFFA4A293),

      navigationToolbarBackgroundColor: Color(0xFF006400),

      navigationToolbarIconColor: Color(0xFFA4A293),

      analysisToolbarBackgroundColor: Color(0xFF006400),

      analysisToolbarIconColor: Color(0xFFA4A293),

      annotationToolbarBackgroundColor: Color(0xFF006400),
      annotationToolbarIconColor: Color(0xFFA4A293),
    ),
    ColorTheme.stonyPath: const ColorSettings(
      boardBackgroundColor: Color(0xFFC0C0C0),

      darkBackgroundColor: Color(0xFF808080),

      boardLineColor: Color(0xFF696969),

      whitePieceColor: Color(0xFFF5F5F5),

      blackPieceColor: Color(0xFF2F4F4F),

      pieceHighlightColor: Color(0x88FFA07A),

      messageColor: Color(0x88000000),

      drawerColor: Color(0xFF808080),

      drawerTextColor: Color(0xFFFFFFFF),

      drawerHighlightItemColor: Color(0x3399CCFF),

      mainToolbarBackgroundColor: Color(0xFF808080),

      mainToolbarIconColor: Color(0xFFA4A293),

      navigationToolbarBackgroundColor: Color(0xFF808080),

      navigationToolbarIconColor: Color(0xFFA4A293),

      analysisToolbarBackgroundColor: Color(0xFF808080),

      analysisToolbarIconColor: Color(0xFFA4A293),

      annotationToolbarBackgroundColor: Color(0xFF808080),
      annotationToolbarIconColor: Color(0xFFA4A293),
    ),
    ColorTheme.midnightBlue: const ColorSettings(
      boardBackgroundColor: Color(0xFF162447),

      darkBackgroundColor: Color(0xFF1f4068),

      boardLineColor: Color(0xFFe43f5a),

      whitePieceColor: Color(0xFFf9f7f7),

      blackPieceColor: Color(0xFF8338ec),

      pieceHighlightColor: Color(0xFF0000FF),

      messageColor: Color(0xFFA4A293),

      drawerColor: Color(0xFF1f4068),

      drawerTextColor: Color(0xFFFFFFFF),

      drawerHighlightItemColor: Color(0x33D3FF00),

      mainToolbarBackgroundColor: Color(0xFF1f4068),

      mainToolbarIconColor: Color(0xFFA4A293),

      navigationToolbarBackgroundColor: Color(0xFF1f4068),

      navigationToolbarIconColor: Color(0xFFA4A293),

      analysisToolbarBackgroundColor: Color(0xFF1f4068),

      analysisToolbarIconColor: Color(0xFFA4A293),

      annotationToolbarBackgroundColor: Color(0xFF1f4068),
      annotationToolbarIconColor: Color(0xFFA4A293),
    ),
    ColorTheme.greenForest: const ColorSettings(
      boardBackgroundColor: Color(0xFFa9eec2),

      darkBackgroundColor: Color(0xFF4DAA4C),

      boardLineColor: Color(0xFF7a9e9f),

      whitePieceColor: Color(0xFFffffff),

      blackPieceColor: Color(0xFF0a2239),

      pieceHighlightColor: Color(0x88FF0000),

      messageColor: Color(0x88000000),

      drawerColor: Color(0xFF4DAA4C),

      drawerTextColor: Color(0xFFFFFFFF),

      drawerHighlightItemColor: Color(0x33FFB800),

      mainToolbarBackgroundColor: Color(0xFF4DAA4C),

      mainToolbarIconColor: Color(0xFFA4A293),

      navigationToolbarBackgroundColor: Color(0xFF4DAA4C),

      navigationToolbarIconColor: Color(0xFFA4A293),

      analysisToolbarBackgroundColor: Color(0xFF4DAA4C),

      analysisToolbarIconColor: Color(0xFFA4A293),

      annotationToolbarBackgroundColor: Color(0xFF4DAA4C),
      annotationToolbarIconColor: Color(0xFFA4A293),
    ),
    ColorTheme.pastelPink: const ColorSettings(
      boardBackgroundColor: Color(0xFFf7bacf),

      darkBackgroundColor: Color(0xFFefc3e6),

      boardLineColor: Color(0xFFa95c5c),

      whitePieceColor: Color(0xFFffffff),

      blackPieceColor: Color(0xFF000000),

      pieceHighlightColor: Colors.red,
      messageColor: Color(0x88000000),

      drawerColor: Color(0xFFa95c5c),

      drawerTextColor: Color(0xFFFFFFFF),

      drawerHighlightItemColor: Color(0x33FFA500),

      mainToolbarBackgroundColor: Color(0xFFefc3e6),

      mainToolbarIconColor: Color(0xFFA4A293),

      navigationToolbarBackgroundColor: Color(0xFFefc3e6),

      navigationToolbarIconColor: Color(0xFFA4A293),

      analysisToolbarBackgroundColor: Color(0xFFefc3e6),

      analysisToolbarIconColor: Color(0xFFA4A293),

      annotationToolbarBackgroundColor: Color(0xFFefc3e6),
      annotationToolbarIconColor: Color(0xFFA4A293),
    ),
    ColorTheme.turquoiseSea: const ColorSettings(
      boardBackgroundColor: Color(0xFFc9ada1),

      darkBackgroundColor: Color(0xFF1f7a8c),

      boardLineColor: Color(0xFFeae2b7),

      whitePieceColor: Color(0xFFffffff),

      blackPieceColor: Color(0xFFd9b08c),

      pieceHighlightColor: Color(0xFFADFF2F),

      messageColor: Color(0xFFA4A293),

      drawerColor: Color(0xFF1f7a8c),

      drawerTextColor: Color(0xFFFFFFFF),

      drawerHighlightItemColor: Color(0x66DC143C),

      mainToolbarBackgroundColor: Color(0xFF1f7a8c),

      mainToolbarIconColor: Color(0xFFA4A293),

      navigationToolbarBackgroundColor: Color(0xFF1f7a8c),

      navigationToolbarIconColor: Color(0xFFA4A293),

      analysisToolbarBackgroundColor: Color(0xFF1f7a8c),

      analysisToolbarIconColor: Color(0xFFA4A293),

      annotationToolbarBackgroundColor: Color(0xFF1f7a8c),
      annotationToolbarIconColor: Color(0xFFA4A293),
    ),
    ColorTheme.violetDream: const ColorSettings(
      boardBackgroundColor: Color(0xFF8b77a9),

      darkBackgroundColor: Color(0xFF583d72),

      boardLineColor: Color(0xFFC5A3B5),

      whitePieceColor: Color(0xFFffffff),

      blackPieceColor: Color(0xFF000000),

      pieceHighlightColor: Color(0x88FFD700),

      messageColor: Color(0xFFA4A293),

      drawerColor: Color(0xFF583d72),

      drawerTextColor: Color(0xFFFFFFFF),

      drawerHighlightItemColor: Color(0x3393C47D),

      mainToolbarBackgroundColor: Color(0xFF583d72),

      mainToolbarIconColor: Color(0xFFA4A293),

      navigationToolbarBackgroundColor: Color(0xFF583d72),

      navigationToolbarIconColor: Color(0xFFA4A293),

      analysisToolbarBackgroundColor: Color(0xFF583d72),

      analysisToolbarIconColor: Color(0xFFA4A293),

      annotationToolbarBackgroundColor: Color(0xFF583d72),
      annotationToolbarIconColor: Color(0xFFA4A293),
    ),
    ColorTheme.mintChocolate: const ColorSettings(
      boardBackgroundColor: Color(0xFFA1E8AF),

      darkBackgroundColor: Color(0xFF0B3D0B),

      boardLineColor: Color(0xFF8B4513),

      whitePieceColor: Color(0xFFffffff),

      blackPieceColor: Color(0xFF000000),

      pieceHighlightColor: Color(0xEEFF69B4),

      messageColor: Color(0xFFA4A293),

      drawerColor: Color(0xFF0B3D0B),

      drawerTextColor: Color(0xFFFFFFFF),

      drawerHighlightItemColor: Color(0x33F08080),

      mainToolbarBackgroundColor: Color(0xFF0B3D0B),

      mainToolbarIconColor: Color(0xFFA4A293),

      navigationToolbarBackgroundColor: Color(0xFF0B3D0B),

      navigationToolbarIconColor: Color(0xFFA4A293),

      analysisToolbarBackgroundColor: Color(0xFF0B3D0B),

      analysisToolbarIconColor: Color(0xFFA4A293),


      annotationToolbarBackgroundColor: Color(0xFF0B3D0B),
      annotationToolbarIconColor: Color(0xFFA4A293),
    ),
    ColorTheme.skyBlue: const ColorSettings(
      boardBackgroundColor: Color(0xFFD0E1F9),

      darkBackgroundColor: Color(0xFF4B89AC),

      boardLineColor: Color(0xFF1C1C1C),

      whitePieceColor: Color(0xFFffffff),

      blackPieceColor: Color(0xFF000000),

      pieceHighlightColor: Color(0x88FFFF00),

      messageColor: Color(0x88000000),

      drawerColor: Color(0xFF4B89AC),

      drawerTextColor: Color(0xFFFFFFFF),

      drawerHighlightItemColor: Color(0x33FFC0CB),

      mainToolbarBackgroundColor: Color(0xFF4B89AC),

      mainToolbarIconColor: Color(0xFFA4A293),

      navigationToolbarBackgroundColor: Color(0xFF4B89AC),

      navigationToolbarIconColor: Color(0xFFA4A293),

      analysisToolbarBackgroundColor: Color(0xFF4B89AC),

      analysisToolbarIconColor: Color(0xFFA4A293),

      annotationToolbarBackgroundColor: Color(0xFF4B89AC),
      annotationToolbarIconColor: Color(0xFFA4A293),
    ),
    ColorTheme.playfulGarden: const ColorSettings(
      boardBackgroundColor: Color(0xFFFBE9A6),

      darkBackgroundColor: Color(0xFF8AC926),

      boardLineColor: Color(0xFF90BE6D),

      whitePieceColor: Color(0xFFFFFFFF),

      blackPieceColor: Color(0xFF222831),

      pieceHighlightColor: Color(0xFFF08080),

      messageColor: Color(0x88000000),

      drawerColor: Color(0xFF90BE6D),

      drawerTextColor: Color(0xFFFFFFFF),

      drawerHighlightItemColor: Color(0x33FFD700),

      mainToolbarBackgroundColor: Color(0xFFB8DCAC),

      mainToolbarIconColor: Color(0xFFA4A293),

      navigationToolbarBackgroundColor: Color(0xFFB8DCAC),

      navigationToolbarIconColor: Color(0xFFA4A293),

      analysisToolbarBackgroundColor: Color(0xFFB8DCAC),

      analysisToolbarIconColor: Color(0xFFA4A293),

      annotationToolbarBackgroundColor: Color(0xFFB8DCAC),
      annotationToolbarIconColor: Color(0xFFA4A293),
    ),
    ColorTheme.darkMystery: const ColorSettings(
      boardBackgroundColor: Color(0xFF5C5C5C),

      darkBackgroundColor: Color(0xFF0F0F0F),

      boardLineColor: Color(0xFF404040),

      whitePieceColor: Color(0xFFE0E0E0),

      blackPieceColor: Color(0xFF1A1A1A),

      pieceHighlightColor: Color(0x88C71585),

      messageColor: Color(0xFFA4A293),

      drawerColor: Color(0xFF0F0F0F),

      drawerTextColor: Color(0xFFFFFFFF),

      drawerHighlightItemColor: Color(0x33F08080),

      mainToolbarBackgroundColor: Color(0xFF0F0F0F),

      mainToolbarIconColor: Color(0xFFA4A293),

      navigationToolbarBackgroundColor: Color(0xFF0F0F0F),

      navigationToolbarIconColor: Color(0xFFA4A293),

      analysisToolbarBackgroundColor: Color(0xFF0F0F0F),

      analysisToolbarIconColor: Color(0xFFA4A293),

      annotationToolbarBackgroundColor: Color(0xFF0F0F0F),
      annotationToolbarIconColor: Color(0xFFA4A293),
    ),
    ColorTheme.ancientEgypt: const ColorSettings(
      boardBackgroundColor: Color(0xFFE8D0AA),

      darkBackgroundColor: Color(0xFF7E5C31),

      boardLineColor: Color(0xFF3D2A18),

      whitePieceColor: Color(0xFFFCF4D9),

      blackPieceColor: Color(0xFF2D4150),

      pieceHighlightColor: Color(0xFFD4AF37),

      messageColor: Color(0xFF3D2A18),

      drawerColor: Color(0xFF7E5C31),

      drawerTextColor: Color(0xFFFCF4D9),

      drawerHighlightItemColor: Color(0x33D4AF37),

      mainToolbarBackgroundColor: Color(0xFF7E5C31),

      mainToolbarIconColor: Color(0xFFFCF4D9),

      navigationToolbarBackgroundColor: Color(0xFF7E5C31),

      navigationToolbarIconColor: Color(0xFFFCF4D9),

      analysisToolbarBackgroundColor: Color(0xFF7E5C31),

      analysisToolbarIconColor: Color(0xFFFCF4D9),

      annotationToolbarBackgroundColor: Color(0xFF7E5C31),
      annotationToolbarIconColor: Color(0xFFFCF4D9),
    ),
    ColorTheme.gothicIce: const ColorSettings(
      boardBackgroundColor: Color(0xFFE8F4FC),

      darkBackgroundColor: Color(0xFF1A2C42),

      boardLineColor: Color(0xFF264D73),

      whitePieceColor: Color(0xFFF0F7FF),

      blackPieceColor: Color(0xFF0D1F2D),

      pieceHighlightColor: Color(0xFFA1D6E6),

      messageColor: Color(0xFFA1D6E6),

      drawerColor: Color(0xFF1A2C42),

      drawerTextColor: Color(0xFFF0F7FF),

      drawerHighlightItemColor: Color(0x33A1D6E6),

      mainToolbarBackgroundColor: Color(0xFF1A2C42),

      mainToolbarIconColor: Color(0xFFA1D6E6),

      navigationToolbarBackgroundColor: Color(0xFF1A2C42),

      navigationToolbarIconColor: Color(0xFFA1D6E6),

      analysisToolbarBackgroundColor: Color(0xFF1A2C42),

      analysisToolbarIconColor: Color(0xFFA1D6E6),

      annotationToolbarBackgroundColor: Color(0xFF1A2C42),
      annotationToolbarIconColor: Color(0xFFA1D6E6),
    ),
    ColorTheme.riceField: const ColorSettings(
      boardBackgroundColor: Color(0xFFF0E9D2),

      darkBackgroundColor: Color(0xFF678D58),

      boardLineColor: Color(0xFF4A593D),

      whitePieceColor: Color(0xFFF7F3E8),

      blackPieceColor: Color(0xFF33290A),

      pieceHighlightColor: Color(0xFFEACC62),

      messageColor: Color(0xFF4A593D),

      drawerColor: Color(0xFF678D58),

      drawerTextColor: Color(0xFFF7F3E8),

      drawerHighlightItemColor: Color(0x33EACC62),

      mainToolbarBackgroundColor: Color(0xFF678D58),

      mainToolbarIconColor: Color(0xFFF7F3E8),

      navigationToolbarBackgroundColor: Color(0xFF678D58),

      navigationToolbarIconColor: Color(0xFFF7F3E8),

      analysisToolbarBackgroundColor: Color(0xFF678D58),

      analysisToolbarIconColor: Color(0xFFF7F3E8),

      annotationToolbarBackgroundColor: Color(0xFF678D58),
      annotationToolbarIconColor: Color(0xFFF7F3E8),
    ),
    ColorTheme.chinesePorcelain: const ColorSettings(
      boardBackgroundColor: Color(0xFFF6FEFF),

      darkBackgroundColor: Color(0xFF0F5E87),

      boardLineColor: Color(0xFF13426B),

      whitePieceColor: Color(0xFFFCFCFC),

      blackPieceColor: Color(0xFF003366),

      pieceHighlightColor: Color(0xFF52B2BF),

      messageColor: Color(0xFFFCFCFC),

      drawerColor: Color(0xFF0F5E87),

      drawerTextColor: Color(0xFFFCFCFC),

      drawerHighlightItemColor: Color(0x3352B2BF),

      mainToolbarBackgroundColor: Color(0xFF0F5E87),

      mainToolbarIconColor: Color(0xFFFCFCFC),

      navigationToolbarBackgroundColor: Color(0xFF0F5E87),

      navigationToolbarIconColor: Color(0xFFFCFCFC),

      analysisToolbarBackgroundColor: Color(0xFF0F5E87),

      analysisToolbarIconColor: Color(0xFFFCFCFC),

      annotationToolbarBackgroundColor: Color(0xFF0F5E87),
      annotationToolbarIconColor: Color(0xFFFCFCFC),
    ),
    ColorTheme.desertDusk: const ColorSettings(
      boardBackgroundColor: Color(0xFFF0C18B),

      darkBackgroundColor: Color(0xFF6A3E35),

      boardLineColor: Color(0xFF4A2C28),

      whitePieceColor: Color(0xFFFEEBC1),

      blackPieceColor: Color(0xFF42283D),

      pieceHighlightColor: Color(0xFFE36161),

      messageColor: Color(0xFFFEEBC1),

      drawerColor: Color(0xFF6A3E35),

      drawerTextColor: Color(0xFFFEEBC1),

      drawerHighlightItemColor: Color(0x33E36161),

      mainToolbarBackgroundColor: Color(0xFF6A3E35),

      mainToolbarIconColor: Color(0xFFFEEBC1),

      navigationToolbarBackgroundColor: Color(0xFF6A3E35),

      navigationToolbarIconColor: Color(0xFFFEEBC1),

      analysisToolbarBackgroundColor: Color(0xFF6A3E35),

      analysisToolbarIconColor: Color(0xFFFEEBC1),

      annotationToolbarBackgroundColor: Color(0xFF6A3E35),
      annotationToolbarIconColor: Color(0xFFFEEBC1),
    ),
    ColorTheme.precisionCraft: const ColorSettings(
      boardBackgroundColor: Color(0xFFEEEEEE),

      darkBackgroundColor: Color(0xFF333333),

      boardLineColor: Color(0xFF222222),

      whitePieceColor: Color(0xFFF8F8F8),

      blackPieceColor: Color(0xFF1A1A1A),

      pieceHighlightColor: Color(0xFFDD0000),

      messageColor: Color(0xFFF8F8F8),

      drawerColor: Color(0xFF333333),

      drawerTextColor: Color(0xFFF8F8F8),

      drawerHighlightItemColor: Color(0x33FFCC00),

      mainToolbarBackgroundColor: Color(0xFF333333),

      mainToolbarIconColor: Color(0xFFF8F8F8),

      navigationToolbarBackgroundColor: Color(0xFF333333),

      navigationToolbarIconColor: Color(0xFFF8F8F8),

      analysisToolbarBackgroundColor: Color(0xFF333333),

      analysisToolbarIconColor: Color(0xFFF8F8F8),

      annotationToolbarBackgroundColor: Color(0xFF333333),
      annotationToolbarIconColor: Color(0xFFF8F8F8),
    ),
    ColorTheme.folkEmbroidery: const ColorSettings(
      boardBackgroundColor: Color(0xFFF5F2E9),

      darkBackgroundColor: Color(0xFF7E4E3B),

      boardLineColor: Color(0xFF6B3E26),

      whitePieceColor: Color(0xFFFFFCF0),

      blackPieceColor: Color(0xFF2B0F06),

      pieceHighlightColor: Color(0xFFD92121),

      messageColor: Color(0xFFFFFCF0),

      drawerColor: Color(0xFF7E4E3B),

      drawerTextColor: Color(0xFFFFFCF0),

      drawerHighlightItemColor: Color(0x3345A145),

      mainToolbarBackgroundColor: Color(0xFF7E4E3B),

      mainToolbarIconColor: Color(0xFFFFFCF0),

      navigationToolbarBackgroundColor: Color(0xFF7E4E3B),

      navigationToolbarIconColor: Color(0xFFFFFCF0),

      analysisToolbarBackgroundColor: Color(0xFF7E4E3B),

      analysisToolbarIconColor: Color(0xFFFFFCF0),

      annotationToolbarBackgroundColor: Color(0xFF7E4E3B),
      annotationToolbarIconColor: Color(0xFFFFFCF0),
    ),
    ColorTheme.carpathianHeritage: const ColorSettings(
      boardBackgroundColor: Color(0xFFF2E8D5),

      darkBackgroundColor: Color(0xFF2C4770),

      boardLineColor: Color(0xFF1F3356),

      whitePieceColor: Color(0xFFF9F0DD),

      blackPieceColor: Color(0xFF231F20),

      pieceHighlightColor: Color(0xFFCE1126),

      messageColor: Color(0xFFF9F0DD),

      drawerColor: Color(0xFF2C4770),

      drawerTextColor: Color(0xFFF9F0DD),

      drawerHighlightItemColor: Color(0x33FCD116),

      mainToolbarBackgroundColor: Color(0xFF2C4770),

      mainToolbarIconColor: Color(0xFFF9F0DD),

      navigationToolbarBackgroundColor: Color(0xFF2C4770),

      navigationToolbarIconColor: Color(0xFFF9F0DD),

      analysisToolbarBackgroundColor: Color(0xFF2C4770),

      analysisToolbarIconColor: Color(0xFFF9F0DD),

      annotationToolbarBackgroundColor: Color(0xFF2C4770),
      annotationToolbarIconColor: Color(0xFFF9F0DD),
    ),
    ColorTheme.imperialGrandeur: const ColorSettings(
      boardBackgroundColor: Color(0xFFF5E7C1),

      darkBackgroundColor: Color(0xFF2A1E5C),

      boardLineColor: Color(0xFF1A1240),

      whitePieceColor: Color(0xFFF8F3E3),

      blackPieceColor: Color(0xFF0F0A26),

      pieceHighlightColor: Color(0xFFD4AF37),

      messageColor: Color(0xFFD4AF37),

      drawerColor: Color(0xFF2A1E5C),

      drawerTextColor: Color(0xFFF8F3E3),

      drawerHighlightItemColor: Color(0x33CC0000),

      mainToolbarBackgroundColor: Color(0xFF2A1E5C),

      mainToolbarIconColor: Color(0xFFD4AF37),

      navigationToolbarBackgroundColor: Color(0xFF2A1E5C),

      navigationToolbarIconColor: Color(0xFFD4AF37),

      analysisToolbarBackgroundColor: Color(0xFF2A1E5C),

      analysisToolbarIconColor: Color(0xFFD4AF37),

      annotationToolbarBackgroundColor: Color(0xFF2A1E5C),
      annotationToolbarIconColor: Color(0xFFD4AF37),
    ),
    ColorTheme.bohemianCrystal: const ColorSettings(
      boardBackgroundColor: Color(0xFFE6F2FF),

      darkBackgroundColor: Color(0xFF16456D),

      boardLineColor: Color(0xFF0F2F4C),

      whitePieceColor: Color(0xFFF7FBFF),

      blackPieceColor: Color(0xFF05172A),

      pieceHighlightColor: Color(0xFF9E0812),

      messageColor: Color(0xFFF7FBFF),

      drawerColor: Color(0xFF16456D),

      drawerTextColor: Color(0xFFF7FBFF),

      drawerHighlightItemColor: Color(0x3311457E),

      mainToolbarBackgroundColor: Color(0xFF16456D),

      mainToolbarIconColor: Color(0xFFF7FBFF),

      navigationToolbarBackgroundColor: Color(0xFF16456D),

      navigationToolbarIconColor: Color(0xFFF7FBFF),

      analysisToolbarBackgroundColor: Color(0xFF16456D),

      analysisToolbarIconColor: Color(0xFFF7FBFF),

      annotationToolbarBackgroundColor: Color(0xFF16456D),
      annotationToolbarIconColor: Color(0xFFF7FBFF),
    ),
    ColorTheme.savannaSunrise: const ColorSettings(
      boardBackgroundColor: Color(0xFFF2E4C0),

      darkBackgroundColor: Color(0xFF4A5E2F),

      boardLineColor: Color(0xFF374825),

      whitePieceColor: Color(0xFFFFF8E1),

      blackPieceColor: Color(0xFF24281A),

      pieceHighlightColor: Color(0xFFE05D00),

      messageColor: Color(0xFFFFF8E1),

      drawerColor: Color(0xFF4A5E2F),

      drawerTextColor: Color(0xFFFFF8E1),

      drawerHighlightItemColor: Color(0x33F1C40F),

      mainToolbarBackgroundColor: Color(0xFF4A5E2F),

      mainToolbarIconColor: Color(0xFFFFF8E1),

      navigationToolbarBackgroundColor: Color(0xFF4A5E2F),

      navigationToolbarIconColor: Color(0xFFFFF8E1),

      analysisToolbarBackgroundColor: Color(0xFF4A5E2F),

      analysisToolbarIconColor: Color(0xFFFFF8E1),

      annotationToolbarBackgroundColor: Color(0xFF4A5E2F),
      annotationToolbarIconColor: Color(0xFFFFF8E1),
    ),
    ColorTheme.harmonyBalance: const ColorSettings(
      boardBackgroundColor: Color(0xFFF3F0E9),

      darkBackgroundColor: Color(0xFF263959),

      boardLineColor: Color(0xFF17263B),

      whitePieceColor: Color(0xFFFAF9F5),

      blackPieceColor: Color(0xFF0C1525),

      pieceHighlightColor: Color(0xFFE63946),

      messageColor: Color(0xFFFAF9F5),

      drawerColor: Color(0xFF263959),

      drawerTextColor: Color(0xFFFAF9F5),

      drawerHighlightItemColor: Color(0x33F9B42D),

      mainToolbarBackgroundColor: Color(0xFF263959),

      mainToolbarIconColor: Color(0xFFFAF9F5),

      navigationToolbarBackgroundColor: Color(0xFF263959),

      navigationToolbarIconColor: Color(0xFFFAF9F5),

      analysisToolbarBackgroundColor: Color(0xFF263959),

      analysisToolbarIconColor: Color(0xFFFAF9F5),

      annotationToolbarBackgroundColor: Color(0xFF263959),
      annotationToolbarIconColor: Color(0xFFFAF9F5),
    ),
    ColorTheme.cinnamonSpice: const ColorSettings(
      boardBackgroundColor: Color(0xFFE8D0B8),

      darkBackgroundColor: Color(0xFF5B4B3B),

      boardLineColor: Color(0xFF3C2F23),

      whitePieceColor: Color(0xFFFBF5EB),

      blackPieceColor: Color(0xFF231C14),

      pieceHighlightColor: Color(0xFF6AA168),

      messageColor: Color(0xFFFBF5EB),

      drawerColor: Color(0xFF5B4B3B),

      drawerTextColor: Color(0xFFFBF5EB),

      drawerHighlightItemColor: Color(0x33FF9800),

      mainToolbarBackgroundColor: Color(0xFF5B4B3B),

      mainToolbarIconColor: Color(0xFFFBF5EB),

      navigationToolbarBackgroundColor: Color(0xFF5B4B3B),

      navigationToolbarIconColor: Color(0xFFFBF5EB),

      analysisToolbarBackgroundColor: Color(0xFF5B4B3B),

      analysisToolbarIconColor: Color(0xFFFBF5EB),

      annotationToolbarBackgroundColor: Color(0xFF5B4B3B),
      annotationToolbarIconColor: Color(0xFFFBF5EB),
    ),
    ColorTheme.anatolianMosaic: const ColorSettings(
      boardBackgroundColor: Color(0xFFF1EEEA),

      darkBackgroundColor: Color(0xFF1E5F8C),

      boardLineColor: Color(0xFF1A4A6E),

      whitePieceColor: Color(0xFFFAF6F0),

      blackPieceColor: Color(0xFF0A2638),

      pieceHighlightColor: Color(0xFFD81B60),

      messageColor: Color(0xFFFAF6F0),

      drawerColor: Color(0xFF1E5F8C),

      drawerTextColor: Color(0xFFFAF6F0),

      drawerHighlightItemColor: Color(0x33E5A836),

      mainToolbarBackgroundColor: Color(0xFF1E5F8C),

      mainToolbarIconColor: Color(0xFFFAF6F0),

      navigationToolbarBackgroundColor: Color(0xFF1E5F8C),

      navigationToolbarIconColor: Color(0xFFFAF6F0),

      analysisToolbarBackgroundColor: Color(0xFF1E5F8C),

      analysisToolbarIconColor: Color(0xFFFAF6F0),

      annotationToolbarBackgroundColor: Color(0xFF1E5F8C),
      annotationToolbarIconColor: Color(0xFFFAF6F0),
    ),
    ColorTheme.carnivalSpirit: const ColorSettings(
      boardBackgroundColor: Color(0xFFFFF59B),

      darkBackgroundColor: Color(0xFF026873),

      boardLineColor: Color(0xFF01535E),

      whitePieceColor: Color(0xFFFFFDEC),

      blackPieceColor: Color(0xFF012E34),

      pieceHighlightColor: Color(0xFFFF5757),

      messageColor: Color(0xFFFFFDEC),

      drawerColor: Color(0xFF026873),

      drawerTextColor: Color(0xFFFFFDEC),

      drawerHighlightItemColor: Color(0x3376FF03),

      mainToolbarBackgroundColor: Color(0xFF026873),

      mainToolbarIconColor: Color(0xFFFFFDEC),

      navigationToolbarBackgroundColor: Color(0xFF026873),

      navigationToolbarIconColor: Color(0xFFFFFDEC),

      analysisToolbarBackgroundColor: Color(0xFF026873),

      analysisToolbarIconColor: Color(0xFFFFFDEC),

      annotationToolbarBackgroundColor: Color(0xFF026873),
      annotationToolbarIconColor: Color(0xFFFFFDEC),
    ),
    ColorTheme.spiceMarket: const ColorSettings(
      boardBackgroundColor: Color(0xFFF9E2B8),

      darkBackgroundColor: Color(0xFF9B2335),

      boardLineColor: Color(0xFF6F1D1B),

      whitePieceColor: Color(0xFFFFFFEB),

      blackPieceColor: Color(0xFF2E0E02),

      pieceHighlightColor: Color(0xFF00A550),

      messageColor: Color(0xFFFFEDBD),

      drawerColor: Color(0xFF9B2335),

      drawerTextColor: Color(0xFFFFEDBD),

      drawerHighlightItemColor: Color(0x33F9B529),

      mainToolbarBackgroundColor: Color(0xFF9B2335),

      mainToolbarIconColor: Color(0xFFFFEDBD),

      navigationToolbarBackgroundColor: Color(0xFF9B2335),

      navigationToolbarIconColor: Color(0xFFFFEDBD),

      analysisToolbarBackgroundColor: Color(0xFF9B2335),

      analysisToolbarIconColor: Color(0xFFFFEDBD),

      annotationToolbarBackgroundColor: Color(0xFF9B2335),
      annotationToolbarIconColor: Color(0xFFFFEDBD),
    ),
    ColorTheme.custom: const ColorSettings(),
  };


  static void updateCustomTheme(ColorSettings settings) {

    colorThemes[ColorTheme.custom] = settings;
  }
}

enum ColorTheme {
  current,
  light,
  dark,
  monochrome,
  transparentCanvas,
  autumnLeaves,
  legendaryLand,
  goldenJade,
  forestWood,
  greenMeadow,
  stonyPath,
  midnightBlue,
  greenForest,
  pastelPink,
  turquoiseSea,
  violetDream,
  mintChocolate,
  skyBlue,
  playfulGarden,
  darkMystery,
  ancientEgypt,
  gothicIce,
  riceField,
  chinesePorcelain,
  desertDusk,
  precisionCraft,
  folkEmbroidery,
  carpathianHeritage,
  imperialGrandeur,
  bohemianCrystal,
  savannaSunrise,
  harmonyBalance,
  cinnamonSpice,
  anatolianMosaic,
  carnivalSpirit,
  spiceMarket,
  custom,
}
