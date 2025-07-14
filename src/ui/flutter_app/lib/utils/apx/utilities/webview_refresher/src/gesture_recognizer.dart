import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';


class WebviewGestureRecognizer extends VerticalDragGestureRecognizer {
  WebviewGestureRecognizer({
    required this.offset,
    required this.scrollController,
    required this.context,
    required this.refreshState,
    super.debugOwner,
    super.allowedButtonsFilter,
  }) : super(
          supportedDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.trackpad,
          },
        );

  final ScrollController scrollController;
  final BuildContext context;
  final ValueNotifier<double> offset;
  final ValueNotifier<bool> refreshState;

  @override
  void rejectGesture(int pointer) {
    if (refreshState.value) {
      acceptGesture(pointer);
    }
  }

  Drag? _drag;

  bool _firstDirectionIsUp = false;

  @override
  GestureDragStartCallback? get onStart => (details) {
        _firstDirectionIsUp = false;
        if (offset.value <= 0) {
          _drag = scrollController.position.drag(details, () {
            _drag = null;
          });
        } else {
          _drag = null;
        }
      };

  @override
  GestureDragUpdateCallback? get onUpdate => (details) {
        if (details.delta.direction < 0 && !_firstDirectionIsUp) {
          _firstDirectionIsUp = true;
          _drag?.end(DragEndDetails(primaryVelocity: 0));
          _drag = null;
          return;
        } else {
          _firstDirectionIsUp = true;
        }
        _drag?.update(details);
      };

  @override
  GestureDragEndCallback? get onEnd => (details) {
        _drag?.end(details);
        _drag = null;
      };
}
