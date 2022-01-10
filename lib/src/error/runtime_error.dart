import 'package:dlox/src/token/token.dart';

class RuntimeError implements Exception {
  RuntimeError(this.token, this.message);
  final Token token;
  final dynamic message;
}
