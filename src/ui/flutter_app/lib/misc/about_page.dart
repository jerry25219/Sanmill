




import 'dart:io';

import 'package:catcher_2/core/catcher_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../custom_drawer/custom_drawer.dart';
import '../generated/flutter_version.dart';
import '../generated/intl/l10n.dart';
import '../shared/config/constants.dart';
import '../shared/services/git_info.dart';
import '../shared/services/url.dart';
import '../shared/themes/app_theme.dart';
import '../shared/widgets/custom_spacer.dart';
import '../shared/widgets/settings/settings.dart';
import 'license_agreement_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  String? get mode {
    if (kDebugMode) {
      return "- debug";
    } else if (kProfileMode) {
      return "- profile";
    } else if (kReleaseMode) {
      return "";
    } else {
      return "-test";
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> settingsItems = <Widget>[
      FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (_, AsyncSnapshot<PackageInfo> data) {
          final String version;
          if (!data.hasData) {
            return Container();
          } else {
            final PackageInfo packageInfo = data.data!;
            if (kIsWeb || Platform.isWindows || Platform.isLinux) {
              version = packageInfo.version;
            } else {
              version = "${packageInfo.version} (${packageInfo.buildNumber})";
            }
          }
          return SettingsListTile(
            key: const Key('settings_list_tile_version_info'),
            titleString: S.of(context).versionInfo,
            subtitleString: "${Constants.projectName} $version",
            onTap: () => showDialog(
              context: context,
              builder: (_) =>  _VersionDialog(
                appVersion: version,
              ),
            ),
          );
        },
      ),































      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
        SettingsListTile(
          key: const Key('settings_list_tile_privacy_policy'),
          titleString: S.of(context).privacyPolicy,
          onTap: () {
            launchUrl(Uri.parse("https://privacy.system-fly.com/privacy.html"),
                mode: LaunchMode.inAppWebView);
          },
        ),























    ];

    return BlockSemantics(
      child: Scaffold(
        key: const Key('about_page_scaffold'),
        resizeToAvoidBottomInset: false,

        appBar: AppBar(
          key: const Key('about_page_appbar'),
          leading: CustomDrawerIcon.of(context)?.drawerIcon,
          title: Text(
            S.of(context).about,
            style: AppTheme.appBarTheme.titleTextStyle,
          ),
        ),
        body: ListView.separated(
          key: const Key('about_page_listview'),
          itemBuilder: (_, int index) => settingsItems[index],
          separatorBuilder: (_, __) => const Divider(),
          itemCount: settingsItems.length,
        ),
      ),
    );
  }
}

class _VersionDialog extends StatelessWidget {
  const _VersionDialog({
    required this.appVersion,
  });

  final String appVersion;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('version_dialog'),
      title: Text(
        S.of(context).appName,
        style: AppTheme.dialogTitleTextStyle,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            S.of(context).version(appVersion),
            style: TextStyle(
                fontSize: AppTheme.textScaler.scale(AppTheme.defaultFontSize)),
          ),
          const CustomSpacer(),
          FutureBuilder<GitInfo>(
            future: gitInfo,
            builder: (BuildContext context, AsyncSnapshot<GitInfo> snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Branch: ${snapshot.data!.branch}',
                        style: TextStyle(
                            fontSize: AppTheme.textScaler
                                .scale(AppTheme.defaultFontSize)),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Revision: ${snapshot.data!.revision}',
                        style: TextStyle(
                            fontSize: AppTheme.textScaler
                                .scale(AppTheme.defaultFontSize)),
                      ),
                    ),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
      actions: <Widget>[
















        TextButton(
          key: const Key('version_dialog_ok_button'),
          child: Text(
            S.of(context).ok,
            style: TextStyle(
                fontSize: AppTheme.textScaler.scale(AppTheme.defaultFontSize)),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class FlutterVersionAlert extends StatefulWidget {
  const FlutterVersionAlert({super.key});

  @override
  FlutterVersionAlertState createState() => FlutterVersionAlertState();
}

class FlutterVersionAlertState extends State<FlutterVersionAlert> {
  String formattedFlutterVersion = "";
  int tapCount = 0;
  DateTime startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    formattedFlutterVersion = flutterVersion.toString();
    formattedFlutterVersion = formattedFlutterVersion
        .replaceAll("{", "")
        .replaceAll("}", "")
        .replaceAll(", ", "\n");
    formattedFlutterVersion = formattedFlutterVersion.substring(
        0, formattedFlutterVersion.indexOf("flutterRoot"));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('flutter_version_alert_dialog'),
      title: Text(
        S.of(context).more,
        style: AppTheme.dialogTitleTextStyle,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            key: const Key('version_dialog_gesture_detector'),
            onTap: () {
              setState(() {
                tapCount++;
                if (tapCount >= 10 &&
                    DateTime.now().difference(startTime).inSeconds <= 10) {

                  Catcher2.sendTestException();
                }
              });
            },
            child: Text(
              formattedFlutterVersion,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          key: const Key('flutter_version_alert_ok_button'),
          child: Text(
            S.of(context).ok,
            style: TextStyle(
                fontSize: AppTheme.textScaler.scale(AppTheme.defaultFontSize)),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
