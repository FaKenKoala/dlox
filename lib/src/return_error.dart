class ReturnError implements Exception {
  ReturnError(this.value);
  final Object? value;
}
