import 'package:flutter/material.dart';

import '../../../home/home.dart';
import '../pages/loading_page.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/fake_app/home';
  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: Key('home_scaffold_key'),
      resizeToAvoidBottomInset: false,
      body: Home(key: Home.homeMainKey),
    );
  }
}
