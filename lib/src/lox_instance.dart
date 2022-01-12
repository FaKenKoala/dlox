import 'package:dlox/src/lox_class.dart';
import 'package:dlox/src/runtime_error.dart';
import 'package:dlox/src/lox_function.dart';
import 'package:dlox/src/token.dart';

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

    LoxFunction? method = kclass.findMethod(name.lexeme);
    if (method != null) {
      return method.bind(this);
    }

    throw RuntimeError(name, "Undefined property '${name.lexeme}'.");
  }

  void set(Token token, Object? value) {
    fields[token.lexeme] = value;
  }
}
