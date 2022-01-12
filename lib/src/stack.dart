class Stack<R> {
  final List<R> _data = [];

  void push(R value) {
    _data.add(value);
  }

  void pop() {
    _data.removeLast();
  }

  R peek() {
    return _data.last;
  }

  R get(int index) {
    return _data[index];
  }

  bool get isEmpty => _data.isEmpty;

  bool get isNotEmpty => _data.isNotEmpty;

  int get length => _data.length;
}
