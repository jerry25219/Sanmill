


part of '../mill.dart';



class GameRecorder {
  GameRecorder({
    this.lastPositionWithRemove,
    this.setupPosition,
  });


  String? lastPositionWithRemove;


  String? setupPosition;



  final PgnNode<ExtMove> _pgnRoot = PgnNode<ExtMove>();



  PgnNode<ExtMove>? activeNode;


  PgnNode<ExtMove> get pgnRoot => _pgnRoot;


  List<ExtMove> get mainlineMoves => _pgnRoot.mainline().toList();


  bool isAtEnd() {
    final PgnNode<ExtMove>? node = activeNode;
    if (node == null) {
      return true;
    }
    return node.children.isEmpty;
  }


  void appendMove(ExtMove move) {
    if (activeNode == null) {

      PgnNode<ExtMove> tail = _pgnRoot;
      while (tail.children.isNotEmpty) {
        tail = tail.children.first;
      }
      final PgnNode<ExtMove> newChild = PgnNode<ExtMove>(move);
      newChild.parent = tail;
      tail.children.add(newChild);
      activeNode = newChild;
    } else {

      final PgnNode<ExtMove> newChild = PgnNode<ExtMove>(move);
      newChild.parent = activeNode;
      activeNode!.children.insert(0, newChild);
      activeNode = newChild;
    }
  }


  void appendMoveIfDifferent(ExtMove newMove) {
    final ExtMove? curr = activeNode?.data;
    if (curr == null || curr.move != newMove.move) {
      appendMove(newMove);
    }
  }


  void branchNewMove(int fromIndex, ExtMove newMove) {
    PgnNode<ExtMove> node = _pgnRoot;
    for (int i = 0; i < fromIndex; i++) {
      if (node.children.isNotEmpty) {
        node = node.children.first;
      } else {
        break;
      }
    }
    final PgnNode<ExtMove> newChild = PgnNode<ExtMove>(newMove);
    newChild.parent = node;
    node.children.insert(0, newChild);
    activeNode = newChild;
  }


  void branchNewMoveFromActiveNode(ExtMove newMove) {
    final PgnNode<ExtMove> where = activeNode ?? _pgnRoot;
    final PgnNode<ExtMove> newChild = PgnNode<ExtMove>(newMove);
    newChild.parent = where;
    where.children.insert(0, newChild);
    activeNode = newChild;
  }




  String get moveHistoryText {

    String buildTagPairs() {
      if (setupPosition != null) {
        return '[FEN "$setupPosition"]\r\n[SetUp "1"]\r\n\r\n';
      }
      return '[FEN "${GameController().position.fen}"]\r\n[SetUp "1"]\r\n\r\n';
    }


    final List<PgnNode<ExtMove>> nodes = mainlineNodes;
    if (nodes.isEmpty) {
      if (GameController().isPositionSetup) {
        return buildTagPairs();
      }
      return "";
    }

    final StringBuffer sb = StringBuffer();
    int num = 1;
    int i = 0;


    void buildStandardNotation() {
      const String sep = "    ";
      if (i < nodes.length) {

        final PgnNode<ExtMove> currentNode = nodes[i];
        final List<String>? nextStartingComments =
            (i + 1 < nodes.length) ? nodes[i + 1].data!.startingComments : null;
        sb.write(sep);
        sb.write(
            _getRichMoveNotationForNode(currentNode, nextStartingComments));
        i++;
      }

      for (int round = 0; round < 3; round++) {
        if (i < nodes.length && nodes[i].data!.type == MoveType.remove) {
          final PgnNode<ExtMove> currentNode = nodes[i];
          final List<String>? nextStartingComments = (i + 1 < nodes.length)
              ? nodes[i + 1].data!.startingComments
              : null;
          sb.write(
              _getRichMoveNotationForNode(currentNode, nextStartingComments));
          i++;
        }
      }
    }


    if (GameController().isPositionSetup) {
      sb.write(buildTagPairs());
    }


    while (i < nodes.length) {
      sb.writeNumber(num++);
      buildStandardNotation();
      buildStandardNotation();
      if (i < nodes.length) {
        sb.writeln();
      }
    }

    return sb.toString();
  }



















  String get moveListPrompt {

    String nagsToString(List<int> nags) {
      final List<String> symbols = <String>[];
      for (final int nag in nags) {
        switch (nag) {
          case 1:
            symbols.add('!');
            break;
          case 2:
            symbols.add('?');
            break;
          case 3:
            symbols.add('!!');
            break;
          case 4:
            symbols.add('??');
            break;
          case 5:
            symbols.add('!?');
            break;
          case 6:
            symbols.add('?!');
            break;
          default:
            symbols.add('\$$nag');
            break;
        }
      }
      return symbols.join(' ');
    }


    String mergeComments(
        PgnNode<ExtMove> node, List<String>? nextStartComments) {
      final List<String> merged = <String>[];
      if (node.data?.comments != null && node.data!.comments!.isNotEmpty) {
        merged.addAll(node.data!.comments!);
      }
      if (nextStartComments != null && nextStartComments.isNotEmpty) {
        merged.addAll(nextStartComments);
      }
      return merged.isEmpty ? "" : merged.join(' ');
    }



    String extMoveDetails(
        PgnNode<ExtMove> node, List<String>? nextStartComments) {
      final ExtMove m = node.data!;
      final String sideStr = m.side.toString().replaceAll('PieceColor.', '');
      final String typeStr = m.type.toString().replaceAll('MoveType.', '');
      final String boardStr = (m.boardLayout != null) ? m.boardLayout! : "";


      final String mergedComments = mergeComments(node, nextStartComments);


      String nagStr = "";
      if (m.nags != null && m.nags!.isNotEmpty) {
        nagStr = nagsToString(m.nags!);
      }


      return "{ side=$sideStr, type=$typeStr, ${boardStr.isNotEmpty ? 'boardLayout="$boardStr", ' : ""}${m.moveIndex != null ? "moveIndex=${m.moveIndex}, " : ""}${m.roundIndex != null ? "roundIndex=${m.roundIndex}, " : ""}${nagStr.isNotEmpty ? 'nags="$nagStr", ' : ""}${mergedComments.isNotEmpty ? 'comments="${mergedComments.replaceAll('"', r'\"')}"' : ""} }";
    }


    final List<PgnNode<ExtMove>> nodes = mainlineNodes;
    if (nodes.isEmpty) {

      if (setupPosition != null) {
        return '[FEN "$setupPosition"]\n[SetUp "1"]\n\n(No moves yet)';
      }
      return "(No moves yet)";
    }

    final StringBuffer sb = StringBuffer();
    int moveNumber = 1;
    int i = 0;



    while (i < nodes.length) {
      sb.write("$moveNumber. ");


      final PgnNode<ExtMove> firstNode = nodes[i];

      final List<String>? firstNodeSuccessorComments =
          (i + 1 < nodes.length) ? nodes[i + 1].data?.startingComments : null;

      sb.write(firstNode.data!.notation);
      sb.write(' ');
      sb.write(extMoveDetails(firstNode, firstNodeSuccessorComments));
      i++;



      while (i < nodes.length && nodes[i].data!.type == MoveType.remove) {
        final PgnNode<ExtMove> removeNode = nodes[i];
        final List<String>? removeNodeSuccessorComments =
            (i + 1 < nodes.length) ? nodes[i + 1].data?.startingComments : null;
        sb.write(' ');
        sb.write(removeNode.data!.notation);
        sb.write(' ');
        sb.write(extMoveDetails(removeNode, removeNodeSuccessorComments));
        i++;
      }


      if (i < nodes.length) {
        sb.write(' ');
        final PgnNode<ExtMove> secondNode = nodes[i];
        final List<String>? secondNodeSuccessorComments =
            (i + 1 < nodes.length) ? nodes[i + 1].data?.startingComments : null;
        sb.write(secondNode.data!.notation);
        sb.write(' ');
        sb.write(extMoveDetails(secondNode, secondNodeSuccessorComments));
        i++;


        while (i < nodes.length && nodes[i].data!.type == MoveType.remove) {
          final PgnNode<ExtMove> removeNode = nodes[i];
          final List<String>? removeNodeSuccessorComments =
              (i + 1 < nodes.length)
                  ? nodes[i + 1].data?.startingComments
                  : null;
          sb.write(' ');
          sb.write(removeNode.data!.notation);
          sb.write(' ');
          sb.write(extMoveDetails(removeNode, removeNodeSuccessorComments));
          i++;
        }
      }

      sb.writeln();
      moveNumber++;
    }



    final String promptHeader = DB().generalSettings.llmPromptHeader.isEmpty
        ? PromptDefaults.llmPromptHeader
        : DB().generalSettings.llmPromptHeader;
    final String promptFooter = DB().generalSettings.llmPromptFooter.isEmpty
        ? PromptDefaults.llmPromptFooter
        : DB().generalSettings.llmPromptFooter;

    final String rawOutput = sb.toString().trim();

    if (GameController().isPositionSetup && setupPosition != null) {
      return '[FEN "$setupPosition"]\n[SetUp "1"]\n\n$rawOutput';
    }


    return "$promptHeader\n$rawOutput\n$promptFooter";
  }


  List<PgnNode<ExtMove>> get mainlineNodes {
    final List<PgnNode<ExtMove>> nodes = <PgnNode<ExtMove>>[];
    PgnNode<ExtMove> current = _pgnRoot;
    while (current.children.isNotEmpty) {
      current = current.children.first;
      nodes.add(current);
    }
    return nodes;
  }







  String _getRichMoveNotationForNode(PgnNode<ExtMove> node,
      [List<String>? nextStartingComments]) {

    final ExtMove move = node.data!;
    final StringBuffer sb = StringBuffer();


    sb.write(move.notation);


    if (move.nags != null && move.nags!.isNotEmpty) {
      sb.write(' ');
      sb.write(_nagsToString(move.nags!));
    }




    final List<String> mergedComments = <String>[];
    if (move.comments != null && move.comments!.isNotEmpty) {
      mergedComments.addAll(move.comments!);
    }
    if (nextStartingComments != null && nextStartingComments.isNotEmpty) {
      mergedComments.addAll(nextStartingComments);
    }


    if (mergedComments.isNotEmpty) {
      sb.write(' {');
      sb.write(mergedComments.join(' '));
      sb.write('} ');
    }

    return sb.toString();
  }


  String _nagsToString(List<int> nags) {
    final List<String> symbols = <String>[];
    for (final int nag in nags) {
      switch (nag) {
        case 1:
          symbols.add('!');
          break;
        case 2:
          symbols.add('?');
          break;
        case 3:
          symbols.add('!!');
          break;
        case 4:
          symbols.add('??');
          break;
        case 5:
          symbols.add('!?');
          break;
        case 6:
          symbols.add('?!');
          break;
        default:

          symbols.add('\$$nag');
          break;
      }
    }

    return symbols.join(' ');
  }
}
