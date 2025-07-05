// import 'package:dealer/src/blocs/user/user_bloc.dart';
// import 'package:dealer/src/features/match/presentation/bloc/match_bloc.dart';
// import 'package:dealer/src/features/match/presentation/pages/match_page.dart';
// import 'package:dealer/src/screens/register/reigster_screen.dart';
// import 'package:dealer/src/screens/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';

import 'blocs/application/application_bloc.dart';
import 'fake_app/HomeScreen.dart' as fake_app;
import 'fake_app/HomeScreen.dart' as real_app;
import 'pages/loading_page.dart';
import 'services/deep_link_service.dart';
import 'services/navigation_service.dart';
import 'utilities/debug_print_output.dart';

final logger = Logger(
    printer: PrettyPrinter(
        methodCount: 0, dateTimeFormat: DateTimeFormat.dateAndTime),
    output: DebugPrintOutput(),
    level: Level.all);
/// The Widget that configures your application.
class Application extends StatefulWidget {
  Application({super.key /*required this.settingsController*/});

  // final SettingsController settingsController;

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> with WidgetsBindingObserver {

  Map<String, Widget Function(BuildContext)> get _routes => {
        // MainScreen.routeName: (context) => const MainScreen(),
        LoadingPage.routeName: (context) => LoadingPage(),
        fake_app.HomeScreen.routeName: (context) => const fake_app.HomeScreen(),
        real_app.HomeScreen.routeName: (context) => const real_app.HomeScreen(),
        // WelcomeScreen.routeName: (context) => const WelcomeScreen(),
        // RegisterScreen.routeName: (context) => const RegisterScreen(),
        // MatchPage.routeName: (context) => const MatchPage(),
      };

  @override
  void initState() {
    super.initState();
    eventBus.on<String>().listen((event){
      logger.i('eventbus ---- $event');
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ApplicationBloc()),
        ],
        child: MaterialApp(
          title: 'Math Learning',
          navigatorKey: NavigationService.navigatorKey,
          restorationScopeId: 'app',
          localizationsDelegates: const [
            // AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            buttonTheme: const ButtonThemeData(
                textTheme: ButtonTextTheme.primary,
                colorScheme: ColorScheme.light()),
          ),
          darkTheme: ThemeData.dark(),
          initialRoute: LoadingPage.routeName,
          routes: _routes,
          onGenerateRoute: (RouteSettings settings) {
            final String? routeName = settings.name;
            final Object? arguments = settings.arguments;
            logger.i('onGenerateRoute: $routeName, arguments: $arguments');
            if (routeName != null) {
              try {
                String path;
                Map<String, String> queryParams = {};
                /// URI-:dragonfly://home?code=6580677a-4cb8-4f0f-91db-ee8933892d97[0m
                if (routeName.startsWith('dragonfly://')) {
                  // Handle full deep link URI
                  final uri = Uri.parse(routeName);
                  path = uri.host;
                  queryParams = uri.queryParameters;
                } else {
                  // Handle stripped path format (e.g. "/?code=1234abcd")
                  final uri = Uri.parse(routeName);
                  path = uri.path.replaceAll(RegExp(r'^/+|/+$'), '');
                  queryParams = uri.queryParameters;

                  // If path is empty and we have query params, assume it's the home route
                  if (path.isEmpty && queryParams.containsKey('code')) {
                    path = 'home';
                  }
                }

                // Process routes
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

            // Handle regular routes
            if (_routes.containsKey(routeName)) {
              return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (context) => _routes[routeName]!(context));
            }

            // Return empty container for undefined routes
            return MaterialPageRoute<void>(
                settings: settings, builder: (context) => Container());
          },
        ),
      );
}
