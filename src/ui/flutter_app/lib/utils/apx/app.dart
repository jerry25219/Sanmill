




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

class Application extends StatefulWidget {
  Application({super.key });



  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> with WidgetsBindingObserver {

  Map<String, Widget Function(BuildContext)> get _routes => {

        LoadingPage.routeName: (context) => LoadingPage(),
        fake_app.HomeScreen.routeName: (context) => const fake_app.HomeScreen(),
        real_app.HomeScreen.routeName: (context) => const real_app.HomeScreen(),



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
