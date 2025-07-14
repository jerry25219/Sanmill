import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

import '../utilities/debug_print_output.dart';
import '../utilities/event_bus.dart';
import 'deep_link_data.dart';
EventBus eventBus = EventBus();
String? inviteCode;


class DeepLinkService {
  static final DeepLinkService _instance =
      DeepLinkService._internal(AppLinks());
  final _logger = Logger(
      printer: PrettyPrinter(
          methodCount: 0, dateTimeFormat: DateTimeFormat.dateAndTime),
      output: DebugPrintOutput(),
      level: Level.all);
  static final _channel = const BasicMessageChannel<String>(
    'samples.flutter.dev/deeplink_channel',
    StringCodec(),
  );


  factory DeepLinkService([AppLinks? appLinks]) =>
      appLinks == null ? _instance : DeepLinkService._internal(appLinks);


  final AppLinks _appLinks;


  DeepLinkService._internal(this._appLinks);


  final _subscriptions = CompositeSubscription();


  final _deepLinkStreamController = BehaviorSubject<DeepLinkData>();


  Stream<DeepLinkData> get deepLinkStream => _deepLinkStreamController.stream;


  bool _isInitialized = false;


  StreamSubscription<Uri?>? _uriSubscription;

  Future<void> initOhos() async {
    try {


















      _channel.setMessageHandler(
        (String? message) async {
          if (message == null || message.isEmpty) {
            return '';
          }
          _logger.i('Deep link OHOS initialized with URI 1-$message');


          String trimmedMessage = cleanUri(message);
          _logger.i('Deep link OHOS initialized with URI 2-$trimmedMessage');
          try {
            final uri = Uri.parse(trimmedMessage);
            _logger.i('Deep link OHOS initialized with URI 3-${uri.toString()} ${uri.scheme} ${uri.host} ${uri.queryParameters}');
            await _handleDeepLink(uri);
            return '';
          } catch (e) {
            _logger.i('Deep link OHOS initialized with URI 3-$e');
            return '';
          }
        },
      );

    } catch (e) {
      _logger.i('e---- ${e.toString()}');
    }
  }

  String cleanUri(String uri) {

    return uri.replaceAll(RegExp(r'^[^\w]+'), '');
  }


  Future<void> initialize() async {
    if (_isInitialized) return;

    try {

      final Uri? initialLink = await _appLinks.getInitialLink();


      _uriSubscription = _appLinks.uriLinkStream.listen(
        (Uri? uri) async {
          if (uri != null) {
            try {
              await _handleDeepLink(uri);
            } catch (e, stackTrace) {
              _logger.i('Deep link handling error: $e\n$stackTrace');

              if (!_deepLinkStreamController.isClosed) {
                _deepLinkStreamController.addError(e, stackTrace);
              }
            }
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          _logger.i('Deep link stream error: $error\n$stackTrace');

          if (!_deepLinkStreamController.isClosed) {
            _deepLinkStreamController.addError(error, stackTrace);
          }
        },
        cancelOnError: false,
      );


      _subscriptions.add(_uriSubscription!);


      if (initialLink != null) {
        await _handleDeepLink(initialLink);
      }

      _isInitialized = true;
    } catch (e, stackTrace) {
      _logger.i('Deep link initialization error: $e\n$stackTrace');

      _subscriptions.dispose();
      _uriSubscription = null;
      if (!_deepLinkStreamController.isClosed) {
        _deepLinkStreamController.addError(e, stackTrace);
      }
      rethrow;
    }
  }


  Future<void> _handleDeepLink(Uri uri) async {
    if (uri.scheme != 'dragonfly') {
      return;
    }

    try {
      final deepLinkData = DeepLinkData(
          path: uri.path,
          queryParams: uri.queryParameters
              .map((key, value) => MapEntry(key, value.toString())));
      inviteCode = uri.queryParameters['code'];
      _logger.i('Deep link data: ${uri.toString()}');
      eventBus.fire(uri.toString());




    } catch (e, stackTrace) {
      _logger.i('Deep link processing error: $e\n$stackTrace');
      rethrow;
    }
  }


  void dispose() {

    _subscriptions.dispose();


    if (!_deepLinkStreamController.isClosed) {
      _deepLinkStreamController.close();
    }


    _isInitialized = false;


    assert(_uriSubscription?.isPaused ?? true,
        'URI subscription not properly cancelled');
    _uriSubscription = null;
  }
}
