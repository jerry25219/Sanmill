




part of 'package:sanmill/main.dart';

late Catcher2 catcher;


Future<void> _initCatcher(Catcher2 catcher) async {
  final Map<String, String> customParameters = <String, String>{};
  late final String externalDirStr;

  if (kIsWeb ||
      Platform.isIOS ||
      Platform.isLinux ||
      Platform.isWindows ||
      Platform.isMacOS) {
    externalDirStr = ".";
  } else {
    try {
      final Directory? externalDir = await getExternalStorageDirectory();
      externalDirStr = externalDir != null ? externalDir.path : ".";
    } catch (e) {
      logger.e(e.toString());
      externalDirStr = ".";
    }
  }

  final String path = "$externalDirStr/${Constants.crashLogsFile}";
  logger.t("[env] ExternalStorageDirectory: $externalDirStr");

  final Catcher2Options debugOptions = Catcher2Options(
      kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS
          ? SilentReportMode()
          : PageReportMode(),
      <ReportHandler>[
        ConsoleHandler(),
        FileHandler(File(path), printLogs: true),
        EmailManualHandler(Constants.recipientEmails, printLogs: true)
      ],
      customParameters: customParameters);




  final Catcher2Options releaseOptions = Catcher2Options(
      kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS
          ? SilentReportMode()
          : PageReportMode(),
      <ReportHandler>[
        FileHandler(File(path), printLogs: true),
        EmailManualHandler(Constants.recipientEmails, printLogs: true)
      ],
      customParameters: customParameters);

  final Catcher2Options profileOptions = Catcher2Options(
      PageReportMode(),
      <ReportHandler>[
        ConsoleHandler(),
        FileHandler(File(path), printLogs: true),
        EmailManualHandler(Constants.recipientEmails, printLogs: true)
      ],
      customParameters: customParameters);


  catcher.updateConfig(
    debugConfig: debugOptions,
    releaseConfig: releaseOptions,
    profileConfig: profileOptions,
  );
}


String generateOptionsContent() {
  String content = "";

  if (EnvironmentConfig.catcher && !kIsWeb && !Platform.isIOS) {
    final Catcher2Options options = catcher.getCurrentConfig()!;
    for (final dynamic value in options.customParameters.values) {
      final String str = value
          .toString()
          .replaceAll("setoption name ", "")
          .replaceAll("value", "=");
      content += "$str\n";
    }
  }

  return content;
}
