






import 'package:flutter/material.dart';

import '../services/mill.dart';


class AnalysisMode {
  static bool _isEnabled = false;
  static List<MoveAnalysisResult> _analysisResults = <MoveAnalysisResult>[];


  static bool _isAnalyzing = false;


  static final ValueNotifier<bool> stateNotifier = ValueNotifier<bool>(false);


  static bool get isEnabled => _isEnabled;


  static bool get isAnalyzing => _isAnalyzing;


  static List<MoveAnalysisResult> get analysisResults => _analysisResults;


  static void enable(List<MoveAnalysisResult> results) {
    _analysisResults = results;
    _isEnabled = true;
    _isAnalyzing = false;

    stateNotifier.value = true;
  }


  static void disable() {
    _analysisResults = <MoveAnalysisResult>[];
    _isEnabled = false;
    _isAnalyzing = false;

    stateNotifier.value = false;
  }


  static void setAnalyzing(bool analyzing) {
    _isAnalyzing = analyzing;
    stateNotifier.value = _isEnabled;
  }


  static void toggle(List<MoveAnalysisResult>? results) {
    if (_isEnabled) {
      disable();
    } else if (results != null && results.isNotEmpty) {
      enable(results);
    }
  }


  static Color getColorForOutcome(GameOutcome outcome) {
    switch (outcome) {
      case GameOutcome.win:
        return Colors.blue.shade600;
      case GameOutcome.draw:
        return Colors.grey.shade600;
      case GameOutcome.loss:
        return Colors.red.shade600;
      case GameOutcome.advantage:
        return Colors.blue.shade600;
      case GameOutcome.disadvantage:
        return Colors.red.shade600;
      case GameOutcome.unknown:
      default:
        return Colors.yellow.shade600;
    }
  }


  static double getOpacityForOutcome(GameOutcome outcome) {
    switch (outcome) {
      case GameOutcome.win:
        return 0.8;
      case GameOutcome.draw:
        return 0.7;
      case GameOutcome.loss:
        return 0.6;
      case GameOutcome.advantage:
        return 0.75;
      case GameOutcome.disadvantage:
        return 0.65;
      case GameOutcome.unknown:
      default:
        return 0.5;
    }
  }
}
