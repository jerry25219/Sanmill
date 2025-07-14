




import '../../../shared/utils/helpers/string_helpers/string_helper.dart';

bool isPureFen(String text) {
  if (text.length >=
          "**************** w p p 9 0 9 0 0 0 0 0 0 0 0 0".length &&
      (text.contains("/") &&
          text[8] == "/" &&
          text[17] == "/" &&
          text[26] == " ")) {
    return true;
  }

  return false;
}

bool hasTagPairs(String text) {
  if (text.length >= 15 &&
      (text.contains("[Event") ||
          text.contains("[White") ||
          text.contains("[FEN"))) {
    return true;
  }

  return false;
}

bool isFenMoveList(String text) {
  if (text.length >= 15 && (text.contains("[FEN"))) {
    return true;
  }

  return false;
}

bool isPlayOkMoveList(String text) {



  if (text.contains('[Site "PlayOK"]')) {
    return true;
  }

  text = removeBracketedContent(text);
  final String noTag = removeTagPairs(text);


  if (!noTag.contains("1.")) {
    return false;
  }


  if (noTag.isEmpty || RegExp(r'[a-gA-G]').hasMatch(noTag)) {
    return false;
  }

  return true;
}

bool isGoldTokenMoveList(String text) {


  text = removeBracketedContent(text);

  return text.contains("GoldToken") ||
      text.contains("Place to") ||
      text.contains(", take ") ||
      text.contains(" -> ");
}

String getTagPairs(String pgn) {

  final int firstBracket = pgn.indexOf('[');


  final int lastBracket = pgn.lastIndexOf(']');


  if (firstBracket != -1 && lastBracket != -1 && lastBracket > firstBracket) {

    return pgn.substring(firstBracket, lastBracket + 1);
  }


  return '';
}

String removeTagPairs(String pgn) {

  if (!pgn.startsWith("[")) {
    return pgn;
  }


  final int lastBracketPos = pgn.lastIndexOf("]");
  if (lastBracketPos == -1) {
    return pgn;
  }


  return pgn.substring(lastBracketPos + 1).trimLeft();
}
