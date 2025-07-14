




import 'package:collection/collection.dart';




class PointedList<E> extends DelegatingList<E> {

  PointedList() : this._(<E>[]);




  PointedList.from(List<E> elements) : this._(elements);

  PointedList._(List<E> list)
      : _list = list,
        globalIterator = PointedListIterator<E>(list),
        super(list) {
    if (list.isNotEmpty) {
      globalIterator.moveToLast();
    }
  }
  late final List<E> _list;


  late final PointedListIterator<E> globalIterator;




  void prune() {
    if (_list.isEmpty) {
      return;
    }
    if (!globalIterator.hasNext) {
      return;
    }

    if (globalIterator.index == null) {
      _list.removeRange(0, _list.length);
    } else {
      _list.removeRange(globalIterator.index! + 1, _list.length);
    }
  }

  @override
  void add(E value) {
    prune();
    _list.add(value);
    globalIterator.moveNext();
  }

  void addAndDeduplicate(E value) {
    if (globalIterator.index != -1 && current != value) {
      add(value);
    }
  }




  E? get current => globalIterator.current;




  int? get index => globalIterator.index;




  void forEachVisible(void Function(E p1) f) {
    if (index == null) {
      return;
    }

    for (int i = 0; i <= index!; i++) {
      f(_list[i]);
    }
  }


  bool get isClean =>
      (globalIterator.index == _list.length - 1) ||
      (globalIterator.index == null && _list.isEmpty);




  bool get hasPrevious => globalIterator.hasPrevious;










  PointedListIterator<E> get bidirectionalIterator =>
      PointedListIterator<E>(_list);
}


class PointedListIterator<E> {
  PointedListIterator(this._sourceList) {
    if (_sourceList.isNotEmpty) {
      _currentIndex = 0;
    }
  }
  final List<E> _sourceList;
  int? _currentIndex;

  bool moveNext() {
    if (!hasNext) {
      return false;
    }

    if (_currentIndex == null) {
      _currentIndex = 0;
    } else {
      _currentIndex = _currentIndex! + 1;
    }



    return true;
  }

  bool movePrevious() {
    if (!hasPrevious) {
      return false;
    }

    if (_currentIndex == 0) {
      _currentIndex = null;
    } else {
      _currentIndex = _currentIndex! - 1;
    }

    return true;
  }


  void moveTo(int index) {
    if (_sourceList.isNotEmpty) {
      _currentIndex = index;
    }
  }




  void moveToLast() => moveTo(lastIndex);




  void moveToFirst() => moveTo(0);




  void moveToHead() => _currentIndex = null;


  int? get index => _currentIndex;


  int get lastIndex => _sourceList.length - 1;




  bool get hasNext => _sourceList.isNotEmpty && _currentIndex != lastIndex;




  bool get hasPrevious => _sourceList.isNotEmpty && _currentIndex != null;

  E? get current {
    if (_currentIndex == null) {
      return null;
    }

    return _sourceList[_currentIndex!];
  }

  E? get prev {
    if (_currentIndex == null ||
        index == 0 ||
        _sourceList[_currentIndex! - 1] == null) {
      return null;
    }

    return _sourceList[_currentIndex! - 1];
  }

  @override

  bool operator ==(Object other) =>
      other is PointedListIterator &&
      _sourceList == other._sourceList &&
      _currentIndex == other._currentIndex;

  @override

  int get hashCode => Object.hash(_sourceList, _currentIndex);
}
