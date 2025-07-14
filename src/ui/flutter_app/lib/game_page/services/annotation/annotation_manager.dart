




import 'dart:math';

import 'package:flutter/material.dart';

import '../../../generated/intl/l10n.dart';
import '../../../shared/database/database.dart';
import '../../../shared/services/logger.dart';
import '../../../shared/themes/app_theme.dart';
import '../painters/painters.dart';


enum AnnotationTool { line, arrow, circle, dot, cross, rect, text, move }



abstract class AnnotationShape {
  AnnotationShape({required this.color});


  Color color;


  void draw(Canvas canvas, Size size);


  bool hitTest(Offset tapPosition);


  void translate(Offset delta);
}





class AnnotationCircle extends AnnotationShape {
  AnnotationCircle({
    required this.center,
    required this.radius,
    required Color color,
    this.strokeWidth = 3.0,
  }) : super(color: color) {
    paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
  }


  factory AnnotationCircle.fromPoints({
    required Offset start,
    required Offset end,
    required Color color,
    double strokeWidth = 3.0,
  }) {
    final Offset center = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );
    final double radius = (start - end).distance / 2;
    return AnnotationCircle(
      center: center,
      radius: radius,
      color: color,
      strokeWidth: strokeWidth,
    );
  }

  Offset center;
  double radius;
  final double strokeWidth;
  late Paint paint;

  @override
  void translate(Offset delta) {
    center += delta;
  }

  @override
  void draw(Canvas canvas, Size size) {
    paint.color = color;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool hitTest(Offset tapPosition) {
    final double dist = (tapPosition - center).distance;
    return dist <= radius + 5.0;
  }
}

class AnnotationLine extends AnnotationShape {
  AnnotationLine({
    required this.start,
    required this.end,
    required super.color,
    this.strokeWidth = 3.0,
  });

  Offset start;
  Offset end;
  final double strokeWidth;

  @override
  void translate(Offset delta) {
    start += delta;
    end += delta;
  }

  @override
  void draw(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawLine(start, end, paint);
  }

  @override
  bool hitTest(Offset tapPosition) {
    const double threshold = 6.0;
    final double lineLen = (end - start).distance;
    if (lineLen < 0.5) {
      return (start - tapPosition).distance < threshold;
    }
    final double t = ((tapPosition.dx - start.dx) * (end.dx - start.dx) +
            (tapPosition.dy - start.dy) * (end.dy - start.dy)) /
        (lineLen * lineLen);
    if (t < 0) {
      return (tapPosition - start).distance <= threshold;
    } else if (t > 1) {
      return (tapPosition - end).distance <= threshold;
    } else {
      final Offset projection = Offset(
        start.dx + t * (end.dx - start.dx),
        start.dy + t * (end.dy - start.dy),
      );
      return (tapPosition - projection).distance <= threshold;
    }
  }
}

class AnnotationArrow extends AnnotationShape {
  AnnotationArrow({
    required this.start,
    required this.end,
    required Color color,
    this.strokeWidth = 3.0,
  }) : super(color: color) {
    paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
  }

  Offset start;
  Offset end;
  final double strokeWidth;
  late Paint paint;

  @override
  void translate(Offset delta) {
    start += delta;
    end += delta;
  }

  @override
  void draw(Canvas canvas, Size size) {

    paint.color = color;


    const double arrowLength = 15.0;
    const double arrowWidth = 12.0;


    final double angle = (end - start).direction;


    final Offset adjustedEnd = end -
        Offset(
          arrowLength * cos(angle),
          arrowLength * sin(angle),
        );


    canvas.drawLine(start, adjustedEnd, paint);



    final Paint circlePaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(start, arrowWidth / 4, circlePaint);


    final Offset perpendicular = Offset(-sin(angle), cos(angle));


    final Offset arrowBaseLeft =
        adjustedEnd + (perpendicular * (arrowWidth / 2));
    final Offset arrowBaseRight =
        adjustedEnd - (perpendicular * (arrowWidth / 2));


    final Path arrowPath = Path()
      ..moveTo(end.dx, end.dy) // Arrow tip exactly at the target point
      ..lineTo(arrowBaseLeft.dx, arrowBaseLeft.dy)
      ..lineTo(arrowBaseRight.dx, arrowBaseRight.dy)
      ..close();


    final Paint arrowPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;


    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool hitTest(Offset tapPosition) {
    final AnnotationLine line = AnnotationLine(
      start: start,
      end: end,
      color: color,
      strokeWidth: strokeWidth,
    );
    return line.hitTest(tapPosition);
  }
}

class AnnotationRect extends AnnotationShape {
  AnnotationRect({
    required this.start,
    required this.end,
    required Color color,
    this.strokeWidth = 3.0,
  }) : super(color: color) {
    paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
  }

  Offset start;
  Offset end;
  final double strokeWidth;
  late Paint paint;

  @override
  void translate(Offset delta) {
    start += delta;
    end += delta;
  }

  @override
  void draw(Canvas canvas, Size size) {
    paint.color = color;
    canvas.drawRect(Rect.fromPoints(start, end), paint);
  }

  @override
  bool hitTest(Offset tapPosition) {
    final Rect rect = Rect.fromPoints(start, end).inflate(5);
    return rect.contains(tapPosition);
  }
}

class AnnotationDot extends AnnotationShape {
  AnnotationDot({
    required this.point,
    required super.color,
    this.radius = 4.0,
  });

  Offset point;
  double radius;

  @override
  void translate(Offset delta) {
    point += delta;
  }

  @override
  void draw(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(point, radius, paint);
  }

  @override
  bool hitTest(Offset tapPosition) {
    final double dist = (tapPosition - point).distance;
    return dist <= radius + 5.0;
  }
}

class AnnotationCross extends AnnotationShape {
  AnnotationCross({
    required this.point,
    required super.color,
    this.crossSize = 8.0,
    this.strokeWidth = 3.0,
  });


  Offset point;


  double crossSize;


  final double strokeWidth;

  @override
  void translate(Offset delta) {
    point += delta;
  }

  @override
  void draw(Canvas canvas, Size size) {

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;


    final Offset topLeft = Offset(point.dx - crossSize, point.dy - crossSize);
    final Offset bottomRight =
        Offset(point.dx + crossSize, point.dy + crossSize);
    final Offset topRight = Offset(point.dx + crossSize, point.dy - crossSize);
    final Offset bottomLeft =
        Offset(point.dx - crossSize, point.dy + crossSize);


    canvas.drawLine(topLeft, bottomRight, paint);
    canvas.drawLine(topRight, bottomLeft, paint);
  }

  @override
  bool hitTest(Offset tapPosition) {

    final double halfSize = crossSize + 5.0;
    final Rect bbox = Rect.fromCenter(
      center: point,
      width: halfSize * 2,
      height: halfSize * 2,
    );
    return bbox.contains(tapPosition);
  }
}

class AnnotationText extends AnnotationShape {
  AnnotationText({
    required this.point,
    required this.text,
    required super.color,
    this.fontSize = 16.0,
  });


  Offset point;
  String text;
  final double fontSize;

  @override
  void translate(Offset delta) {
    point += delta;
  }

  @override
  void draw(Canvas canvas, Size size) {

    final TextSpan span = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
      ),
    );

    final TextPainter tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );
    tp.layout();


    final Offset drawOffset = point - Offset(tp.width / 2, tp.height / 2);


    tp.paint(canvas, drawOffset);
  }

  @override
  bool hitTest(Offset tapPosition) {

    final TextSpan span = TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: fontSize),
    );

    final TextPainter tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );
    tp.layout();


    final Rect bbox = Rect.fromCenter(
      center: point,
      width: tp.width,
      height: tp.height,
    ).inflate(5);


    return bbox.contains(tapPosition);
  }
}





enum AnnotationCommandType {
  addShape,
  removeShape,
  changeColor,
  changeText,
  moveText,
  translateShape,
}

class AnnotationCommand {
  AnnotationCommand({
    required this.type,
    required this.shape,
    this.oldColor,
    this.newColor,
    this.oldText,
    this.newText,
    this.oldOffset,
    this.newOffset,
    this.delta,
    required this.manager,
  });

  final AnnotationCommandType type;
  final AnnotationShape shape;
  final Color? oldColor;
  final Color? newColor;
  final String? oldText;
  final String? newText;
  final Offset? oldOffset;
  final Offset? newOffset;
  final Offset? delta;
  final AnnotationManager manager;

  void redo() {
    switch (type) {
      case AnnotationCommandType.addShape:
        manager.shapes.add(shape);
        break;
      case AnnotationCommandType.removeShape:
        manager.shapes.remove(shape);
        break;
      case AnnotationCommandType.changeColor:
        if (newColor != null) {
          shape.color = newColor!;
        }
        break;
      case AnnotationCommandType.changeText:
        if (shape is AnnotationText && newText != null) {
          (shape as AnnotationText).text = newText!;
        }
        break;
      case AnnotationCommandType.moveText:
        if (shape is AnnotationText && newOffset != null) {
          (shape as AnnotationText).point = newOffset!;
        }
        break;
      case AnnotationCommandType.translateShape:
        if (delta != null) {
          shape.translate(delta!);
        }
        break;
    }
  }

  void undo() {
    switch (type) {
      case AnnotationCommandType.addShape:
        manager.shapes.remove(shape);
        break;
      case AnnotationCommandType.removeShape:
        manager.shapes.add(shape);
        break;
      case AnnotationCommandType.changeColor:
        if (oldColor != null) {
          shape.color = oldColor!;
        }
        break;
      case AnnotationCommandType.changeText:
        if (shape is AnnotationText && oldText != null) {
          (shape as AnnotationText).text = oldText!;
        }
        break;
      case AnnotationCommandType.moveText:
        if (shape is AnnotationText && oldOffset != null) {
          (shape as AnnotationText).point = oldOffset!;
        }
        break;
      case AnnotationCommandType.translateShape:
        if (delta != null) {
          shape.translate(-delta!);
        }
        break;
    }
  }
}





class AnnotationManager extends ChangeNotifier {
  static const int maxHistorySteps = 200;
  bool snapToBoard = true;

  final List<AnnotationShape> shapes = <AnnotationShape>[];

  AnnotationShape? _currentDrawingShape;

  AnnotationShape? get currentDrawingShape => _currentDrawingShape;

  final List<AnnotationCommand> _undoStack = <AnnotationCommand>[];
  final List<AnnotationCommand> _redoStack = <AnnotationCommand>[];


  AnnotationTool currentTool = AnnotationTool.circle;
  Color currentColor = Colors.red;

  AnnotationShape? _selectedShape;

  AnnotationShape? get selectedShape => _selectedShape;






  void translateShape(AnnotationShape shape, Offset delta) {
    if (!shapes.contains(shape)) {
      return;
    }
    shape.translate(delta);
    _redoStack.clear();
    _pushUndoCommand(
      AnnotationCommand(
        type: AnnotationCommandType.translateShape,
        shape: shape,
        delta: delta,
        manager: this,
      ),
    );
    notifyListeners();
  }

  void selectShape(AnnotationShape? shape) {
    _selectedShape = shape;
    notifyListeners();
  }

  void clearSelection() {
    _selectedShape = null;
    notifyListeners();
  }

  void setCurrentDrawingShape(AnnotationShape? shape) {
    _currentDrawingShape = shape;
    notifyListeners();
  }

  void addShape(AnnotationShape shape) {
    shapes.add(shape);
    _redoStack.clear();
    _pushUndoCommand(
      AnnotationCommand(
        type: AnnotationCommandType.addShape,
        shape: shape,
        manager: this,
      ),
    );
    notifyListeners();
  }

  void removeShape(AnnotationShape shape) {
    if (shapes.remove(shape)) {
      _redoStack.clear();
      _pushUndoCommand(
        AnnotationCommand(
          type: AnnotationCommandType.removeShape,
          shape: shape,
          manager: this,
        ),
      );
      notifyListeners();
    }
  }

  void changeColor(AnnotationShape shape, Color newColor) {
    if (!shapes.contains(shape)) {
      return;
    }
    final Color oldColor = shape.color;
    shape.color = newColor;
    _redoStack.clear();
    _pushUndoCommand(
      AnnotationCommand(
        type: AnnotationCommandType.changeColor,
        shape: shape,
        oldColor: oldColor,
        newColor: newColor,
        manager: this,
      ),
    );
    notifyListeners();
  }

  void changeText(AnnotationText shape, String newText) {
    final String oldText = shape.text;
    shape.text = newText;
    _redoStack.clear();
    _pushUndoCommand(
      AnnotationCommand(
        type: AnnotationCommandType.changeText,
        shape: shape,
        oldText: oldText,
        newText: newText,
        manager: this,
      ),
    );
    notifyListeners();
  }

  void moveText(AnnotationText shape, Offset oldOffset, Offset newOffset) {
    shape.point = newOffset;
    _redoStack.clear();
    _pushUndoCommand(
      AnnotationCommand(
        type: AnnotationCommandType.moveText,
        shape: shape,
        oldOffset: oldOffset,
        newOffset: newOffset,
        manager: this,
      ),
    );
    notifyListeners();
  }

  void clear() {
    shapes.clear();
    _currentDrawingShape = null;
    _undoStack.clear();
    _redoStack.clear();
    _selectedShape = null;
    notifyListeners();
  }

  void undo() {
    if (_undoStack.isNotEmpty) {
      final AnnotationCommand cmd = _undoStack.removeLast();
      cmd.undo();
      _redoStack.add(cmd);
      notifyListeners();
    }
  }

  void redo() {
    if (_redoStack.isNotEmpty) {
      final AnnotationCommand cmd = _redoStack.removeLast();
      cmd.redo();
      _undoStack.add(cmd);
      notifyListeners();
    }
  }





  void _pushUndoCommand(AnnotationCommand cmd) {
    _undoStack.add(cmd);
    if (_undoStack.length > maxHistorySteps) {
      _undoStack.removeAt(0);
    }
  }
}







class AnnotationPainter extends CustomPainter {
  const AnnotationPainter(this.manager);

  final AnnotationManager manager;

  @override
  void paint(Canvas canvas, Size size) {

    for (final AnnotationShape shape in manager.shapes) {
      shape.draw(canvas, size);
      if (shape == manager.selectedShape) {
        _drawHighlight(canvas, shape);
      }
    }

    final AnnotationShape? temp = manager.currentDrawingShape;
    if (temp != null) {
      temp.draw(canvas, size);
    }
  }

  void _drawHighlight(Canvas canvas, AnnotationShape shape) {
    final Paint p = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    if (shape is AnnotationCircle) {
      canvas.drawCircle(shape.center, shape.radius + 5, p);
    } else if (shape is AnnotationLine) {
      final Rect r = Rect.fromPoints(shape.start, shape.end).inflate(5);
      canvas.drawRect(r, p);
    } else if (shape is AnnotationArrow) {
      final Rect r = Rect.fromPoints(shape.start, shape.end).inflate(5);
      canvas.drawRect(r, p);
    } else if (shape is AnnotationRect) {
      final Rect r = Rect.fromPoints(shape.start, shape.end).inflate(5);
      canvas.drawRect(r, p);
    } else if (shape is AnnotationDot) {
      canvas.drawCircle(shape.point, shape.radius + 5, p);
    } else if (shape is AnnotationCross) {
      final double extent = shape.crossSize + 5.0;
      final Rect r = Rect.fromCenter(
        center: shape.point,
        width: extent * 2,
        height: extent * 2,
      );
      canvas.drawRect(r, p);
    } else if (shape is AnnotationText) {
      final TextSpan span = TextSpan(
        text: shape.text,
        style: TextStyle(color: shape.color, fontSize: shape.fontSize),
      );
      final TextPainter tp =
          TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      final Rect r = Rect.fromLTWH(
        shape.point.dx,
        shape.point.dy,
        tp.width,
        tp.height,
      ).inflate(5);
      canvas.drawRect(r, p);
    }
  }

  @override
  bool shouldRepaint(AnnotationPainter oldDelegate) => true;
}








class AnnotationOverlay extends StatefulWidget {
  const AnnotationOverlay({
    super.key,
    required this.annotationManager,
    required this.child,
    required this.gameBoardKey,
  });

  final AnnotationManager annotationManager;
  final Widget child;
  final GlobalKey gameBoardKey;

  @override
  State<AnnotationOverlay> createState() => _AnnotationOverlayState();
}

class _AnnotationOverlayState extends State<AnnotationOverlay> {

  Offset? _firstTapPosition;


  double get _pieceWidth {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) {

      return 0;
    }
    final RenderBox box = renderObject;
    final Size overlaySize = box.size;
    return ((overlaySize.width - (AppTheme.boardPadding * 2)) *
            DB().displaySettings.pieceWidth /
            6) -
        1;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[

        widget.child,


        Positioned.fill(
          child: GestureDetector(
            onTapDown: (TapDownDetails details) {
              final RenderBox box = context.findRenderObject()! as RenderBox;
              final Offset tapPos = box.globalToLocal(details.globalPosition);
              _handleTap(tapPos);
            },
            onLongPressStart: (LongPressStartDetails details) {
              _handleLongPressStart(details);
            },
            child: AnimatedBuilder(
              animation: widget.annotationManager,
              builder: (BuildContext context, _) {
                return CustomPaint(
                  painter: AnnotationPainter(widget.annotationManager),
                );
              },
            ),
          ),
        ),
      ],
    );
  }







  void _handleTap(Offset tapPos) {
    final AnnotationTool currentTool = widget.annotationManager.currentTool;
    final Color currentColor = widget.annotationManager.currentColor;


    Offset pos;
    if (currentTool == AnnotationTool.rect) {
      pos = tapPos;
    } else {
      pos = _snapToBoardIntersection(tapPos);
    }


    switch (currentTool) {
      case AnnotationTool.dot:
        _createDot(pos, currentColor);
        break;
      case AnnotationTool.cross:
        _createCross(pos, currentColor);
        break;
      case AnnotationTool.text:
        _createTextAt(pos, currentColor);
        break;
      case AnnotationTool.line:
      case AnnotationTool.arrow:
      case AnnotationTool.rect:

        _handleTwoTapTool(pos, currentTool, currentColor);
        break;
      case AnnotationTool.circle:
        _createCircle(pos, currentColor);
        break;
      case AnnotationTool.move:

        break;
    }

    setState(() {});
  }


  Offset _snapToBoardIntersection(Offset overlayLocalTap) {

    final RenderObject? ro =
        widget.gameBoardKey.currentContext?.findRenderObject();
    if (ro is! RenderBox) {
      logger.w('GameBoard RenderBox is not available. Using original tap.');
      return overlayLocalTap;
    }
    final RenderBox boardBox = ro;


    final RenderBox overlayBox = context.findRenderObject()! as RenderBox;
    final Offset globalTapPos = overlayBox.localToGlobal(overlayLocalTap);
    final Offset boardLocalTap = boardBox.globalToLocal(globalTapPos);
    final Size boardSize = boardBox.size;


    Offset bestBoardLocal = boardLocalTap;
    double minDistance = double.infinity;
    for (final Offset boardLogicalPoint in points) {
      final Offset candidate = offsetFromPoint(boardLogicalPoint, boardSize);
      final double dist = (candidate - boardLocalTap).distance;
      if (dist < minDistance) {
        minDistance = dist;
        bestBoardLocal = candidate;
      }
    }


    final Offset snappedGlobal = boardBox.localToGlobal(bestBoardLocal);
    final Offset snappedOverlayLocal = overlayBox.globalToLocal(snappedGlobal);
    return snappedOverlayLocal;
  }






  void _handleLongPressStart(LongPressStartDetails details) {
    final RenderBox box = context.findRenderObject()! as RenderBox;
    final Offset localPos = box.globalToLocal(details.globalPosition);

    final AnnotationShape? shape = _hitTestShape(localPos);
    if (shape == null) {
      return;
    }


    widget.annotationManager.selectShape(shape);

    final RenderBox? overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlayBox == null) {
      logger.w('Overlay render object is null');
      return;
    }

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        overlayBox.size.width - details.globalPosition.dx,
        overlayBox.size.height - details.globalPosition.dy,
      ),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'delete',
          child: Text(S.of(context).delete),
        ),
      ],
    ).then((String? selected) {
      if (selected == 'delete') {
        widget.annotationManager.removeShape(shape);
        setState(() {});
      }
    });
  }


  AnnotationShape? _hitTestShape(Offset tapPos) {
    final List<AnnotationShape> shapes = widget.annotationManager.shapes;
    for (int i = shapes.length - 1; i >= 0; i--) {
      if (shapes[i].hitTest(tapPos)) {
        return shapes[i];
      }
    }
    return null;
  }


  void _createDot(Offset point, Color color) {
    final double radius = _pieceWidth / 6;
    final AnnotationDot shape =
        AnnotationDot(point: point, color: color, radius: radius);
    widget.annotationManager.addShape(shape);
  }


  void _createCross(Offset point, Color color) {
    final double crossSize = _pieceWidth / 2;
    final AnnotationCross shape = AnnotationCross(
      point: point,
      color: color,
      crossSize: crossSize,
    );
    widget.annotationManager.addShape(shape);
  }


  void _createCircle(Offset point, Color color) {
    final double forcedRadius = _pieceWidth / 2;
    final AnnotationCircle shape = AnnotationCircle(
      center: point,
      radius: forcedRadius,
      color: color,
    );
    widget.annotationManager.addShape(shape);
  }


  Future<void> _createTextAt(Offset point, Color color) async {
    final TextEditingController controller = TextEditingController();

    final String? userText = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(S.of(context).addText),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: S.of(ctx).typeYourAnnotation,
          ),
          onSubmitted: (String val) => Navigator.pop(ctx, val),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(ctx).cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, controller.text);
            },
            child: Text(S.of(ctx).ok),
          ),
        ],
      ),
    );

    if (userText != null && userText.isNotEmpty) {
      final AnnotationText shape = AnnotationText(
        point: point,
        text: userText,
        color: color,
      );
      widget.annotationManager.addShape(shape);
    }
  }


  void _handleTwoTapTool(Offset tapPos, AnnotationTool tool, Color color) {
    if (_firstTapPosition == null) {
      _firstTapPosition = tapPos;
    } else {
      final Offset start = _firstTapPosition!;
      final Offset end = tapPos;

      switch (tool) {
        case AnnotationTool.line:
          widget.annotationManager.addShape(
            AnnotationLine(start: start, end: end, color: color),
          );
          break;
        case AnnotationTool.arrow:
          widget.annotationManager.addShape(
            AnnotationArrow(start: start, end: end, color: color),
          );
          break;
        case AnnotationTool.rect:

          widget.annotationManager.addShape(
            AnnotationRect(start: start, end: end, color: color),
          );
          break;
        case AnnotationTool.circle:
        case AnnotationTool.dot:
        case AnnotationTool.cross:
        case AnnotationTool.text:
        case AnnotationTool.move:
          break;
      }

      _firstTapPosition = null;
    }
  }
}


extension _OffsetDirection on Offset {}
