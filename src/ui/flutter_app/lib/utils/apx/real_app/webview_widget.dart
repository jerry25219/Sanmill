import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../blocs/application/application_bloc.dart';
import '../blocs/application/state.dart';
import '../utilities/webview_refresher/webview_refresher.dart';

class WebviewWidget extends StatefulWidget {
  static const String routeName = '/real_app/home';

  const WebviewWidget({super.key});

  @override
  State<WebviewWidget> createState() => _WebviewWidgetState();
}

class _WebviewWidgetState extends State<WebviewWidget>
    with WidgetsBindingObserver {
  final controller = WebViewController();
  Completer<void>? _completer;

  bool _isExitWarningActive = false;
  Timer? _exitTimer;
  bool _hasError = false;
  StreamSubscription<List<ConnectivityResult>>? _streamSubscription;
  ValueNotifier<int> loadProgress = ValueNotifier<int>(0);
  bool _enableRefresh = true;

  // ignore: strict_raw_type
  Future onRefresh() async {
    final connectivity = await Connectivity().checkConnectivity();
    final isOffline = connectivity.contains(ConnectivityResult.none);
    if (isOffline) {
      return;
    } else {
      _completer = Completer<void>();
      final currentUrl = await controller.currentUrl();
      if (currentUrl == null) {
        await forward();
      } else {
        await controller.reload();
      }
      await _completer!.future;
    }
  }

  Future<void> forward() async {
    final ApplicationReadyState state =
        context.read<ApplicationBloc>().state as ApplicationReadyState;
    await controller.loadRequest(
      Uri.parse('https://${state.domains?.first ?? 'www.system-screen.com'}/'),
    );
  }

  void finishRefresh() {
    if (_completer == null) return;
    if (!_completer!.isCompleted) {
      _completer?.complete();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      String? userAgent = await controller.getUserAgent();
      if (kDebugMode) {
        print('Current User Agent: $userAgent');
      }
      if (userAgent == null || userAgent.isEmpty) {
        userAgent = 'match-learn';
      } else {
        userAgent = '$userAgent match-learn';
      }
      controller.setUserAgent(userAgent);
      forward();
    });
    // controller.setUserAgent('match-learn');

    // Enable WebView features for proper image loading
    controller.enableZoom(false);
    controller.setBackgroundColor(const Color.fromARGB(255, 30, 31, 34));

    // Configure WebView settings
    controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (url) {
          if (_hasError) {
            _hasError = false;
          }
          _enableRefresh = true;
          setState(() {});
          finishRefresh();
        },
        onProgress: (int progress) {
          loadProgress.value = progress;
          if (progress == 100) {
            finishRefresh();
          }
        },
        onWebResourceError: (error) async {
          finishRefresh();
          final List<ConnectivityResult> connectivity =
              await Connectivity().checkConnectivity();
          final bool isOffline = connectivity.contains(ConnectivityResult.none);

          if (isOffline &&
              (error.errorType == WebResourceErrorType.connect ||
                  error.errorType == WebResourceErrorType.hostLookup ||
                  error.errorType == WebResourceErrorType.timeout) &&
              loadProgress.value < 100) {
            setState(() {
              _hasError = true;
            });
          }
        },
        onHttpError: (HttpResponseError error) {
          if (kDebugMode) {
            print('HTTP Error: ${error.response}');
          }
          finishRefresh();
        },
        onHttpAuthRequest: (request) {},
        onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      ),
    );

    controller.addJavaScriptChannel(
      'APP_BRIDGE',
      onMessageReceived: (JavaScriptMessage msg) {
        final Map<String, dynamic> payload =
            jsonDecode(msg.message) as Map<String, dynamic>;
        final type = payload['type'];
        final data = payload['data'];
        if (type == 'popup') {
          bool show = data as bool;
          setState(() {
            _enableRefresh = !show;
          });
        }
        print('payload -- $payload');
      },
    );

    /// 监听网络连接状态变化
    _streamSubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (!result.contains(ConnectivityResult.none)) {
        setState(() {
          _hasError = false;
        });
        controller.reload();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _hasError) {
      controller.reload();
    }
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    _streamSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }

        if (await controller.canGoBack()) {
          controller.goBack();
        } else {
          if (_isExitWarningActive) {
            // User pressed back twice within the time window, exit the app
            _exitTimer?.cancel();
            SystemNavigator.pop();
          } else {
            // First back press, show warning and start timer
            _isExitWarningActive = true;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('再按一次返回键退出应用'),
                duration: Duration(seconds: 1),
              ),
            );

            _exitTimer = Timer(const Duration(milliseconds: 1500), () {
              _isExitWarningActive = false;
            });
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 30, 31, 34),
        body: SafeArea(
          child: _hasError
              ? _networkError()
              : Stack(
                  children: [
                    WebviewRefresher(
                      isRefresherEnabled: _enableRefresh,
                      onRefresh: onRefresh,
                      controller: controller,
                      platform: Platform.isAndroid
                          ? TargetPlatform.android
                          : TargetPlatform.iOS,
                    ),
                    // 进度条
                    Align(
                      alignment: Alignment.topCenter,
                      child: ValueListenableBuilder<int>(
                        valueListenable: loadProgress,
                        builder: (context, progress, child) {
                          if (progress == 100) {
                            return const SizedBox.shrink();
                          }
                          return LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: Colors.transparent,
                            color: Colors.blue,
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _networkError() {
    final ThemeData themeData = Theme.of(context);

    /// 日夜间模式判断
    final bool isDarkMode = themeData.brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.network_check_outlined,
            size: 100,
            color: Colors.white24,
          ),
          SizedBox(
            height: 10,
          ),
          const Text(
            '网络异常',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              onRefresh();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(12),
              child: const Text(
                '点击重试',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
