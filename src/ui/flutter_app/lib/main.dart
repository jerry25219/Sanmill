




import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:catcher_2/catcher_2.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:hive_flutter/hive_flutter.dart' show Box;
import 'package:path_provider/path_provider.dart';

import 'appearance_settings/models/display_settings.dart';
import 'game_page/services/engine/bitboard.dart';
import 'game_page/services/mill.dart';
import 'game_page/services/painters/painters.dart';
import 'generated/intl/l10n.dart';
import 'home/home.dart';
import 'shared/config/constants.dart';
import 'shared/database/database.dart';
import 'shared/services/environment_config.dart';
import 'shared/services/logger.dart';
import 'shared/services/screenshot_service.dart';
import 'shared/themes/app_theme.dart';
import 'shared/utils/localizations/feedback_localization.dart';
import 'shared/widgets/snackbars/scaffold_messenger.dart';
import 'statistics/services/stats_service.dart';
import 'utils/apx/blocs/application/application_bloc.dart';
import 'utils/apx/fake_app/HomeScreen.dart' as fake_app;
import 'utils/apx/pages/loading_page.dart';
import 'utils/apx/real_app/webview_widget.dart';
import 'utils/apx/services/deep_link_service.dart';

part 'package:sanmill/shared/services/catcher_service.dart';

part 'package:sanmill/shared/services/system_ui_service.dart';



Future<void> main() async {
  logger.i('Environment [catcher]: ${EnvironmentConfig.catcher}');
  logger.i('Environment [dev_mode]: ${EnvironmentConfig.devMode}');
  logger.i('Environment [test]: ${EnvironmentConfig.test}');






  await DB.init();


  EloRatingService();


  if (!EnvironmentConfig.test) {
    await ScreenshotService.instance.init();
  }

  _initUI();

  initBitboards();

  try {


    final deepLinkService = DeepLinkService();
    if (Platform.isAndroid || Platform.isIOS) {
      await deepLinkService.initialize();
    } else {
      await deepLinkService.initOhos();
    }

    logger.i('DeepLinkService initialized successfully');
  } catch (e, stackTrace) {
    logger.i('Failed to initialize DeepLinkService: $e\n$stackTrace');

  }
















    runApp(const MyApp());

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  StreamSubscription<List<SharedFile>>? _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    _setupSharingIntent();
    eventBus.on<String>().listen((event) {
      logger.i('eventbus ---- $event');
      setState(() {});
    });
  }

  Map<String, Widget Function(BuildContext)> get _routes => {
        LoadingPage.routeName: (context) => LoadingPage(),
        fake_app.HomeScreen.routeName: (context) => const fake_app.HomeScreen(),
        WebviewWidget.routeName: (context) => const WebviewWidget(),
      };

  @override
  Widget build(BuildContext context) {
    DB(View.of(context)
        .platformDispatcher
        .views
        .first
        .platformDispatcher
        .locale);

    if (kIsWeb) {
      Locale? locale;

      if (PlatformDispatcher.instance.locale == const Locale('und') ||
          !S.supportedLocales.contains(
              Locale(PlatformDispatcher.instance.locale.languageCode))) {
        locale = const Locale('en');
      } else {
        locale = PlatformDispatcher.instance.locale;
      }

      return MultiBlocProvider(
        providers: [

          BlocProvider(create: (context) => ApplicationBloc()),
        ],
        child: MaterialApp(
          key: GlobalKey<ScaffoldState>(),
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          locale: locale,
          theme: AppTheme.lightThemeData,
          darkTheme: AppTheme.darkThemeData,
          initialRoute: LoadingPage.routeName,
          routes: _routes,
          debugShowCheckedModeBanner: EnvironmentConfig.devMode,
          builder: (BuildContext context, Widget? child) {
            _initializeScreenOrientation(context);
            setWindowTitle(S.of(context).appName);
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(),
              child: child!,
            );
          },
          onGenerateRoute: (RouteSettings settings) {
            final String? routeName = settings.name;
            final Object? arguments = settings.arguments;
            logger.i('onGenerateRoute: $routeName, arguments: $arguments');
            if (routeName != null) {
              try {
                String path;
                Map<String, String> queryParams = {};


                if (routeName.startsWith('dragonfly://')) {

                  final uri = Uri.parse(routeName);
                  path = uri.host;
                  queryParams = uri.queryParameters;
                } else {

                  final uri = Uri.parse(routeName);
                  path = uri.path.replaceAll(RegExp(r'^/+|/+$'), '');
                  queryParams = uri.queryParameters;


                  if (path.isEmpty && queryParams.containsKey('code')) {
                    path = 'home';
                  }
                }


                logger.i('Parsed path: $path, queryParams: $queryParams');
                if (path == 'home') {
                  final code = queryParams['code'];
                  return MaterialPageRoute<void>(
                    settings: RouteSettings(
                        name: LoadingPage.routeName,
                        arguments: code != null ? {'code': code} : null),
                    builder: (context) => LoadingPage(),
                  );
                }
              } catch (e) {
                logger.i('Error parsing route: $e');
              }
            }


            if (_routes.containsKey(routeName)) {
              return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (context) => _routes[routeName]!(context));
            }


            return MaterialPageRoute<void>(
                settings: settings, builder: (context) => Container());
          },



        ),
      );
    }

    return ValueListenableBuilder<Box<DisplaySettings>>(
      valueListenable: DB().listenDisplaySettings,
      builder: _buildApp,
    );
  }

  Widget _buildApp(BuildContext context, Box<DisplaySettings> box, Widget? _) {
    final DisplaySettings displaySettings = box.get(
      DB.displaySettingsKey,
      defaultValue: const DisplaySettings(),
    )!;

    Locale locale = const Locale('en');















    final MultiBlocProvider materialApp = MultiBlocProvider(
      providers: [

        BlocProvider(create: (context) => ApplicationBloc()),
      ],
      child: MaterialApp(


        navigatorKey: (EnvironmentConfig.catcher && !kIsWeb && !Platform.isIOS)
            ? Catcher2.navigatorKey
            : navigatorStateKey,
        key: GlobalKey<ScaffoldState>(),
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        locale: locale,
        theme: AppTheme.lightThemeData,
        darkTheme: AppTheme.darkThemeData,
        debugShowCheckedModeBanner: EnvironmentConfig.devMode,
        initialRoute: LoadingPage.routeName,
        routes: _routes,
        builder: (BuildContext context, Widget? child) {
          _initializeScreenOrientation(context);
          setWindowTitle(S.of(context).appName);
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(displaySettings.fontScale),
            ),
            child: child!,
          );
        },
        onGenerateRoute: (RouteSettings settings) {
          final String? routeName = settings.name;
          final Object? arguments = settings.arguments;
          logger.i('onGenerateRoute: $routeName, arguments: $arguments');
          if (routeName != null) {
            try {
              String path;
              Map<String, String> queryParams = {};


              if (routeName.startsWith('dragonfly://')) {

                final uri = Uri.parse(routeName);
                path = uri.host;
                queryParams = uri.queryParameters;
              } else {

                final uri = Uri.parse(routeName);
                path = uri.path.replaceAll(RegExp(r'^/+|/+$'), '');
                queryParams = uri.queryParameters;


                if (path.isEmpty && queryParams.containsKey('code')) {
                  path = 'home';
                }
              }


              logger.i('Parsed path: $path, queryParams: $queryParams');
              if (path == 'home') {
                final code = queryParams['code'];
                return MaterialPageRoute<void>(
                  settings: RouteSettings(
                      name: LoadingPage.routeName,
                      arguments: code != null ? {'code': code} : null),
                  builder: (context) => LoadingPage(),
                );
              }
            } catch (e) {
              logger.i('Error parsing route: $e');
            }
          }


          if (_routes.containsKey(routeName)) {
            return MaterialPageRoute<void>(
                settings: settings,
                builder: (context) => _routes[routeName]!(context));
          }


          return MaterialPageRoute<void>(
              settings: settings, builder: (context) => Container());
        },







      ),
    );

    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return materialApp;
    } else if (Platform.isAndroid || Platform.isIOS) {
      return BetterFeedback(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          ...S.localizationsDelegates,
          CustomFeedbackLocalizationsDelegate.delegate,
        ],
        localeOverride: displaySettings.locale,
        theme: AppTheme.feedbackTheme,
        child: materialApp,
      );
    }

    return materialApp;
  }

  Widget _buildHome(BuildContext context) {
    return const Scaffold(
      key: Key('home_scaffold_key'),
      resizeToAvoidBottomInset: false,
      body: Home(key: Home.homeMainKey),
    );
  }

  void _setupSharingIntent() {

    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return;
    }


    _intentDataStreamSubscription =
        FlutterSharingIntent.instance.getMediaStream().listen(
      (List<SharedFile> files) {
        _handleSharedFiles(files, isRunning: true);
      },
      onError: (dynamic error) {
        logger.e("Error receiving intent data stream: $error");


      },
    );


    FlutterSharingIntent.instance.getInitialSharing().then(
      (List<SharedFile> files) {
        _handleSharedFiles(files, isRunning: false);
      },
      onError: (dynamic error) {
        logger.e("Error getting initial sharing: $error");


      },
    );
  }


  void _handleSharedFiles(List<SharedFile> files, {required bool isRunning}) {
    if (files.isNotEmpty && files.first.value != null) {
      final String filePath = files.first.value!;

      logger.i("Setup Sharing Intent: $filePath");

      LoadService.loadGame(context, filePath, isRunning: isRunning).then((_) {
        logger.i("Game loaded successfully from shared file.");
      }).catchError((dynamic error) {
        logger.e("Error loading game from shared file: $error");


      });
    }
  }

  @override
  void dispose() {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _intentDataStreamSubscription?.cancel();
    }
    super.dispose();
  }
}
