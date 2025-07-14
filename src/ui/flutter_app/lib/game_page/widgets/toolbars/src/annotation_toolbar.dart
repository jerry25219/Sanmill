




part of '../game_toolbar.dart';



class AnnotationToolbar extends StatefulWidget {
  const AnnotationToolbar({
    super.key,
    required this.annotationManager,
    required this.isAnnotationMode,
    required this.onToggleAnnotationMode,
  });

  final AnnotationManager annotationManager;
  final bool isAnnotationMode;
  final VoidCallback onToggleAnnotationMode;

  @override
  State<AnnotationToolbar> createState() => _AnnotationToolbarState();
}

class _AnnotationToolbarState extends State<AnnotationToolbar> {
  final List<Color> _colorOptions = const <Color>[
    Colors.white,
    Colors.black,
    Colors.grey,
    Colors.red,
    Colors.yellow,
    Colors.blue,
    Colors.green,
    Colors.pink,
    Colors.purple,
    Colors.indigo,
  ];

  Future<void> _takeScreenshot(String storageLocation,
      [String? filename]) async {
    await ScreenshotService.takeScreenshot(storageLocation, filename);
  }


  Future<bool?> _showClearConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(S.of(context).confirmClear),
        content: Text(S.of(context).areYouSureYouWantToClearAllAnnotations),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.of(context).yes),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[850],
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: widget.isAnnotationMode
          ? _buildExpandedToolbar(context)
          : _buildCollapsedToolbar(context),
    );
  }

  Widget _buildCollapsedToolbar(BuildContext context) {
    return Center(
      child: IconButton(
        tooltip: S.of(context).enterAnnotationMode,
        icon: const Icon(
          FluentIcons.draw_image_24_regular,
          color: Colors.white,
        ),
        onPressed: widget.onToggleAnnotationMode,
      ),
    );
  }

  Widget _buildExpandedToolbar(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildToolRow(context),
        const SizedBox(height: 4),
        _buildColorRow(context),
        const SizedBox(height: 4),
        _buildControlRow(context),
      ],
    );
  }



  Widget _buildToolRow(BuildContext context) {
    final AnnotationTool currentTool = widget.annotationManager.currentTool;
    final List<AnnotationTool> tools = AnnotationTool.values
        .where((AnnotationTool t) => t != AnnotationTool.move)
        .toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: tools.map((AnnotationTool tool) {
        final bool isSelected = (currentTool == tool);
        return Semantics(

          label: _toolLabel(context, tool),
          button: true,
          child: InkWell(
            onTap: () {
              setState(() => widget.annotationManager.currentTool = tool);
            },
            borderRadius: BorderRadius.circular(8.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(

                color: isSelected
                    ? Colors.yellow.withAlpha(25)
                    : Colors.transparent,

                border: Border.all(
                    color: isSelected ? Colors.yellow : Colors.transparent,
                    width: 2),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                _iconForTool(tool),
                color: isSelected ? Colors.white : Colors.grey[300],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }



  String _toolLabel(BuildContext context, AnnotationTool tool) {

    switch (tool) {
      case AnnotationTool.line:
        return "Line Tool";
      case AnnotationTool.arrow:
        return "Arrow Tool";
      case AnnotationTool.circle:
        return "Circle Tool";
      case AnnotationTool.dot:
        return "Dot Tool";
      case AnnotationTool.cross:
        return "Cross Tool";
      case AnnotationTool.rect:
        return "Rectangle Tool";
      case AnnotationTool.text:
        return "Text Tool";
      case AnnotationTool.move:
        return "Move Tool";
    }
  }



  String _colorName(Color color) {

    if (color == Colors.white) {
      return "white";
    }
    if (color == Colors.black) {
      return "black";
    }
    if (color == Colors.grey) {
      return "grey";
    }
    if (color == Colors.red) {
      return "red";
    }
    if (color == Colors.yellow) {
      return "yellow";
    }
    if (color == Colors.blue) {
      return "blue";
    }
    if (color == Colors.green) {
      return "green";
    }
    if (color == Colors.pink) {
      return "pink";
    }
    if (color == Colors.purple) {
      return "purple";
    }
    if (color == Colors.indigo) {
      return "indigo";
    }
    return "unknown";
  }



  Widget _buildColorRow(BuildContext context) {
    final AnnotationShape? selectedShape =
        widget.annotationManager.selectedShape;
    final Color activeColor =
        selectedShape?.color ?? widget.annotationManager.currentColor;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _colorOptions.map((Color color) {
          final bool isSelected = (color == activeColor);
          return Semantics(

            label: 'Select ${_colorName(color)} color',
            button: true,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (selectedShape != null) {
                    widget.annotationManager.changeColor(selectedShape, color);
                  } else {
                    widget.annotationManager.currentColor = color;
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(

                  border: Border.all(
                    color: isSelected ? Colors.yellow : Colors.transparent,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }


  Widget _buildControlRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildControlButton(
          context,
          tooltip: S.of(context).exitAnnotationMode,
          icon: FluentIcons.games_24_regular,
          onTap: widget.onToggleAnnotationMode,
        ),
        _buildControlButton(
          context,
          tooltip: 'Undo',
          icon: FluentIcons.arrow_undo_24_regular,
          onTap: () => setState(() => widget.annotationManager.undo()),
        ),
        _buildControlButton(
          context,
          tooltip: 'Redo',
          icon: FluentIcons.arrow_redo_24_regular,
          onTap: () => setState(() => widget.annotationManager.redo()),
        ),
        _buildControlButton(
          context,
          tooltip: S.of(context).clearAllAnnotations,
          icon: FluentIcons.delete_24_regular,
          onTap: () async {
            final bool? confirmed = await _showClearConfirmationDialog(context);
            if (confirmed != null && confirmed == true) {
              setState(() => widget.annotationManager.clear());
            }
          },
        ),
        _buildControlButton(
          context,
          tooltip: S.of(context).takeScreenshot,
          icon: FluentIcons.camera_24_regular,
          onTap: () => _takeScreenshot("gallery"),
        ),
      ],
    );
  }


  IconData _iconForTool(AnnotationTool tool) {
    switch (tool) {
      case AnnotationTool.line:
        return FluentIcons.line_horizontal_1_24_regular;
      case AnnotationTool.arrow:
        return FluentIcons.arrow_right_24_regular;
      case AnnotationTool.circle:
        return FluentIcons.circle_24_regular;
      case AnnotationTool.dot:
        return FluentIcons.circle_small_24_filled;
      case AnnotationTool.cross:
        return FluentIcons.dismiss_24_regular;
      case AnnotationTool.rect:
        return FluentIcons.rectangle_landscape_24_regular;
      case AnnotationTool.text:
        return FluentIcons.text_font_24_regular;
      case AnnotationTool.move:
        return FluentIcons.arrow_move_24_regular;
    }
  }


  Widget _buildControlButton(
    BuildContext context, {
    required String tooltip,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return _ControlButton(
      tooltip: tooltip,
      icon: icon,
      onTap: onTap,
    );
  }
}



class _ControlButton extends StatefulWidget {
  const _ControlButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {

    return Semantics(
      label: widget.tooltip,
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,

            decoration: BoxDecoration(
              color: _isPressed
                  ? Colors.yellow.withValues(alpha: 0.2)
                  : _isHovered
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Tooltip(
              message: widget.tooltip,
              child: Icon(
                widget.icon,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
