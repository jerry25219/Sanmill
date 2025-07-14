


import 'dart:async';
import 'dart:collection';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



import '../../generated/intl/l10n.dart';
import '../../shared/database/database.dart';
import '../../shared/services/logger.dart';


enum FishType {
  normal, // Common fish, average properties
  fast, // Fast-moving fish
  large, // Larger fish worth more points
  golden, // Rare valuable fish
  tiny, // Very small fish, hard to catch
  jellyfish, // Erratic movement pattern
  shark, // Large and aggressive
  bubblefish, // Moves in bubble-like patterns
  crab // Moves sideways more than forward
}


enum Direction { up, down, left, right }





class CatFishingGame extends StatefulWidget {
  const CatFishingGame({super.key, this.onScoreUpdate});


  final Function(int score)? onScoreUpdate;

  @override
  State<CatFishingGame> createState() => _CatFishingGameState();
}

class _CatFishingGameState extends State<CatFishingGame>
    with SingleTickerProviderStateMixin {

  int _score = 0;
  int _timeLeft = 60;
  bool _isGameOver = false;
  String _gameOverReason = '';


  final bool _isDebug = false;


  late Size _gameSize = Size.zero;


  final Queue<Offset> _catSegments = Queue<Offset>();
  int _catLength = 3;
  Direction _direction = Direction.right;
  Direction _nextDirection = Direction.right;
  final double _catSegmentSize = 24.0;


  final double _baseMoveDistance = 4.0;
  double _currentMoveDistance =
      4.0;
  final double _maxMoveDistance = 16.0;
  final double _speedDecayRate =
      0.95;
  final double _minMoveDistance = 2.0;
  DateTime _lastGestureTime = DateTime.now();


  Timer? _moveTimer;


  late AnimationController _controller;


  Timer? _gameTimer;


  final math.Random _random = math.Random();


  final List<_Fish> _fishes = <_Fish>[];
  final int _numFish = 7;


  int _fishEatenCount = 0;


  final double _fishSpeedBoostPerCatch = 0.05;


  final double _maxFishSpeedMultiplier = 2.5;


  double _fishRandomDirectionChance = 0.3;


  final double _maxFishRandomDirectionChance = 0.7;


  double _fishDirectionChangeAmount = 0.4;


  final double _maxFishDirectionChangeAmount = 1.2;


  late Color _messageColor;


  final List<_CatchEffect> _catchEffects = <_CatchEffect>[];

  @override
  void initState() {
    super.initState();


    try {
      _messageColor = DB().colorSettings.messageColor;
    } catch (e) {
      _messageColor = Colors.white;
      logger.w(
          "Warning: Could not get color from DB().colorSettings.messageColor. Using fallback.");
    }


    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);


    _startGameTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_gameSize != Size.zero && _catSegments.isEmpty) {
        _initializeGame();
      }
    });
  }


  void _initializeGame() {

    final double centerX = (_gameSize.width / 2).floorToDouble();
    final double centerY = (_gameSize.height / 2).floorToDouble();

    _catSegments.clear();

    for (int i = 0; i < _catLength; i++) {
      _catSegments
          .addFirst(Offset(centerX - i * _baseMoveDistance * 2, centerY));
    }


    _initializeFish();


    _startMovementTimer();

    setState(() {});
  }


  void _initializeFish() {
    if (_gameSize == Size.zero) {
      return;
    }
    _fishes.clear();
    for (int i = 0; i < _numFish; i++) {
      _fishes.add(_Fish.random(_random, _gameSize));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _gameTimer?.cancel();
    _moveTimer?.cancel();
    super.dispose();
  }



  void _startMovementTimer() {
    _moveTimer?.cancel();

    _moveTimer =
        Timer.periodic(const Duration(milliseconds: 50), (Timer timer) {
      if (!mounted || _isGameOver) {
        timer.cancel();
        return;
      }
      _updateCatPosition();


      final DateTime now = DateTime.now();
      if (now.difference(_lastGestureTime).inMilliseconds > 300) {
        _decaySpeed();
      }
    });
  }


  void _decaySpeed() {
    if (_currentMoveDistance > _baseMoveDistance) {
      setState(() {
        _currentMoveDistance =
            math.max(_baseMoveDistance, _currentMoveDistance * _speedDecayRate);
      });
    }
  }


  void _stopMovementTimer() {
    _moveTimer?.cancel();
  }


  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {

          _gameOver("⏰");
        }
      });
    });
  }


  void _increaseFishDifficulty() {

    _fishEatenCount++;


    math.min(1.0, _fishEatenCount / 30);


    _fishRandomDirectionChance = _fishRandomDirectionChance +
        ((_maxFishRandomDirectionChance - _fishRandomDirectionChance) * 0.1);

    _fishDirectionChangeAmount = _fishDirectionChangeAmount +
        ((_maxFishDirectionChangeAmount - _fishDirectionChangeAmount) * 0.1);


    for (final _Fish fish in _fishes) {

      fish.speedMultiplier = math.min(_maxFishSpeedMultiplier,
          fish.speedMultiplier + _fishSpeedBoostPerCatch);


      fish.wiggleAmount = math.min(0.8, fish.wiggleAmount + 0.02);
      fish.wiggleSpeed = math.min(8.0, fish.wiggleSpeed + 0.1);
    }
  }


  void _updateCatPosition() {
    if (_isGameOver || !mounted) {
      return;
    }

    setState(() {

      _direction = _nextDirection;


      final Offset head = _catSegments.first;
      Offset newHead;


      switch (_direction) {
        case Direction.up:
          newHead = Offset(head.dx, head.dy - _currentMoveDistance);
          break;
        case Direction.down:
          newHead = Offset(head.dx, head.dy + _currentMoveDistance);
          break;
        case Direction.left:
          newHead = Offset(head.dx - _currentMoveDistance, head.dy);
          break;
        case Direction.right:
          newHead = Offset(head.dx + _currentMoveDistance, head.dy);
          break;
      }


      if (newHead.dx < 0) {
        newHead = Offset(_gameSize.width, newHead.dy);
      } else if (newHead.dx > _gameSize.width) {
        newHead = Offset(0, newHead.dy);
      }

      if (newHead.dy < 0) {
        newHead = Offset(newHead.dx, _gameSize.height);
      } else if (newHead.dy > _gameSize.height) {
        newHead = Offset(newHead.dx, 0);
      }


      _catSegments.addFirst(newHead);



      bool selfCollision = false;


      if (_catSegments.length > 5) {



        final int segmentsToSkip = math.max(5, _catSegments.length ~/ 3);


        final Offset headPos = _catSegments.first;
        final double collisionThreshold =
            _catSegmentSize * 0.4;


        int index = 0;
        for (final Offset segment in _catSegments) {

          if (index <= segmentsToSkip) {
            index++;
            continue;
          }


          final double distance = (segment - headPos).distance;


          if (distance < collisionThreshold) {
            selfCollision = true;


            if (_isDebug) {
              logger.i(
                  'Collision detected! Distance: $distance, Threshold: $collisionThreshold, Segment: $index');
            }

            break;
          }

          index++;
        }
      }

      if (selfCollision) {
        _gameOver("😮🐱🦷");


        if (_catSegments.isNotEmpty) {
          _catSegments.removeFirst();
        }

        return;
      }


      for (final _Fish fish in _fishes) {
        final double distance = (fish.position - newHead).distance;
        final double catchDistance = _catSegmentSize / 2 + fish.size / 2;

        if (distance < catchDistance * 0.8) {


          _score += fish.points;
          widget.onScoreUpdate?.call(_score);


          _createCatchEffect(fish);


          _catLength += fish.points;


          _increaseFishDifficulty();


          fish.respawn(_random, _gameSize);

          break;
        }
      }


      while (_catSegments.length > _catLength) {
        _catSegments.removeLast();
      }


      _updateFish();
    });
  }


  void _updateFish() {
    if (_isGameOver || _gameSize == Size.zero || _fishes.isEmpty) {
      return;
    }


    const double dt = 0.05;


    for (final _Fish fish in _fishes) {

      fish.headingChangeTimer -= dt;


      if (fish.headingChangeTimer <= 0) {

        fish.headingChangeTimer = fish.headingChangeInterval;


        if (fish.type == FishType.jellyfish) {

          fish.targetHeading =
              fish.heading + (_random.nextDouble() * math.pi - math.pi / 2);
        } else if (fish.type == FishType.bubblefish) {

          fish.targetHeading =
              fish.heading + (_random.nextDouble() * math.pi / 2);
        } else if (fish.type == FishType.crab) {

          final double sideChance = _random.nextDouble();
          if (sideChance < 0.6) {

            fish.targetHeading =
                fish.heading + (math.pi / 2 * (_random.nextBool() ? 1 : -1));
          } else {

            fish.targetHeading =
                fish.heading + (_random.nextDouble() * math.pi - math.pi / 2);
          }
        } else if (fish.type == FishType.shark) {

          final double lungeChance = _random.nextDouble();
          if (lungeChance < 0.2) {

            fish.velocity = fish.velocity * 1.5;

            fish.targetHeading =
                fish.heading + (_random.nextDouble() * 0.4 - 0.2);
          } else {

            fish.targetHeading = fish.heading +
                (_random.nextDouble() * math.pi / 2 - math.pi / 4);
          }
        } else {


          final double turnRange =
              math.pi / 2 * (1.0 + (_fishEatenCount / 60).clamp(0.0, 1.0));
          fish.targetHeading =
              fish.heading + (_random.nextDouble() * turnRange - turnRange / 2);
        }


        while (fish.targetHeading < 0) {
          fish.targetHeading += math.pi * 2;
        }
        while (fish.targetHeading >= math.pi * 2) {
          fish.targetHeading -= math.pi * 2;
        }
      }



      double headingDiff = fish.targetHeading - fish.heading;


      if (headingDiff > math.pi) {
        headingDiff -= math.pi * 2;
      }
      if (headingDiff < -math.pi) {
        headingDiff += math.pi * 2;
      }


      final double turnAmount = headingDiff.abs() < fish.turnRate
          ? headingDiff // If we're close enough, just set it directly
          : fish.turnRate * headingDiff.sign;


      fish.heading +=
          turnAmount * dt * 20;


      while (fish.heading < 0) {
        fish.heading += math.pi * 2;
      }
      while (fish.heading >= math.pi * 2) {
        fish.heading -= math.pi * 2;
      }


      final double speedMultiplier = fish.speedMultiplier;
      final double effectiveSpeed = fish.baseSpeed * speedMultiplier;


      fish.velocity = Offset(math.cos(fish.heading), math.sin(fish.heading)) *
          effectiveSpeed;


      Offset newPos = fish.position + fish.velocity * dt;


      final double half = fish.size / 2;


      bool didBounce = false;


      if (newPos.dx - half < 0) {
        newPos = Offset(half, newPos.dy);

        fish.heading = math.pi - fish.heading;
        fish.targetHeading = fish.heading;
        didBounce = true;
      } else if (newPos.dx + half > _gameSize.width) {
        newPos = Offset(_gameSize.width - half, newPos.dy);

        fish.heading = math.pi - fish.heading;
        fish.targetHeading = fish.heading;
        didBounce = true;
      }


      if (newPos.dy - half < 0) {
        newPos = Offset(newPos.dx, half);

        fish.heading = -fish.heading;
        fish.targetHeading = fish.heading;
        didBounce = true;
      } else if (newPos.dy + half > _gameSize.height) {
        newPos = Offset(newPos.dx, _gameSize.height - half);

        fish.heading = -fish.heading;
        fish.targetHeading = fish.heading;
        didBounce = true;
      }


      while (fish.heading < 0) {
        fish.heading += math.pi * 2;
      }
      while (fish.heading >= math.pi * 2) {
        fish.heading -= math.pi * 2;
      }


      if (didBounce) {

        fish.baseSpeed *= 0.95;


        fish.velocity = Offset(math.cos(fish.heading), math.sin(fish.heading)) *
            (fish.baseSpeed * fish.speedMultiplier);
      }



      final double wiggleFactor =
          0.01 * (1.0 + (_fishEatenCount / 100).clamp(0.0, 1.0));
      final double perpAngle =
          fish.heading + math.pi / 2;
      final double lateralAmount =
          (math.sin(fish.wigglePhase) * fish.wiggleAmount) *
              fish.size *
              wiggleFactor;

      newPos += Offset(math.cos(perpAngle) * lateralAmount,
          math.sin(perpAngle) * lateralAmount);

      fish.position = newPos;


      fish.wigglePhase += dt * fish.wiggleSpeed;
      if (fish.wigglePhase > math.pi * 2) {
        fish.wigglePhase -= math.pi * 2;
      }
    }


    _updateCatchEffects(0.05);
  }


  void _updateCatchEffects(double dt) {
    for (final _CatchEffect effect in _catchEffects) {
      effect.position =
          Offset(effect.position.dx, effect.position.dy - 20 * dt);
      effect.life -= dt;
    }
    _catchEffects.removeWhere((_CatchEffect e) => e.life <= 0);
  }


  void _createCatchEffect(_Fish fish) {

    String text;

    if (fish.type == FishType.golden) {

      text = 'Golden! +${fish.points}';
    } else {


      fish.size.toStringAsFixed(1);
      text = '+${fish.points}';
    }

    _catchEffects.add(_CatchEffect(
      text: text,
      position: fish.position,
      life: 1.0,
    ));
  }


  void _changeDirection(Direction newDirection) {

    if (_direction == Direction.up && newDirection == Direction.down) {
      return;
    }
    if (_direction == Direction.down && newDirection == Direction.up) {
      return;
    }
    if (_direction == Direction.left && newDirection == Direction.right) {
      return;
    }
    if (_direction == Direction.right && newDirection == Direction.left) {
      return;
    }

    _nextDirection = newDirection;
  }


  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final LogicalKeyboardKey key = event.logicalKey;

      if (key == LogicalKeyboardKey.arrowUp) {
        _changeDirection(Direction.up);
      } else if (key == LogicalKeyboardKey.arrowDown) {
        _changeDirection(Direction.down);
      } else if (key == LogicalKeyboardKey.arrowLeft) {
        _changeDirection(Direction.left);
      } else if (key == LogicalKeyboardKey.arrowRight) {
        _changeDirection(Direction.right);
      }
    }
  }


  void _adjustSpeedFromGesture(Offset velocity) {

    final double speed = velocity.distance;



    final double newSpeed = math.min(
        _maxMoveDistance,
        _minMoveDistance +
            (speed / 200) * (_maxMoveDistance - _minMoveDistance));


    setState(() {
      _currentMoveDistance = newSpeed;
      _lastGestureTime = DateTime.now();
    });
  }


  void _gameOver(String reason) {
    if (_isGameOver) {
      return;
    }
    setState(() {
      _isGameOver = true;
      _gameOverReason = reason;
      _stopMovementTimer();
      _gameTimer?.cancel();
    });
  }


  void _restartGame() {
    if (!mounted) {
      return;
    }
    setState(() {
      _score = 0;
      _timeLeft = 60;
      _isGameOver = false;
      _gameOverReason = '';
      _catLength = 3;
      _direction = Direction.right;
      _nextDirection = Direction.right;
      _currentMoveDistance = _baseMoveDistance;
      _fishEatenCount = 0;
      _fishRandomDirectionChance = 0.3;
      _fishDirectionChangeAmount = 0.4;

      _initializeGame();
      _catchEffects.clear();

      _startGameTimer();
      _startMovementTimer();

      widget.onScoreUpdate?.call(_score);
    });
  }



  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: _handleKeyEvent,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {

          final Size newSize =
              Size(constraints.maxWidth, constraints.maxHeight);
          if (_gameSize != newSize) {
            _gameSize = newSize;
            if (_catSegments.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _initializeGame();
              });
            }
          }




          final bool isMobilePlatform =
              !kIsWeb && (Platform.isAndroid || Platform.isIOS);
          final bool isDesktopOrWebPlatform = kIsWeb ||
              Platform.isMacOS ||
              Platform.isWindows ||
              Platform.isLinux;

          return GestureDetector(

            onVerticalDragUpdate: isMobilePlatform
                ? (DragUpdateDetails details) {

                    if (details.delta.dy < 0) {
                      _changeDirection(Direction.up);
                    } else {
                      _changeDirection(Direction.down);
                    }


                    _adjustSpeedFromGesture(details.primaryDelta != null
                        ? Offset(0, details.primaryDelta! * 10)
                        : Offset.zero);
                  }
                : null,
            onHorizontalDragUpdate: isMobilePlatform
                ? (DragUpdateDetails details) {

                    if (details.delta.dx < 0) {
                      _changeDirection(Direction.left);
                    } else {
                      _changeDirection(Direction.right);
                    }


                    _adjustSpeedFromGesture(details.primaryDelta != null
                        ? Offset(details.primaryDelta! * 10, 0)
                        : Offset.zero);
                  }
                : null,

            onTapDown: isDesktopOrWebPlatform
                ? (TapDownDetails details) {
                    if (_catSegments.isEmpty || _isGameOver) {
                      return;
                    }


                    final Offset tapPosition = details.localPosition;
                    final Offset headPosition = _catSegments.first;


                    final Offset direction = tapPosition - headPosition;


                    final double distance = direction.distance;



                    if (direction.dx.abs() > direction.dy.abs()) {

                      if (direction.dx > 0) {
                        _changeDirection(Direction.right);
                      } else {
                        _changeDirection(Direction.left);
                      }
                    } else {

                      if (direction.dy > 0) {
                        _changeDirection(Direction.down);
                      } else {
                        _changeDirection(Direction.up);
                      }
                    }





                    final double speedFactor =
                        (distance / 150.0).clamp(0.2, 1.0);
                    final double newSpeed = _minMoveDistance +
                        speedFactor * (_maxMoveDistance - _minMoveDistance);

                    setState(() {
                      _currentMoveDistance = newSpeed;
                      _lastGestureTime =
                          DateTime.now();
                    });
                  }
                : null,
            child: Stack(
              children: <Widget>[

                Container(color: Colors.lightBlue.shade100),


                CustomPaint(
                  size: Size.infinite,
                  painter: _GridPainter(),
                ),


                ..._fishes.map((_Fish fish) => Positioned(
                      left: fish.position.dx - fish.size / 2,
                      top: fish.position.dy - fish.size / 2,
                      child: Transform.rotate(



                        angle: _calculateFishDisplayAngle(fish),
                        child: Text(
                          fish.emoji,
                          style: TextStyle(fontSize: fish.size),
                        ),
                      ),
                    )),


                ..._catSegments
                    .toList()
                    .asMap()
                    .entries
                    .map((MapEntry<int, Offset> entry) {
                  final int index = entry.key;
                  final Offset segment = entry.value;
                  final bool isHead = index == 0;

                  return Positioned(
                    left: segment.dx - _catSegmentSize / 2,
                    top: segment.dy - _catSegmentSize / 2,
                    child: Container(
                      width: _catSegmentSize,
                      height: _catSegmentSize,
                      decoration: BoxDecoration(
                        color: isHead
                            ? Colors.orange
                            : Colors.orange.withValues(
                                alpha: math.max(0.1, 0.8 - index * 0.01)),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.brown,
                          width: 2,
                        ),
                      ),
                      child: isHead
                          ? const Center(
                              child: Text(
                                '🐱',
                                style: TextStyle(fontSize: 14),
                              ),
                            )
                          : index % 3 == 0
                              ? const Center(
                                  child: Text(
                                    '🐾',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                )
                              : null,
                    ),
                  );
                }),


                Positioned(
                  top: 10,
                  left: 10,
                  child: _buildInfoChip('⏱️ $_timeLeft'),
                ),


                Positioned(
                  top: 10,
                  right: 10,
                  child: _buildInfoChip('🐟 ${_catLength - 3}'),
                ),


                ..._catchEffects.map((_CatchEffect effect) {
                  final double alpha = (effect.life / 1.0).clamp(0.0, 1.0);
                  return Positioned(
                    left: effect.position.dx,
                    top: effect.position.dy,
                    child: Opacity(
                      opacity: alpha,
                      child: Text(
                        effect.text,
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: <Shadow>[
                            Shadow(blurRadius: 4.0, color: Colors.black26),
                          ],
                        ),
                      ),
                    ),
                  );
                }),


                if (_isDebug)
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Text(
                        'Fish eaten: $_fishEatenCount\nDifficulty: ${(_fishEatenCount / 30).clamp(0.0, 1.0).toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),


                if (_isGameOver)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.7),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              S.of(context).gameOver,
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                shadows: <Shadow>[
                                  Shadow(
                                    blurRadius: 8.0,
                                    color: Colors.black.withValues(alpha: 0.5),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _gameOverReason,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${_catLength - 3} 🐟',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                textStyle: const TextStyle(fontSize: 18),
                              ),
                              onPressed: _restartGame,
                              child: const Text('🔄'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _messageColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: 'monospace',
        ),
      ),
    );
  }


  double _calculateFishDisplayAngle(_Fish fish) {

    double baseAngle = fish.heading;
    while (baseAngle < 0) {
      baseAngle += math.pi * 2;
    }
    while (baseAngle >= math.pi * 2) {
      baseAngle -= math.pi * 2;
    }


    double finalAngle =
        baseAngle + math.sin(fish.wigglePhase) * fish.wiggleAmount;


    finalAngle += math.pi;






    final bool facingDownward =
        baseAngle > math.pi / 2 && baseAngle < math.pi * 3 / 2;

    if (facingDownward) {


      finalAngle = math.pi - (finalAngle - math.pi);


      while (finalAngle < 0) {
        finalAngle += math.pi * 2;
      }
      while (finalAngle >= math.pi * 2) {
        finalAngle -= math.pi * 2;
      }
    }

    return finalAngle;
  }
}


class _Fish {
  _Fish({
    required this.position,
    required this.velocity,
    required this.size,
    required this.type,
    required this.emoji,
    required this.points,
    required this.speedMultiplier,
    required this.baseSpeed,
    required this.heading,
    required this.targetHeading,
    required this.headingChangeTimer,
    required this.headingChangeInterval,
    required this.turnRate,
    this.wigglePhase = 0.0,
    this.wiggleSpeed = 5.0,
    this.wiggleAmount = 0.2,
  });




  factory _Fish.random(math.Random rng, Size bounds) {
    final FishType type = _getRandomFishType(rng);

    double size, speedMultiplier;
    String emoji;
    int basePoints = 1;


    final double baseSpeed = rng.nextDouble() * 10 + 10;

    switch (type) {
      case FishType.fast:
        size = rng.nextDouble() * 10 + 20;
        emoji = '🐟';
        basePoints = 3;
        speedMultiplier = 1.2;
        break;
      case FishType.large:
        size = rng.nextDouble() * 20 + 40;
        emoji = '🐡';
        basePoints = 7;
        speedMultiplier = 0.6;
        break;
      case FishType.golden:
        size = rng.nextDouble() * 10 + 30;
        emoji = '🪙';
        basePoints = 9;
        speedMultiplier = 0.8;
        break;
      case FishType.tiny:

        size = rng.nextDouble() * 5 + 10;
        emoji = '🐡';
        basePoints = 2;
        speedMultiplier = 1.5;
        break;
      case FishType.jellyfish:

        size = rng.nextDouble() * 15 + 25;
        emoji = '🪼';
        basePoints = 5;
        speedMultiplier = 0.5;
        break;
      case FishType.shark:

        size = rng.nextDouble() * 25 + 45;
        emoji = '🦈';
        basePoints = 8;
        speedMultiplier = 1.0;
        break;
      case FishType.bubblefish:

        size = rng.nextDouble() * 12 + 18;
        emoji = '🫧';
        basePoints = 1;
        speedMultiplier = 0.7;
        break;
      case FishType.crab:

        size = rng.nextDouble() * 15 + 20;
        emoji = '🦀';
        basePoints = 4;
        speedMultiplier = 0.4;
        break;
      case FishType.normal:
        size = rng.nextDouble() * 15 + 25;
        emoji = '🐠';
        basePoints = 6;
        speedMultiplier = 0.9;
        break;
    }




    final double sizeMultiplier = size / 25.0;
    final int sizeBonus = (sizeMultiplier * 2).floor();


    final int points = basePoints + sizeBonus;


    final Offset pos = Offset(
      rng.nextDouble() * (bounds.width - size) + size / 2,
      rng.nextDouble() * (bounds.height - size) + size / 2,
    );


    final double initialHeading = rng.nextDouble() * 2 * math.pi;
    final double targetHeading = initialHeading;


    final Offset vel =
        Offset(math.cos(initialHeading), math.sin(initialHeading)) * baseSpeed;


    double headingChangeInterval =
        3.0;
    double turnRate =
        0.05;


    switch (type) {
      case FishType.jellyfish:
        headingChangeInterval = 1.0;
        turnRate = 0.08;
        break;
      case FishType.bubblefish:
        headingChangeInterval = 1.5;
        turnRate = 0.04;
        break;
      case FishType.crab:
        headingChangeInterval = 2.0;
        turnRate = 0.12;
        break;
      case FishType.shark:
        headingChangeInterval = 4.0;
        turnRate = 0.03;
        break;
      case FishType.fast:
        headingChangeInterval = 2.5;
        turnRate = 0.06;
        break;
      case FishType.normal:
      case FishType.large:
      case FishType.golden:
      case FishType.tiny:

        break;
    }


    final double headingChangeTimer = rng.nextDouble() * headingChangeInterval;


    final double wiggleSpeed = rng.nextDouble() * 2.0 + 1.5;
    final double wiggleAmount =
        rng.nextDouble() * 0.15 + 0.05;
    final double wigglePhase =
        rng.nextDouble() * math.pi * 2;

    return _Fish(
      position: pos,
      velocity: vel,
      size: size,
      type: type,
      emoji: emoji,
      points: points,
      speedMultiplier: speedMultiplier,
      baseSpeed: baseSpeed,
      heading: initialHeading,
      targetHeading: targetHeading,
      headingChangeTimer: headingChangeTimer,
      headingChangeInterval: headingChangeInterval,
      turnRate: turnRate,
      wigglePhase: wigglePhase,
      wiggleSpeed: wiggleSpeed,
      wiggleAmount: wiggleAmount,
    );
  }

  Offset position;
  Offset velocity;
  double size;
  FishType type;
  String emoji;
  int points;
  double speedMultiplier;


  double baseSpeed;
  double heading;
  double targetHeading;
  double headingChangeTimer;
  double headingChangeInterval;
  double turnRate;


  double wigglePhase;
  double wiggleSpeed;
  double wiggleAmount;


  static FishType _getRandomFishType(math.Random rng) {
    final double chance = rng.nextDouble();
    if (chance < 0.03) {
      return FishType.golden;
    } else if (chance < 0.07) {
      return FishType.shark;
    } else if (chance < 0.12) {
      return FishType.jellyfish;
    } else if (chance < 0.20) {
      return FishType.large;
    } else if (chance < 0.30) {
      return FishType.crab;
    } else if (chance < 0.40) {
      return FishType.bubblefish;
    } else if (chance < 0.55) {
      return FishType.fast;
    } else if (chance < 0.70) {
      return FishType.tiny;
    } else {
      return FishType.normal;
    }
  }


  void respawn(math.Random rng, Size bounds) {
    final _Fish newFish = _Fish.random(rng, bounds);
    position = newFish.position;
    velocity = newFish.velocity;
    size = newFish.size;
    type = newFish.type;
    emoji = newFish.emoji;
    points = newFish.points;
    speedMultiplier = newFish.speedMultiplier;
    baseSpeed = newFish.baseSpeed;
    heading = newFish.heading;
    targetHeading = newFish.targetHeading;
    headingChangeTimer = newFish.headingChangeTimer;
    headingChangeInterval = newFish.headingChangeInterval;
    turnRate = newFish.turnRate;
    wigglePhase = newFish.wigglePhase;
    wiggleSpeed = newFish.wiggleSpeed;
    wiggleAmount = newFish.wiggleAmount;
  }
}


class _CatchEffect {
  _CatchEffect({
    required this.text,
    required this.position,
    required this.life,
  });

  String text;
  Offset position;
  double life;
}


class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1;


    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }


    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
