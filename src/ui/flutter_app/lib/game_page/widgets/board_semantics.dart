




part of 'game_page.dart';




class _BoardSemantics extends StatefulWidget {
  const _BoardSemantics();

  @override
  State<_BoardSemantics> createState() => _BoardSemanticsState();
}

class _BoardSemanticsState extends State<_BoardSemantics> {
  @override
  void initState() {
    super.initState();
    GameController().boardSemanticsNotifier.addListener(updateBoardSemantics);
  }

  void updateBoardSemantics() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<String> squareDesc = _buildSquareDescription(context);

    return GridView(
      key: const Key('board_grid_view'),
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      children: List<Widget>.generate(
        7 * 7,
        (int index) => Center(
          child: Semantics(
            key: Key('board_square_$index'),

            label: squareDesc[index],
          ),
        ),
      ),
    );
  }


  List<String> _buildSquareDescription(BuildContext context) {
    final List<String> coordinates = <String>[];
    final List<String> pieceDesc = <String>[];
    final List<String> squareDesc = <String>[];

    const List<int> map = <int>[

      1,
      8,
      15,
      22,
      29,
      36,
      43,

      2,
      9,
      16,
      23,
      30,
      37,
      44,

      3,
      10,
      17,
      24,
      31,
      38,
      45,

      4,
      11,
      18,
      25,
      32,
      39,
      46,

      5,
      12,
      19,
      26,
      33,
      40,
      47,

      6,
      13,
      20,
      27,
      34,
      41,
      48,

      7,
      14,
      21,
      28,
      35,
      42,
      49
    ];

    const List<int> checkPoints = <int>[

      1,
      0,
      0,
      1,
      0,
      0,
      1,

      0,
      1,
      0,
      1,
      0,
      1,
      0,

      0,
      0,
      1,
      1,
      1,
      0,
      0,

      1,
      1,
      1,
      0,
      1,
      1,
      1,

      0,
      0,
      1,
      1,
      1,
      0,
      0,

      0,
      1,
      0,
      1,
      0,
      1,
      0,

      1,
      0,
      0,
      1,
      0,
      0,
      1
    ];

    final bool ltr = Directionality.of(context) == TextDirection.ltr;

    for (final String file
        in ltr ? horizontalNotations : horizontalNotations.reversed) {
      for (final String rank in verticalNotations) {
        coordinates.add("${file.toUpperCase()}$rank");
      }
    }

    for (int i = 0; i < 7 * 7; i++) {
      if (checkPoints[i] == 0) {
        pieceDesc.add(S.of(context).noPoint);
      } else {
        pieceDesc.add(
          GameController().position.pieceOnGrid(i).pieceName(context),
        );
      }
    }

    squareDesc.clear();

    for (int i = 0; i < 7 * 7; i++) {
      final String desc = pieceDesc[map[i] - 1];
      if (desc == S.of(context).emptyPoint) {
        squareDesc.add("${coordinates[i]}: $desc");
      } else {
        squareDesc.add("$desc: ${coordinates[i]}");
      }
    }

    return squareDesc;
  }

  @override
  void dispose() {
    GameController()
        .boardSemanticsNotifier
        .removeListener(updateBoardSemantics);
    super.dispose();
  }
}
