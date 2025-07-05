import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class DebugPrintOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    event.lines.forEach(debugPrint);
  }
}
