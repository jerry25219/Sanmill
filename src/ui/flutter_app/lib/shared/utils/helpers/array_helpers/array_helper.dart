







extension ListExtension<E> on List<E> {




  E? get lastF {
    if (isNotEmpty) {
      return this[length - 1];
    }
    return null;
  }
}
