






part of '../mill.dart';


















class _Mills {
  const _Mills._();

  static List<List<int>> get adjacentSquaresInit {
    return DB().ruleSettings.hasDiagonalLines
        ? _adjacentSquaresDiagonal
        : _adjacentSquares;
  }

  static List<List<List<int>>> get millTableInit {
    return DB().ruleSettings.hasDiagonalLines ? _millTableDiagonal : _millTable;
  }


  static const List<List<int>> _adjacentSquares = [
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [16, 9, 15, 0],
     [10, 8, 0, 0],
     [18, 11, 9, 0],
     [12, 10, 0, 0],
     [20, 13, 11, 0],
     [14, 12, 0, 0],
     [22, 15, 13, 0],
     [8, 14, 0, 0],
     [8, 24, 17, 23],
     [18, 16, 0, 0],
     [10, 26, 19, 17],
     [20, 18, 0, 0],
     [12, 28, 21, 19],
     [22, 20, 0, 0],
     [14, 30, 23, 21],
     [16, 22, 0, 0],
     [16, 25, 31, 0],
     [26, 24, 0, 0],
     [18, 27, 25, 0],
     [28, 26, 0, 0],
     [20, 29, 27, 0],
     [30, 28, 0, 0],
     [22, 31, 29, 0],
     [24, 30, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
  ];

  static const List<List<int>> _adjacentSquaresDiagonal = [
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [9, 15, 16, 0],
     [17, 8, 10, 0],
     [9, 11, 18, 0],
     [19, 10, 12, 0],
     [11, 13, 20, 0],
     [21, 12, 14, 0],
     [13, 15, 22, 0],
     [23, 8, 14, 0],
     [17, 23, 8, 24],
     [9, 25, 16, 18],
     [17, 19, 10, 26],
     [11, 27, 18, 20],
     [19, 21, 12, 28],
     [13, 29, 20, 22],
     [21, 23, 14, 30],
     [15, 31, 16, 22],
     [25, 31, 16, 0],
     [17, 24, 26, 0],
     [25, 27, 18, 0],
     [19, 26, 28, 0],
     [27, 29, 20, 0],
     [21, 28, 30, 0],
     [29, 31, 22, 0],
     [23, 24, 30, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
     [0, 0, 0, 0],
  ];

  static const List<List<List<int>>> _millTable = [
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [16, 24],
      [9, 15],
      [0, 0]
    ],
     [
      [0, 0],
      [15, 8],
      [10, 11]
    ],
     [
      [18, 26],
      [11, 9],
      [0, 0]
    ],
     [
      [0, 0],
      [9, 10],
      [12, 13]
    ],
     [
      [20, 28],
      [13, 11],
      [0, 0]
    ],
     [
      [0, 0],
      [11, 12],
      [14, 15]
    ],
     [
      [22, 30],
      [15, 13],
      [0, 0]
    ],
     [
      [0, 0],
      [13, 14],
      [8, 9]
    ],
     [
      [8, 24],
      [17, 23],
      [0, 0]
    ],
     [
      [0, 0],
      [23, 16],
      [18, 19]
    ],
     [
      [10, 26],
      [19, 17],
      [0, 0]
    ],
     [
      [0, 0],
      [17, 18],
      [20, 21]
    ],
     [
      [12, 28],
      [21, 19],
      [0, 0]
    ],
     [
      [0, 0],
      [19, 20],
      [22, 23]
    ],
     [
      [14, 30],
      [23, 21],
      [0, 0]
    ],
     [
      [0, 0],
      [21, 22],
      [16, 17]
    ],
     [
      [8, 16],
      [25, 31],
      [0, 0]
    ],
     [
      [0, 0],
      [31, 24],
      [26, 27]
    ],
     [
      [10, 18],
      [27, 25],
      [0, 0]
    ],
     [
      [0, 0],
      [25, 26],
      [28, 29]
    ],
     [
      [12, 20],
      [29, 27],
      [0, 0]
    ],
     [
      [0, 0],
      [27, 28],
      [30, 31]
    ],
     [
      [14, 22],
      [31, 29],
      [0, 0]
    ],
     [
      [0, 0],
      [29, 30],
      [24, 25]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ]
  ];

  static const List<List<List<int>>> _millTableDiagonal = [
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [16, 24],
      [9, 15],
      [0, 0]
    ],
     [
      [17, 25],
      [15, 8],
      [10, 11]
    ],
     [
      [18, 26],
      [11, 9],
      [0, 0]
    ],
     [
      [19, 27],
      [9, 10],
      [12, 13]
    ],
     [
      [20, 28],
      [13, 11],
      [0, 0]
    ],
     [
      [21, 29],
      [11, 12],
      [14, 15]
    ],
     [
      [22, 30],
      [15, 13],
      [0, 0]
    ],
     [
      [23, 31],
      [13, 14],
      [8, 9]
    ],
     [
      [8, 24],
      [17, 23],
      [0, 0]
    ],
     [
      [9, 25],
      [23, 16],
      [18, 19]
    ],
     [
      [10, 26],
      [19, 17],
      [0, 0]
    ],
     [
      [11, 27],
      [17, 18],
      [20, 21]
    ],
     [
      [12, 28],
      [21, 19],
      [0, 0]
    ],
     [
      [13, 29],
      [19, 20],
      [22, 23]
    ],
     [
      [14, 30],
      [23, 21],
      [0, 0]
    ],
     [
      [15, 31],
      [21, 22],
      [16, 17]
    ],
     [
      [8, 16],
      [25, 31],
      [0, 0]
    ],
     [
      [9, 17],
      [31, 24],
      [26, 27]
    ],
     [
      [10, 18],
      [27, 25],
      [0, 0]
    ],
     [
      [11, 19],
      [25, 26],
      [28, 29]
    ],
     [
      [12, 20],
      [29, 27],
      [0, 0]
    ],
     [
      [13, 21],
      [27, 28],
      [30, 31]
    ],
     [
      [14, 22],
      [31, 29],
      [0, 0]
    ],
     [
      [15, 23],
      [29, 30],
      [24, 25]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ],
     [
      [0, 0],
      [0, 0],
      [0, 0]
    ]
  ];

  static const List<List<int>> _horizontalAndVerticalLines = [

    [31, 24, 25],
    [23, 16, 17],
    [15, 8, 9],
    [30, 22, 14],
    [10, 18, 26],
    [13, 12, 11],
    [21, 20, 19],
    [29, 28, 27],

    [31, 30, 29],
    [23, 22, 21],
    [15, 14, 13],
    [24, 16, 8],
    [12, 20, 28],
    [9, 10, 11],
    [17, 18, 19],
    [25, 26, 27],
  ];

  static const List<List<int>> _diagonalLines = [
    [31, 23, 15],
    [9, 17, 25],
    [29, 21, 13],
    [11, 19, 27],
  ];
}
