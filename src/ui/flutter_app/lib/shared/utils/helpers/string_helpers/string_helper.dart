




String removeBracketedContent(String input) {

  final RegExp parentheses = RegExp(r'\([^()]*\)');
  final RegExp squareBrackets = RegExp(r'\[[^\[\]]*\]');
  final RegExp curlyBraces = RegExp(r'\{[^{}]*\}');

  String result = input;


  result = result.replaceAll(parentheses, '');


  result = result.replaceAll(squareBrackets, '');


  result = result.replaceAll(curlyBraces, '');

  return result;
}


String transformOutside(String text, Map<String, String> replacements) {
  String result = text.toLowerCase();
  replacements.forEach((String pattern, String replacement) {
    result = result.replaceAll(pattern, replacement);
  });
  return result;
}




String processOutsideBrackets(String input, Map<String, String> replacements) {

  final List<String> bracketStack = <String>[];


  final StringBuffer finalOutput = StringBuffer();
  final StringBuffer outsideBuffer = StringBuffer();
  final StringBuffer insideBuffer = StringBuffer();


  void flushOutsideBuffer() {
    if (outsideBuffer.isEmpty) {
      return;
    }

    final String transformed =
        transformOutside(outsideBuffer.toString(), replacements);
    finalOutput.write(transformed);
    outsideBuffer.clear();
  }


  void flushInsideBuffer() {
    if (insideBuffer.isEmpty) {
      return;
    }
    finalOutput.write(insideBuffer.toString());
    insideBuffer.clear();
  }


  final Map<String, String> matchingBrackets = <String, String>{
    ']': '[',
    '}': '{',
    ')': '(',
  };

  for (int i = 0; i < input.length; i++) {
    final String c = input[i];


    if (c == '[' || c == '{' || c == '(') {

      if (bracketStack.isEmpty) {
        flushOutsideBuffer();
      }


      bracketStack.add(c);

      insideBuffer.write(c);
    }

    else if (c == ']' || c == '}' || c == ')') {
      if (bracketStack.isNotEmpty && bracketStack.last == matchingBrackets[c]) {

        insideBuffer.write(c);
        bracketStack.removeLast();


        if (bracketStack.isEmpty) {
          flushInsideBuffer();
        }
      } else {


        if (bracketStack.isEmpty) {
          outsideBuffer.write(c);
        } else {
          insideBuffer.write(c);
        }
      }
    } else {

      if (bracketStack.isEmpty) {

        outsideBuffer.write(c);
      } else {

        insideBuffer.write(c);
      }
    }
  }


  if (outsideBuffer.isNotEmpty) {
    flushOutsideBuffer();
  }



  if (insideBuffer.isNotEmpty) {
    flushInsideBuffer();
  }

  return finalOutput.toString();
}
