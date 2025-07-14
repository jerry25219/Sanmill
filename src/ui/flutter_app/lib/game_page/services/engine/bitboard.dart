




List<int> squareBB = List<int>.filled(32, 0);

int squareBb(int s) {
  if (!(8 <= s && s < 32)) {
    return 0;
  }
  return squareBB[s];
}

void initBitboards() {
  for (int s = 8; s < 32; ++s) {
    squareBB[s] = 1 << s;
  }
}
