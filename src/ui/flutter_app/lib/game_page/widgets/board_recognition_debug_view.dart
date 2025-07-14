




import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../../generated/intl/l10n.dart';
import '../../shared/database/database.dart';
import '../../shared/services/logger.dart';
import '../services/board_image_recognition.dart';
import '../services/mill.dart';
import 'piece_overlay_painter.dart';


enum DebugStage {
  originalImage, // Original image
  resizedImage, // Resized image
  enhancedImage, // Contrast-enhanced image
  boardMaskRaw, // Initial board mask (unprocessed)
  boardMaskProcessed, // Processed board mask (after dilation/erosion)
  boardDetection, // Board region detection result
  boardPointsDetection, // Board point detection
  colorAnalysis, // Color analysis result
  pieceDetection, // Piece detection process
  finalResult, // Final recognition result
}


class BoardRecognitionDebugView extends StatefulWidget {
  const BoardRecognitionDebugView({
    super.key,
    required this.imageBytes,
    required this.boardPoints,
    required this.resultMap,
    required this.processedImageWidth,
    required this.processedImageHeight,
    this.showTitle = false,
    this.debugInfo,
  });

  final Uint8List imageBytes;
  final List<BoardPoint> boardPoints;
  final Map<int, PieceColor> resultMap;
  final int processedImageWidth;
  final int processedImageHeight;
  final bool showTitle;
  final BoardRecognitionDebugInfo? debugInfo;




  static String? generateTempFenString(Map<int, PieceColor> resultMap) {
    if (resultMap.isEmpty) {
      return null;
    }

    try {










      final StringBuffer fenBuffer = StringBuffer();


      String innerRing = "";

      for (int i = 0; i < 8; i++) {
        final int idx = 16 + ((i + 1) % 8);
        final PieceColor pieceColor = resultMap[idx] ?? PieceColor.none;
        innerRing += _pieceColorToFenChar(pieceColor);
      }


      String middleRing = "";
      for (int i = 0; i < 8; i++) {
        final int idx = 8 + ((i + 1) % 8);
        final PieceColor pieceColor = resultMap[idx] ?? PieceColor.none;
        middleRing += _pieceColorToFenChar(pieceColor);
      }


      String outerRing = "";
      for (int i = 0; i < 8; i++) {
        final int idx = (i + 1) % 8;
        final PieceColor pieceColor = resultMap[idx] ?? PieceColor.none;
        outerRing += _pieceColorToFenChar(pieceColor);
      }


      fenBuffer.write('$innerRing/$middleRing/$outerRing');


      int whiteCount = 0;
      int blackCount = 0;

      for (final PieceColor color in resultMap.values) {
        if (color == PieceColor.white) {
          whiteCount++;
        }
        if (color == PieceColor.black) {
          blackCount++;
        }
      }


      final int piecesCount = DB().ruleSettings.piecesCount;
      final String phase =
          (whiteCount < piecesCount || blackCount < piecesCount) ? "p" : "m";


      final String sideToMove = (whiteCount > blackCount) ? "b" : "w";


      final String action = (phase == "p") ? "p" : "s";


      fenBuffer.write(' $sideToMove $phase $action');


      fenBuffer.write(
          ' $whiteCount ${piecesCount - whiteCount} $blackCount ${piecesCount - blackCount}');


      fenBuffer.write(' 0 0 0 0 0 0 0 0 0 0 0');

      return fenBuffer.toString();
    } catch (e) {
      logger.e("Error generating temporary FEN: $e");
      return null;
    }
  }


  static String _pieceColorToFenChar(PieceColor color) {
    return color.string;
  }

  @override
  State<BoardRecognitionDebugView> createState() =>
      _BoardRecognitionDebugViewState();
}

class _BoardRecognitionDebugViewState extends State<BoardRecognitionDebugView> {
  DebugStage _currentStage = DebugStage.finalResult;


  Uint8List? _cachedOriginalImage;
  Uint8List? _cachedResizedImage;
  Uint8List? _cachedEnhancedImage;


  List<List<bool>>? _processedMask;

  @override
  void initState() {
    super.initState();
    _prepareImages();
  }

  @override
  void didUpdateWidget(BoardRecognitionDebugView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.debugInfo != widget.debugInfo) {
      _prepareImages();
    }
  }


  void _prepareImages() {

    if (widget.debugInfo?.originalImage != null) {
      _cachedOriginalImage =
          _convertImageToBytes(widget.debugInfo!.originalImage!);
    }


    if (widget.debugInfo?.processedImage != null) {

      final img.Image? resizedImage = widget.debugInfo?.originalImage != null
          ? img.copyResize(
              widget.debugInfo!.originalImage!,
              width: widget.processedImageWidth,
              height: widget.processedImageHeight,
            )
          : null;

      if (resizedImage != null) {
        _cachedResizedImage = _convertImageToBytes(resizedImage);
      }
    }


    if (widget.debugInfo?.processedImage != null) {
      _cachedEnhancedImage =
          _convertImageToBytes(widget.debugInfo!.processedImage!);
    }


    if (widget.debugInfo?.boardMask != null) {


      _processedMask = List<List<bool>>.generate(
        widget.debugInfo!.boardMask!.length,
        (int i) => List<bool>.from(widget.debugInfo!.boardMask![i]),
      );


      if (_processedMask != null) {

      }
    }
  }


  Uint8List _convertImageToBytes(img.Image image) {
    return Uint8List.fromList(img.encodeJpg(image));
  }

  @override
  Widget build(BuildContext context) {

    final Widget visualizationWidget = AspectRatio(
      aspectRatio: widget.processedImageWidth / widget.processedImageHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[

            _buildBaseLayer(),


            _buildOverlayLayer(),
          ],
        ),
      ),
    );


    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[

        if (widget.showTitle)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              S.of(context).boardRecognitionResult,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),


        if (widget.debugInfo != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildStageSelector(),
          ),


        Padding(
          padding: const EdgeInsets.all(8.0),
          child: visualizationWidget,
        ),


        if (widget.debugInfo != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildStageInfo(),
          ),
      ],
    );
  }


  Widget _buildStageSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _stageButton('1. Original Image', DebugStage.originalImage),
            _stageButton('2. Resized Image', DebugStage.resizedImage),
            _stageButton('3. Enhanced Contrast', DebugStage.enhancedImage),
            _stageButton('4. Initial Mask', DebugStage.boardMaskRaw),
            _stageButton('5. Processed Mask', DebugStage.boardMaskProcessed),
            _stageButton('6. Board Detection', DebugStage.boardDetection),
            _stageButton('7. Point Detection', DebugStage.boardPointsDetection),
            _stageButton('8. Color Analysis', DebugStage.colorAnalysis),
            _stageButton('9. Piece Detection', DebugStage.pieceDetection),
            _stageButton('10. Final Result', DebugStage.finalResult),
          ],
        ),
      ),
    );
  }


  Widget _stageButton(String label, DebugStage stage) {
    final bool isSelected = _currentStage == stage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _currentStage = stage;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
          minimumSize: const Size(10, 30),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(label, style: const TextStyle(fontSize: 10)),
      ),
    );
  }


  Widget _buildOverlayLayer() {
    if (widget.debugInfo == null) {
      return const SizedBox.shrink();
    }


    if (widget.imageBytes.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final bool boardDetected = widget.boardPoints.isNotEmpty ||
        (widget.debugInfo!.boardRect != null &&
            !(widget.debugInfo!.boardRect!.width <= 0 ||
                widget.debugInfo!.boardRect!.height <= 0));


    switch (_currentStage) {
      case DebugStage.boardDetection:
        if (!boardDetected) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    S.of(context).noValidBoardDetected,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please try adjusting the camera angle or lighting conditions',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
          );
        } else if (widget.debugInfo!.boardRect != null &&
            !(widget.debugInfo!.boardRect!.width <= 0 ||
                widget.debugInfo!.boardRect!.height <= 0)) {

          return BoardRectOverlay(
            boardRect: widget.debugInfo!.boardRect!,
            imageSize: Size(
              widget.processedImageWidth.toDouble(),
              widget.processedImageHeight.toDouble(),
            ),
          );
        } else {

          return CustomPaint(
            size: Size.infinite,
            painter: PieceOverlayPainter(
              boardPoints: widget.boardPoints,
              resultMap: widget.resultMap,
              imageSize: Size(
                widget.processedImageWidth.toDouble(),
                widget.processedImageHeight.toDouble(),
              ),
              boardRect: widget.debugInfo?.boardRect,
            ),
          );
        }

      case DebugStage.boardPointsDetection:

        if (widget.boardPoints.isEmpty) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red, width: 3),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    S.of(context).noBoardPointDetected,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return CustomPaint(
          size: Size.infinite,
          painter: BoardPointsDebugPainter(
            boardPoints: widget.boardPoints,
            imageSize: Size(
              widget.processedImageWidth.toDouble(),
              widget.processedImageHeight.toDouble(),
            ),
          ),
        );

      case DebugStage.colorAnalysis:
        if (widget.debugInfo?.colorProfile == null) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                S.of(context).colorAnalysisFailed,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          );
        }
        return CustomPaint(
          size: Size.infinite,
          painter: ColorAnalysisPainter(
            boardPoints: widget.boardPoints,
            colorProfile: widget.debugInfo?.colorProfile,
            imageSize: Size(
              widget.processedImageWidth.toDouble(),
              widget.processedImageHeight.toDouble(),
            ),
          ),
        );

      case DebugStage.pieceDetection:
        if (widget.boardPoints.isEmpty) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                S.of(context).noBoardPointDetectedCannotIdentifyPiece,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          );
        }
        return CustomPaint(
          size: Size.infinite,
          painter: PieceDetectionPainter(
            boardPoints: widget.boardPoints,
            resultMap: widget.resultMap,
            imageSize: Size(
              widget.processedImageWidth.toDouble(),
              widget.processedImageHeight.toDouble(),
            ),
            showDetails: true,
          ),
        );

      case DebugStage.finalResult:
        if (widget.boardPoints.isEmpty) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Final Recognition Failed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(S.of(context).entireRecognitionProcessFailedToComplete),
                Text(
                    S.of(context).suggestionTryTakingAClearerPictureOfTheBoard),
              ],
            ),
          );
        }

        int whiteCount = 0, blackCount = 0;
        for (final PieceColor color in widget.resultMap.values) {
          if (color == PieceColor.white) {
            whiteCount++;
          }
          if (color == PieceColor.black) {
            blackCount++;
          }
        }


        final String? fenString =
            BoardRecognitionDebugView.generateTempFenString(widget.resultMap);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Final Recognition Result: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('White Pieces: $whiteCount'),
              Text('Black Pieces: $blackCount'),
              const Text(
                  'Red Circle Indicates Black Pieces, Green Circle Indicates White Pieces'),
              const SizedBox(height: 10),

              if (fenString != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'FEN:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            fenString,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Click S.of(context).applyToBoard to set up this position',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 11,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );

      case DebugStage.originalImage:
      case DebugStage.resizedImage:
      case DebugStage.enhancedImage:
      case DebugStage.boardMaskRaw:
      case DebugStage.boardMaskProcessed:
        return const SizedBox.shrink();
    }
  }


  Widget _buildBaseLayer() {
    switch (_currentStage) {
      case DebugStage.originalImage:

        if (_cachedOriginalImage != null) {
          return Image.memory(_cachedOriginalImage!, fit: BoxFit.contain);
        }
        return _buildImageNotAvailable('Original Image');

      case DebugStage.resizedImage:

        if (_cachedResizedImage != null) {
          return Image.memory(_cachedResizedImage!, fit: BoxFit.contain);
        }
        return _buildImageNotAvailable('Resized Image');

      case DebugStage.enhancedImage:

        if (_cachedEnhancedImage != null) {
          return Image.memory(_cachedEnhancedImage!, fit: BoxFit.contain);
        }
        return _buildImageNotAvailable('Enhanced Contrast Image');

      case DebugStage.boardMaskRaw:

        if (widget.debugInfo?.boardMask != null) {
          return CustomPaint(
            painter: MaskPainter(
              mask: widget.debugInfo!.boardMask!,
              imageSize: Size(
                widget.processedImageWidth.toDouble(),
                widget.processedImageHeight.toDouble(),
              ),
              maskColor: Colors.blue.withValues(alpha: 0.7),
              label: 'Initial Mask',
            ),
          );
        }
        return _buildImageNotAvailable('Initial Board Mask');

      case DebugStage.boardMaskProcessed:

        if (_processedMask != null) {
          return CustomPaint(
            painter: MaskPainter(
              mask: _processedMask!,
              imageSize: Size(
                widget.processedImageWidth.toDouble(),
                widget.processedImageHeight.toDouble(),
              ),
              maskColor: Colors.green.withValues(alpha: 0.7),
              label: 'Processed Mask',
            ),
          );
        }
        return _buildImageNotAvailable('Processed Mask');

      case DebugStage.boardDetection:

        return Image.memory(widget.imageBytes, fit: BoxFit.cover);

      case DebugStage.boardPointsDetection:
      case DebugStage.colorAnalysis:
      case DebugStage.pieceDetection:
      case DebugStage.finalResult:
        return Image.memory(widget.imageBytes, fit: BoxFit.cover);
    }
  }


  Widget _buildImageNotAvailable(String label) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.image_not_supported, size: 48),
          Text('$label Not Available'),
        ],
      ),
    );
  }


  Widget _buildStageInfo() {
    switch (_currentStage) {
      case DebugStage.originalImage:
        final img.Image? original = widget.debugInfo?.originalImage;
        if (original == null) {
          return const Text('Original Image Information Not Available');
        }
        return Text(
          'Original Image: ${original.width}x${original.height} Pixels',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );

      case DebugStage.resizedImage:
        return Text(
          'Resized: ${widget.processedImageWidth}x${widget.processedImageHeight} Pixels',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );

      case DebugStage.enhancedImage:
        final ImageCharacteristics? chars = widget.debugInfo?.characteristics;
        if (chars == null) {
          return const Text('Enhanced Image Information Not Available');
        }
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Enhanced Contrast: Contrast Factor=1.8',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Brightness=${chars.averageBrightness.toStringAsFixed(1)}, '
                '${chars.isDarkBackground ? "Dark Background" : "Light Background"}, '
                'Contrast=${chars.isHighContrast ? "High" : "Low"}, '
                'Contrast Ratio=${chars.contrastRatio.toStringAsFixed(2)}',
              ),
            ],
          ),
        );

      case DebugStage.boardMaskRaw:
        final List<List<bool>>? mask = widget.debugInfo?.boardMask;
        if (mask == null) {
          return const Text('Board Mask Information Not Available');
        }


        int setPoints = 0;
        for (final List<bool> row in mask) {
          for (final bool value in row) {
            if (value) {
              setPoints++;
            }
          }
        }
        return Text(
          'Initial Board Mask: ${mask.length} Rows, Mask Point Count=$setPoints',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );

      case DebugStage.boardMaskProcessed:
        return const Text(
          'Mask Processing: Dilation (Expand Area) -> Erosion (Remove Noise)',
          style: TextStyle(fontWeight: FontWeight.bold),
        );

      case DebugStage.boardDetection:
        final math.Rectangle<int>? rect = widget.debugInfo?.boardRect;
        if (rect == null) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  S.of(context).boardDetectionFailed,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Possible Reasons:'),
                const Text('1. Insufficient Board Area Contrast'),
                const Text('2. Board is Obstructed or Out of Image Range'),
                const Text(
                    '3. Poor Lighting Conditions Causing Board Boundary Blur'),
                const Text(
                    'Suggestion: Try Taking a Picture in a Well-lit Environment to Ensure Complete and Clear Visibility of the Board'),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Board Region Detection Result: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Top-left: (${rect.left}, ${rect.top})'),
              Text('Size: Width=${rect.width}, Height=${rect.height}'),
              Text(
                  'Aspect Ratio: ${(rect.width / rect.height).toStringAsFixed(2)}'),
              const Text('Yellow Rectangle Indicates Detected Board Area'),
            ],
          ),
        );

      case DebugStage.boardPointsDetection:
        final int pointCount = widget.boardPoints.length;
        if (pointCount == 0) {
          return const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'No board point detected!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 4),
                Text('Possible Reasons:'),
                Text('1. Board Area Detection Failed'),
                Text(
                    '2. Board Pattern Does Not Match Standard Nine-piece Chess Layout'),
                Text(
                    'Suggestion: Ensure Using Standard Nine-piece Chess Board'),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Board Point Detection Result: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Detected $pointCount Points (Should Be 24)'),
              const Text(
                  'Blue Circle Indicates Detected Points, Number Indicates Point Index'),
              if (pointCount < 24)
                const Text(
                    'Warning: Point Count Less Than 24, Detection May Be Inaccurate',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        );

      case DebugStage.colorAnalysis:
        final ColorProfile? profile = widget.debugInfo?.colorProfile;
        if (profile == null) {
          return const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Color Analysis Failed!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 4),
                Text('Possible Reasons:'),
                Text('1. Board Area or Point Detection Failed'),
                Text(
                    '2. Insufficient Image Contrast, Difficult to Distinguish Colors'),
                Text(
                    'Suggestion: Take a Picture in a Uniformly Lit Environment'),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Color Analysis Result: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  'White Mean: ${profile.whiteMean.toStringAsFixed(1)}, Standard Deviation: ${profile.whiteStd.toStringAsFixed(1)}'),
              Text(
                  'Black Mean: ${profile.blackMean.toStringAsFixed(1)}, Standard Deviation: ${profile.blackStd.toStringAsFixed(1)}'),
              Text(
                  'Empty Mean: ${profile.emptyMean.toStringAsFixed(1)}, Standard Deviation: ${profile.emptyStd.toStringAsFixed(1)}'),
              const Text(
                  'Orange Indicates White Sample, Blue Indicates Black Sample, Green Indicates Empty Sample'),
            ],
          ),
        );

      case DebugStage.pieceDetection:
        if (widget.boardPoints.isEmpty) {
          return const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Piece Detection Failed!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 4),
                Text('Possible Reasons:'),
                Text('1. Board Point Detection Failed'),
                Text('2. Unable to Determine Sampling Point Location'),
                Text(
                    'Suggestion: Ensure Clear Visibility of the Board and Pieces'),
              ],
            ),
          );
        }
        int whiteCount = 0, blackCount = 0;
        for (final PieceColor color in widget.resultMap.values) {
          if (color == PieceColor.white) {
            whiteCount++;
          }
          if (color == PieceColor.black) {
            blackCount++;
          }
        }
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Piece Detection Process: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                  'Analyze Color Characteristics of Each Point to Determine If There Is a Piece'),
              Text(
                  'White Threshold: ${widget.debugInfo?.characteristics?.whiteBrightnessThreshold ?? 0}'),
              Text(
                  'Black Threshold: ${widget.debugInfo?.characteristics?.blackBrightnessThreshold ?? 0}'),
              Text(
                  'Currently Identified: White Pieces=$whiteCount, Black Pieces=$blackCount'),
              const Text(
                  'Yellow Outline Sampling Area, Red Indicates Identified as Black, Green Indicates Identified as White'),
            ],
          ),
        );

      case DebugStage.finalResult:
        if (widget.boardPoints.isEmpty) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Final Recognition Failed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(S.of(context).entireRecognitionProcessFailedToComplete),
                Text(
                    S.of(context).suggestionTryTakingAClearerPictureOfTheBoard),
              ],
            ),
          );
        }

        int whiteCount = 0, blackCount = 0;
        for (final PieceColor color in widget.resultMap.values) {
          if (color == PieceColor.white) {
            whiteCount++;
          }
          if (color == PieceColor.black) {
            blackCount++;
          }
        }


        final String? fenString =
            BoardRecognitionDebugView.generateTempFenString(widget.resultMap);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Final Recognition Result: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('White Pieces: $whiteCount'),
              Text('Black Pieces: $blackCount'),
              const Text(
                  'Red Circle Indicates Black Pieces, Green Circle Indicates White Pieces'),
              const SizedBox(height: 10),

              if (fenString != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'FEN:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            fenString,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Click S.of(context).applyToBoard to set up this position',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 11,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
    }
  }
}


class MaskPainter extends CustomPainter {
  MaskPainter({
    required this.mask,
    required this.imageSize,
    this.maskColor = Colors.white,
    this.label,
  });

  final List<List<bool>> mask;
  final Size imageSize;
  final Color maskColor;
  final String? label;

  @override
  void paint(Canvas canvas, Size size) {

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black,
    );


    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;


    final Paint maskPaint = Paint()..color = maskColor.withValues(alpha: 0.7);


    for (int y = 0; y < mask.length; y += 2) {
      for (int x = 0; x < mask[y].length; x += 2) {
        if (y < mask.length && x < mask[y].length && mask[y][x]) {
          canvas.drawRect(
            Rect.fromLTWH(
              x * scaleX,
              y * scaleY,
              2 * scaleX,
              2 * scaleY,
            ),
            maskPaint,
          );
        }
      }
    }


    if (label != null) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.black54,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        const Offset(10, 10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


class BoardPointsDebugPainter extends CustomPainter {
  BoardPointsDebugPainter({
    required this.boardPoints,
    required this.imageSize,
  });

  final List<BoardPoint> boardPoints;
  final Size imageSize;

  @override
  void paint(Canvas canvas, Size size) {

    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;


    for (int i = 0; i < boardPoints.length; i++) {
      final BoardPoint point = boardPoints[i];


      final Paint pointPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(
        Offset(point.x * scaleX, point.y * scaleY),
        point.radius * scaleX * 0.8,
        pointPaint,
      );


      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: '$i',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.black54,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          point.x * scaleX - textPainter.width / 2,
          point.y * scaleY - textPainter.height / 2,
        ),
      );


      final Paint innerPointPaint = Paint()
        ..color = i < 8 ? Colors.red : (i < 16 ? Colors.yellow : Colors.green)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(point.x * scaleX, point.y * scaleY),
        3.0,
        innerPointPaint,
      );
    }


    final TextPainter legendPainter = TextPainter(
      text: const TextSpan(
        text: 'Red=Outer Ring, Yellow=Middle Ring, Green=Inner Ring',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          backgroundColor: Colors.black54,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    legendPainter.layout();
    legendPainter.paint(
      canvas,
      Offset(10, size.height - legendPainter.height - 10),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


class ColorAnalysisPainter extends CustomPainter {
  ColorAnalysisPainter({
    required this.boardPoints,
    required this.imageSize,
    this.colorProfile,
  });

  final List<BoardPoint> boardPoints;
  final Size imageSize;
  final ColorProfile? colorProfile;

  @override
  void paint(Canvas canvas, Size size) {
    if (colorProfile == null) {
      return;
    }


    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;


    for (int i = 0; i < boardPoints.length; i++) {
      final BoardPoint point = boardPoints[i];


      final double brightness = (i % 3 == 0)
          ? colorProfile!
              .whiteMean // Example: Take every 3rd point as white sample
          : (i % 3 == 1)
              ? colorProfile!
                  .blackMean // Example: Take every 3rd point as black sample
              : colorProfile!
                  .emptyMean;


      final Color pointColor = (i % 3 == 0)
          ? Colors.orange // White sample
          : (i % 3 == 1)
              ? Colors.blue // Black sample
              : Colors.green;


      final Paint pointPaint = Paint()
        ..color = pointColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(
        Offset(point.x * scaleX, point.y * scaleY),
        point.radius * scaleX * 0.7,
        pointPaint,
      );


      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: brightness.toStringAsFixed(0),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            backgroundColor: Colors.black54,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          point.x * scaleX - textPainter.width / 2,
          point.y * scaleY - textPainter.height / 2,
        ),
      );
    }


    final TextPainter statsPainter = TextPainter(
      text: TextSpan(
        children: <TextSpan>[
          const TextSpan(
            text: 'Color Statistics: ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text:
                'White=${colorProfile!.whiteMean.toStringAsFixed(1)}±${colorProfile!.whiteStd.toStringAsFixed(1)} ',
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 12,
            ),
          ),
          TextSpan(
            text:
                'Black=${colorProfile!.blackMean.toStringAsFixed(1)}±${colorProfile!.blackStd.toStringAsFixed(1)} ',
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 12,
            ),
          ),
          TextSpan(
            text:
                'Empty=${colorProfile!.emptyMean.toStringAsFixed(1)}±${colorProfile!.emptyStd.toStringAsFixed(1)}',
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
            ),
          ),
        ],
        style: const TextStyle(
          backgroundColor: Colors.black54,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    statsPainter.layout();
    statsPainter.paint(
      canvas,
      const Offset(10, 10),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


class PieceDetectionPainter extends CustomPainter {
  PieceDetectionPainter({
    required this.boardPoints,
    required this.resultMap,
    required this.imageSize,
    this.showDetails = false,
  });

  final List<BoardPoint> boardPoints;
  final Map<int, PieceColor> resultMap;
  final Size imageSize;
  final bool showDetails;

  @override
  void paint(Canvas canvas, Size size) {

    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;


    for (int i = 0; i < boardPoints.length; i++) {
      final BoardPoint point = boardPoints[i];
      final PieceColor? pieceColor = resultMap[i];


      final Paint samplingAreaPaint = Paint()
        ..color = Colors.yellow.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawCircle(
        Offset(point.x * scaleX, point.y * scaleY),
        point.radius *
            scaleX *
            0.75, // Sampling area slightly smaller than actual radius
        samplingAreaPaint,
      );


      if (pieceColor != null && pieceColor != PieceColor.none) {
        final Paint piecePaint = Paint()
          ..color = pieceColor == PieceColor.white ? Colors.green : Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

        canvas.drawCircle(
          Offset(point.x * scaleX, point.y * scaleY),
          point.radius * scaleX,
          piecePaint,
        );


        if (showDetails) {
          final TextPainter textPainter = TextPainter(
            text: TextSpan(
              text: pieceColor == PieceColor.white ? 'W' : 'B',
              style: TextStyle(
                color:
                    pieceColor == PieceColor.white ? Colors.green : Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.black54,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(
              point.x * scaleX - textPainter.width / 2,
              point.y * scaleY - textPainter.height / 2,
            ),
          );
        }
      } else {

        if (showDetails) {
          final Paint emptyPaint = Paint()
            ..color = Colors.grey
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;

          final double crossSize = point.radius * scaleX * 0.4;

          canvas.drawLine(
            Offset(point.x * scaleX - crossSize, point.y * scaleY - crossSize),
            Offset(point.x * scaleX + crossSize, point.y * scaleY + crossSize),
            emptyPaint,
          );

          canvas.drawLine(
            Offset(point.x * scaleX + crossSize, point.y * scaleY - crossSize),
            Offset(point.x * scaleX - crossSize, point.y * scaleY + crossSize),
            emptyPaint,
          );
        }
      }


      final TextPainter indexPainter = TextPainter(
        text: TextSpan(
          text: '$i',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            backgroundColor: Colors.black54,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      indexPainter.layout();
      indexPainter.paint(
        canvas,
        Offset(
          point.x * scaleX - 12,
          point.y * scaleY - 12,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


class BoardRectOverlay extends StatelessWidget {
  const BoardRectOverlay({
    super.key,
    required this.boardRect,
    required this.imageSize,
  });

  final math.Rectangle<int> boardRect;
  final Size imageSize;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: BoardRectPainter(
        boardRect: boardRect,
        imageSize: imageSize,
      ),
    );
  }
}


class BoardRectPainter extends CustomPainter {
  BoardRectPainter({
    required this.boardRect,
    required this.imageSize,
  });

  final math.Rectangle<int> boardRect;
  final Size imageSize;

  @override
  void paint(Canvas canvas, Size size) {

    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    final Rect scaledRect = Rect.fromLTWH(
      boardRect.left * scaleX,
      boardRect.top * scaleY,
      boardRect.width * scaleX,
      boardRect.height * scaleY,
    );


    final Paint rectPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;


    final Path path = Path();
    const double dashWidth = 10.0;
    const double dashSpace = 5.0;
    double distance = 0.0;


    path.moveTo(scaledRect.left, scaledRect.top);
    bool draw = true;
    while (distance < scaledRect.width) {
      double currentWidth = distance + (draw ? dashWidth : dashSpace);
      if (currentWidth > scaledRect.width) {
        currentWidth = scaledRect.width;
      }

      if (draw) {
        path.lineTo(scaledRect.left + currentWidth, scaledRect.top);
      } else {
        path.moveTo(scaledRect.left + currentWidth, scaledRect.top);
      }

      distance = currentWidth;
      draw = !draw;
    }


    distance = 0.0;
    draw = true;
    while (distance < scaledRect.height) {
      double currentHeight = distance + (draw ? dashWidth : dashSpace);
      if (currentHeight > scaledRect.height) {
        currentHeight = scaledRect.height;
      }

      if (draw) {
        path.lineTo(scaledRect.right, scaledRect.top + currentHeight);
      } else {
        path.moveTo(scaledRect.right, scaledRect.top + currentHeight);
      }

      distance = currentHeight;
      draw = !draw;
    }


    distance = 0.0;
    draw = true;
    while (distance < scaledRect.width) {
      double currentWidth = distance + (draw ? dashWidth : dashSpace);
      if (currentWidth > scaledRect.width) {
        currentWidth = scaledRect.width;
      }

      if (draw) {
        path.lineTo(scaledRect.right - currentWidth, scaledRect.bottom);
      } else {
        path.moveTo(scaledRect.right - currentWidth, scaledRect.bottom);
      }

      distance = currentWidth;
      draw = !draw;
    }


    distance = 0.0;
    draw = true;
    while (distance < scaledRect.height) {
      double currentHeight = distance + (draw ? dashWidth : dashSpace);
      if (currentHeight > scaledRect.height) {
        currentHeight = scaledRect.height;
      }

      if (draw) {
        path.lineTo(scaledRect.left, scaledRect.bottom - currentHeight);
      } else {
        path.moveTo(scaledRect.left, scaledRect.bottom - currentHeight);
      }

      distance = currentHeight;
      draw = !draw;
    }

    canvas.drawPath(path, rectPaint);


    const double cornerSize = 15.0;
    final Paint cornerPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;


    canvas.drawLine(
      Offset(scaledRect.left, scaledRect.top + cornerSize),
      Offset(scaledRect.left, scaledRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scaledRect.left, scaledRect.top),
      Offset(scaledRect.left + cornerSize, scaledRect.top),
      cornerPaint,
    );


    canvas.drawLine(
      Offset(scaledRect.right - cornerSize, scaledRect.top),
      Offset(scaledRect.right, scaledRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scaledRect.right, scaledRect.top),
      Offset(scaledRect.right, scaledRect.top + cornerSize),
      cornerPaint,
    );


    canvas.drawLine(
      Offset(scaledRect.right, scaledRect.bottom - cornerSize),
      Offset(scaledRect.right, scaledRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scaledRect.right, scaledRect.bottom),
      Offset(scaledRect.right - cornerSize, scaledRect.bottom),
      cornerPaint,
    );


    canvas.drawLine(
      Offset(scaledRect.left + cornerSize, scaledRect.bottom),
      Offset(scaledRect.left, scaledRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scaledRect.left, scaledRect.bottom),
      Offset(scaledRect.left, scaledRect.bottom - cornerSize),
      cornerPaint,
    );


    const TextSpan textSpan = TextSpan(
      text: 'Detected Board Area',
      style: TextStyle(
        color: Colors.yellow,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        backgroundColor: Colors.black54,
      ),
    );

    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        scaledRect.left + 5,
        scaledRect.top - textPainter.height - 5,
      ),
    );


    final TextSpan sizeSpan = TextSpan(
      text: '${boardRect.width} x ${boardRect.height}',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        backgroundColor: Colors.black54,
      ),
    );

    final TextPainter sizePainter = TextPainter(
      text: sizeSpan,
      textDirection: TextDirection.ltr,
    );

    sizePainter.layout();
    sizePainter.paint(
      canvas,
      Offset(
        scaledRect.right - sizePainter.width - 5,
        scaledRect.bottom + 5,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
