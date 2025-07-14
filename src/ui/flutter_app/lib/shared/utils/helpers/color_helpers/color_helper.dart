




import 'dart:ui';



Color pickColorWithMaxDifference(
    Color candidate1, Color candidate2, Color reference) {
  double colorDiff(Color c1, Color c2) {
    final double dr = c1.r - c2.r;
    final double dg = c1.g - c2.g;
    final double db = c1.b - c2.b;
    return dr * dr + dg * dg + db * db;
  }

  return (colorDiff(candidate1, reference) > colorDiff(candidate2, reference))
      ? candidate1
      : candidate2;
}
