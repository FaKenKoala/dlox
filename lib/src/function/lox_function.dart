import 'package:dlox/src/callable/lox_callable.dart';
import 'package:dlox/src/environment/environment.dart';
import 'package:dlox/src/error/return_error.dart';
import 'package:dlox/src/interpreter/interpreter.dart';
import 'package:dlox/src/stmt/stmt.dart';

class LoxFunction implements LoxCallable {
  LoxFunction(this._declaration, this._closure);
  final Funct _declaration;
  final Environment _closure;

  @override
  int arity() {
    return _declaration.params.length;
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    Environment environment = Environment(_closure);
    for (int i = 0; i < _declaration.params.length; i++) {
      environment.define(_declaration.params[i].lexeme, arguments[i]);
    }
    try {
      interpreter.executeBlock(_declaration.body, environment);
    } on ReturnError catch (error) {
      return error.value;
    }
    return null;
  }

  @override
  String toString() {
    return "<fn ${_declaration.name.lexeme}>";
  }
}
