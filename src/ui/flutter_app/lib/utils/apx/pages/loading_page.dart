import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../app.dart';
import '../blocs/application/application_bloc.dart';
import '../blocs/application/events.dart';
import '../blocs/application/state.dart';
import '../services/deep_link_service.dart';

class LoadingPage extends StatefulWidget {
  static const String routeName = '/';

  LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final applicationBloc = context.read<ApplicationBloc>();

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final code = args?['code'] as String? ?? inviteCode;

     if ((code != null && code.isNotEmpty || (applicationBloc.state is! ApplicationReadyState)) && (applicationBloc.state is! ApplicationRegisteringState)) {
      applicationBloc.add(ApplicationBeginRegisterEvent(invitationCode: code));
      logger.i('Starting registration with code: $code');
    } else {
      logger.i('No invitation code provided, starting registration without it');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ApplicationBloc, ApplicationState>(
        listener: (context, state) {
          if (state is ApplicationReadyState) {
            try {

              logger.i('Navigating to home page with state: $state');



              final hasValidDomains = state.domains?.isNotEmpty ?? false;
              logger.i('Has valid domains: $hasValidDomains');

              final route = hasValidDomains ? '/real_app/home' : '/fake_app/home';
              logger.i('Navigating to route: $route');

              if (mounted) {

                logger.i('Pushing replacement route: $route');
                Navigator.of(context).pushReplacementNamed(route);
              } else {
                logger.i('Context is not mounted, cannot navigate');
              }
            } catch (e, stackTrace) {
              logger.i('Navigation error: $e\n$stackTrace');

              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/fake_app/home');
              }
            }
          } else {

            logger.i('Current state: $state');
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/icons/background.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
