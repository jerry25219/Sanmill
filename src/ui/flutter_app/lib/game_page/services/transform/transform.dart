




import '../mill.dart';

enum TransformationType {
  identity,
  rotate90Degrees,
  horizontalFlip,
  verticalFlip,
  innerOuterFlip
}


final Map<TransformationType, List<int>> transformationMap =
    <TransformationType, List<int>>{
  TransformationType.identity: List<int>.generate(24, (int i) => i),
  TransformationType.rotate90Degrees: <int>[
    2,
    3,
    4,
    5,
    6,
    7,
    0,
    1,
    10,
    11,
    12,
    13,
    14,
    15,
    8,
    9,
    18,
    19,
    20,
    21,
    22,
    23,
    16,
    17,
  ],
  TransformationType.horizontalFlip: <int>[
    0,
    7,
    6,
    5,
    4,
    3,
    2,
    1,
    8,
    15,
    14,
    13,
    12,
    11,
    10,
    9,
    16,
    23,
    22,
    21,
    20,
    19,
    18,
    17
  ],
  TransformationType.verticalFlip: <int>[
    4,
    3,
    2,
    1,
    0,
    7,
    6,
    5,
    12,
    11,
    10,
    9,
    8,
    15,
    14,
    13,
    20,
    19,
    18,
    17,
    16,
    23,
    22,
    21
  ],
  TransformationType.innerOuterFlip: <int>[
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
  ],
};


void _validateInput(String s) {
  if (s.length != 24) {
    throw ArgumentError('Input string must be exactly 24 characters long.');
  }
}


String _transformString(String s, List<int> newPosition) {
  _validateInput(s);
  final List<String> result = List<String>.filled(24, '');
  for (int i = 0; i < 24; i++) {
    result[newPosition[i]] = s[i];
  }
  return result.join();
}


String transformString(String s, TransformationType transformationType) {
  final List<int> newPosition = transformationMap[transformationType] ??
      List<int>.generate(24, (int i) => i);
  return _transformString(s, newPosition);
}

String transformFEN(String fen, TransformationType transformationType) {

  final String boardPart = fen.substring(0, 26);

  final String otherPart = fen.substring(26);


  final List<int> slashPositions = <int>[];
  for (int i = 0; i < boardPart.length; i++) {
    if (boardPart[i] == '/') {
      slashPositions.add(i);
    }
  }


  final String transformedInput = boardPart.replaceAll('/', '');


  final String transformedOutput =
      transformString(transformedInput, transformationType);


  final StringBuffer newBoardPart = StringBuffer();
  int slashIndex = 0;
  for (int i = 0; i < transformedOutput.length; i++) {

    if (slashIndex < slashPositions.length &&
        i == slashPositions[slashIndex] - slashIndex) {
      newBoardPart.write('/');
      slashIndex++;
    }
    newBoardPart.write(transformedOutput[i]);
  }


  return '$newBoardPart$otherPart';
}

void transformSquareSquareAttributeList(TransformationType transformationType) {
  final List<SquareAttribute> newSqAttrList = List<SquareAttribute>.generate(
    sqNumber,
    (int index) => SquareAttribute(placedPieceNumber: 0),
  );

  for (int i = sqBegin; i < sqEnd; i++) {
    final int newPosition =
        transformationMap[transformationType]![i - rankNumber] + rankNumber;
    newSqAttrList[newPosition] = GameController().position.sqAttrList[i];
  }

  GameController().position.sqAttrList = newSqAttrList;
}
