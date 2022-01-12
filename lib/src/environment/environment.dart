import 'dart:convert';

import 'package:dlox/src/error/runtime_error.dart';
import 'package:dlox/src/token/token.dart';

class Environment {
  Environment([this.enclosing]);
  final Environment? enclosing;
  final Map<String, Object?> values = {};

  Object? get(Token name) {
    if (values.containsKey(name.lexeme)) {
      return values[name.lexeme];
    }

    if (enclosing != null) {
      return enclosing!.get(name);
    }
    throw RuntimeError(name, "Undefined variable '${name.lexeme}'.");
  }

  void assign(Token name, Object? value) {
    if (values.containsKey(name.lexeme)) {
      values[name.lexeme] = value;
      return;
    }

    if (enclosing != null) {
      enclosing!.assign(name, value);
      return;
    }
    throw RuntimeError(name, "Undefined variable '${name.lexeme}.");
  }

  void define(String name, Object? value) {
    values[name] = value;
  }

  Environment? ancestor(int distance) {
    Environment? environment = this;
    for (int i = 0; i < distance; i++) {
      environment = environment?.enclosing;
    }

    return environment;
  }

  Object? getAt(int distance, String name) {
    return ancestor(distance)?.values[name];
  }

  void assignAt(int distance, Token name, Object? value) {
    ancestor(distance)?.values[name.lexeme] = value;
  }
}
