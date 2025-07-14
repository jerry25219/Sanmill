




part of '../mill.dart';

class ExportService {
  const ExportService._();


  static Future<void> exportGame(BuildContext context,
      {bool shouldPop = true}) async {
    await Clipboard.setData(
      ClipboardData(text: GameController().gameRecorder.moveHistoryText),
    );

    if (!context.mounted) {
      return;
    }

    rootScaffoldMessengerKey.currentState!
        .showSnackBarClear(S.of(context).moveHistoryCopied);

    if (shouldPop) {
      Navigator.pop(context);
    }
  }
}
