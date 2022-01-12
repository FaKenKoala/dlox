import 'package:dlox/src/class/lox_class.dart';
import 'package:dlox/src/error/runtime_error.dart';
import 'package:dlox/src/token/token.dart';

class LoxInstance {
  LoxInstance(this.kclass);
  final LoxClass kclass;
  final Map<String, Object?> fields = {};

  @override
  String toString() {
    return '${kclass.name} instance';
  }

  Object? get(Token name) {
    if (fields.containsKey(name.lexeme)) {
      return fields[name.lexeme];
    }

    throw RuntimeError(name, "Undefined property '${name.lexeme}'.");
  }

  void set(Token token, Object? value) {
    fields[token.lexeme] = value;
  }
}
