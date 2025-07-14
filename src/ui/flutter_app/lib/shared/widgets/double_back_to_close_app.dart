




import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef WillBackCall = bool Function();








class DoubleBackToCloseApp extends StatefulWidget {


  const DoubleBackToCloseApp({
    super.key,
    required this.snackBar,
    required this.child,
    this.willBack,
  });


  final SnackBar snackBar;


  final Widget child;


  final WillBackCall? willBack;

  @override
  State<DoubleBackToCloseApp> createState() => _DoubleBackToCloseAppState();
}

class _DoubleBackToCloseAppState extends State<DoubleBackToCloseApp> {

  Completer<SnackBarClosedReason> _closedCompleter =
      Completer<SnackBarClosedReason>()..complete(SnackBarClosedReason.remove);


  bool get _isAndroid => Theme.of(context).platform == TargetPlatform.android;


  bool get _isSnackBarVisible => !_closedCompleter.isCompleted;







  bool get _willHandlePopInternally =>
      ModalRoute.of(context)?.willHandlePopInternally ?? false;

  @override
  Widget build(BuildContext context) {
    assert(() {
      _ensureThatContextContainsScaffold();
      return true;
    }());

    if (_isAndroid) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: _handleWillPop,
        child: widget.child,
      );
    } else {
      return widget.child;
    }
  }


  Future<bool> _handleWillPop(bool didPop, dynamic result) async {
    if (didPop) {
      return false;
    }

    if (widget.willBack != null && !widget.willBack!.call()) {
      return false;
    }

    if (_isSnackBarVisible || _willHandlePopInternally) {
      SystemNavigator.pop();
      return true;
    } else {
      final ScaffoldMessengerState scaffoldMessenger =
          ScaffoldMessenger.of(context);
      scaffoldMessenger.hideCurrentSnackBar();
      _closedCompleter = scaffoldMessenger
          .showSnackBar(widget.snackBar)
          .closed
          .wrapInCompleter();
      return false;
    }
  }


  void _ensureThatContextContainsScaffold() {
    if (Scaffold.maybeOf(context) == null) {
      throw FlutterError(
        '`DoubleBackToCloseApp` must be wrapped in a `Scaffold`.',
      );
    }
  }
}

extension<T> on Future<T> {



  Completer<T> wrapInCompleter() {
    final Completer<T> completer = Completer<T>();
    then(completer.complete).catchError(completer.completeError);
    return completer;
  }
}
