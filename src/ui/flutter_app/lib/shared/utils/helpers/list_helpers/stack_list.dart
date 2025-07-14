




import 'dart:collection';
import 'dart:core';

import '../../../services/logger.dart';

class StackList<T> {

  StackList() {
    _maxStackSize = _noLimit;
  }





  StackList.sized(int maxStackSize) {
    if (maxStackSize < 2) {
      throw Exception('Error: stack size must be 2 entries or more ');
    } else {
      _maxStackSize = maxStackSize;
    }
  }

  final ListQueue<T> _list = ListQueue<T>();

  final int _noLimit = -1;


  int _maxStackSize = 0;


  List<T> toList() => _list.toList();


  bool get isEmpty => _list.isEmpty;


  bool get isNotEmpty => _list.isNotEmpty;


  void push(T element) {
    if (_maxStackSize == _noLimit || _list.length < _maxStackSize) {
      _list.addLast(element);
    } else {
      throw Exception(
          'Error: Cannot add element. Stack already at maximum size of: $_maxStackSize elements');
    }
  }


  T pop() {
    if (isEmpty) {
      throw Exception(
        "Can't use pop with empty stack\n consider "
        'checking for size or isEmpty before calling pop',
      );
    }
    final T poppedElement = _list.last;
    _list.removeLast();
    return poppedElement;
  }


  T top() {
    if (isEmpty) {
      throw Exception(
        "Can't use top with empty stack\n consider "
        'checking for size or isEmpty before calling top',
      );
    }
    return _list.last;
  }


  int size() {
    return _list.length;
  }


  int get length => size();


  bool contains(T searchElement) {
    return _list.contains(searchElement);
  }


  void clear() {
    while (isNotEmpty) {
      _list.removeLast();
    }
  }


  void print() {
    List<T>.from(_list).reversed.toList().forEach((T element) {
      logger.t(element.toString());
    });
  }
}
