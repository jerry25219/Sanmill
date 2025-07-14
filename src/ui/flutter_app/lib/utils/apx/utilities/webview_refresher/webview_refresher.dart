
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'src/gesture_recognizer.dart';


typedef DefaultRefreshBuilder = Widget Function(
    RefreshCallback? onRefresh, Widget child);


class WebviewRefresher extends StatefulWidget {
  const WebviewRefresher({
    super.key,
    this.controller,
    this.scrollController,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
    this.onRefresh,
    this.platform,
    this.androidRefresherBuilder = _defaultAndroidBuilder,
    this.iosRefreshBuilder = _defaultIosBuilder,
    this.defaultRefresherBuilder = _defaultRefreshBuilder,
    this.isRefresherEnabled = true,
  });
  final bool isRefresherEnabled;


  final WebViewController? controller;




  final ScrollController? scrollController;


  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;


  final RefreshCallback? onRefresh;




  final TargetPlatform? platform;


  final DefaultRefreshBuilder androidRefresherBuilder;




  final DefaultRefreshBuilder defaultRefresherBuilder;


  final DefaultRefreshBuilder iosRefreshBuilder;

  static Widget _defaultAndroidBuilder(
      RefreshCallback? onRefresh, Widget child) {
    return RefreshIndicator.adaptive(
      onRefresh: () async => await onRefresh?.call(),
      notificationPredicate: (notification) {
        if (onRefresh == null) return false;
        return notification.depth == 0;
      },
      child: child,
    );
  }

  static Widget _defaultIosBuilder(RefreshCallback? onRefresh, Widget child) {
    return RefreshIndicator(
      onRefresh: () async => await onRefresh?.call(),
      notificationPredicate: (notification) {
        if (onRefresh == null) return false;
        return notification.depth == 0;
      },
      child: child,
    );
  }

  static Widget _defaultRefreshBuilder(
      RefreshCallback? onRefresh, Widget child) {
    return child;
  }

  @override
  State<WebviewRefresher> createState() => _WebviewRefresherState();
}

class _WebviewRefresherState extends State<WebviewRefresher> {
  late WebViewController _controller = widget.controller ?? WebViewController();
  late ScrollController _scrollController =
      widget.scrollController ?? ScrollController();
  final _currentOffset = ValueNotifier<double>(0);
  final _canRefresh = ValueNotifier<bool>(true);
  bool _isRefresherEnabled = true;

  @override
  void initState() {
    super.initState();
    _updateRefresherState();
    _controller.setOnScrollPositionChange((change) {
      _currentOffset.value = change.y;
    });
    _isRefresherEnabled = widget.isRefresherEnabled;
  }

  _updateRefresherState() {
    _canRefresh.value = widget.onRefresh != null;
  }

  @override
  void didUpdateWidget(covariant WebviewRefresher oldWidget) {
    final oldController = oldWidget.controller;
    if (widget.controller != null && oldController != _controller) {
      _controller = widget.controller!;
    }
    final oldScrollController = oldWidget.scrollController;
    if (widget.scrollController != null &&
        oldScrollController != _scrollController) {
      _scrollController = widget.scrollController!;
    }
    _updateRefresherState();
    if(widget.isRefresherEnabled != _isRefresherEnabled) {
      _isRefresherEnabled = widget.isRefresherEnabled;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    _currentOffset.dispose();
    _canRefresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final platform = widget.platform ?? defaultTargetPlatform;
    Widget webview = WebViewWidget(
      controller: _controller,
      gestureRecognizers: {
        if (platform != TargetPlatform.android ||
            platform != TargetPlatform.iOS)
          Factory(() => WebviewGestureRecognizer(
                scrollController: _scrollController,
                context: context,
                offset: _currentOffset,
                refreshState: _canRefresh,
              )),
        ...widget.gestureRecognizers,
      },
    );
    if(_isRefresherEnabled) {
      return switch (platform) {
        TargetPlatform.android => _buildAndroid(webview),
        TargetPlatform.iOS => _buildIos(webview),
        _ => _buildDefault(webview),
      };
    } else {
      return webview;
    }
  }

  Widget _buildAndroid(Widget webview) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return widget.androidRefresherBuilder(
          widget.onRefresh,
          SingleChildScrollView(
            controller: _scrollController,
            child: SizedBox(height: constraints.maxHeight, child: webview),
          ),
        );
      },
    );
  }

  Widget _buildIos(Widget webview) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return widget.iosRefreshBuilder(
          widget.onRefresh,
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            controller: _scrollController,
            child: SizedBox(height: constraints.maxHeight, child: webview),
          ),
        );
      },
    );
  }

  Widget _buildDefault(Widget webview) {
    return widget.defaultRefresherBuilder(widget.onRefresh, webview);
  }
}
