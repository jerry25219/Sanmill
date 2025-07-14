




import 'package:flutter/material.dart';

import '../services/painters/vignette_painter.dart';

class VignetteOverlay extends StatelessWidget {
  const VignetteOverlay({super.key, required this.gameBoardRect});

  final Rect gameBoardRect;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      key: const Key('vignette_overlay_ignore_pointer'),
      child: CustomPaint(
        key: const Key('vignette_overlay_custom_paint'),
        size: Size.infinite,
        painter: VignettePainter(gameBoardRect),
      ),
    );
  }
}
