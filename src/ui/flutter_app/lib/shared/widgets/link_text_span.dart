




import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/environment_config.dart';

class LinkTextSpan extends TextSpan {
  LinkTextSpan({super.style, required String url, String? text})
      : super(
          text: text ?? url,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (EnvironmentConfig.test == true) {
                return;
              }
              final String s = url.substring("https://".length);
              final String authority = s.substring(0, s.indexOf('/'));
              final String unencodedPath = s.substring(s.indexOf('/'));
              final Uri uri = Uri.https(authority, unencodedPath);
              launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
            },
        );
}
