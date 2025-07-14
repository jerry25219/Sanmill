




import 'package:flutter/material.dart';

import '../../../shared/database/database.dart';
import '../mill.dart';

class AnimationManager {
  AnimationManager(this.vsync) {
    _initPlaceAnimation();
    _initMoveAnimation();
    _initRemoveAnimation();
  }

  final TickerProvider vsync;
  bool _isDisposed = false;

  bool allowAnimations = true;


  late final AnimationController _placeAnimationController;
  late final Animation<double> _placeAnimation;

  AnimationController get placeAnimationController => _placeAnimationController;
  Animation<double> get placeAnimation => _placeAnimation;


  late final AnimationController _moveAnimationController;
  late final Animation<double> _moveAnimation;

  AnimationController get moveAnimationController => _moveAnimationController;
  Animation<double> get moveAnimation => _moveAnimation;


  late final AnimationController _removeAnimationController;
  late final Animation<double> _removeAnimation;

  AnimationController get removeAnimationController =>
      _removeAnimationController;
  Animation<double> get removeAnimation => _removeAnimation;


  void _initPlaceAnimation() {
    _placeAnimationController = AnimationController(
      vsync: vsync,
      duration: Duration(
        milliseconds: (DB().displaySettings.animationDuration * 1000).toInt(),
      ),
    );

    _placeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _placeAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }


  void _initMoveAnimation() {
    _moveAnimationController = AnimationController(
      vsync: vsync,
      duration: Duration(
        milliseconds: (DB().displaySettings.animationDuration * 1000).toInt(),
      ),
    );

    _moveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _moveAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }


  void _initRemoveAnimation() {
    _removeAnimationController = AnimationController(
      vsync: vsync,
      duration: Duration(
        milliseconds: (DB().displaySettings.animationDuration * 1000).toInt(),
      ),
    );

    _removeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _removeAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }


  void dispose() {
    _isDisposed = true;
    _placeAnimationController.dispose();
    _moveAnimationController.dispose();
    _removeAnimationController.dispose();
  }


  void resetPlaceAnimation() {
    if (!_isDisposed) {
      _placeAnimationController.reset();
    }
  }


  void forwardPlaceAnimation() {
    if (!_isDisposed) {
      _placeAnimationController.forward();
    }
  }


  void resetMoveAnimation() {
    if (!_isDisposed) {
      _moveAnimationController.reset();
    }
  }


  void forwardMoveAnimation() {
    if (!_isDisposed) {
      _moveAnimationController.forward();
    }
  }


  void resetRemoveAnimation() {
    if (!_isDisposed) {
      _removeAnimationController.reset();
    }
  }


  void forwardRemoveAnimation() {
    if (!_isDisposed) {
      _removeAnimationController.forward();
    }
  }


  bool isRemoveAnimationAnimating() {
    return !_isDisposed && _removeAnimationController.isAnimating;
  }


  void animatePlace() {

    if ( _isDisposed) {

      return;
    }

    if (allowAnimations) {
      resetPlaceAnimation();
      forwardPlaceAnimation();
    }
  }


  void animateMove() {
    if ( _isDisposed) {

      return;
    }

    if (allowAnimations) {
      resetMoveAnimation();
      forwardMoveAnimation();
    }
  }


  void animateRemove() {
    if ( _isDisposed) {

      return;
    }

    if (allowAnimations) {
      resetRemoveAnimation();

      _removeAnimationController.addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          GameController().gameInstance.removeIndex = null;
        }
      });

      forwardRemoveAnimation();
    }
  }
}
