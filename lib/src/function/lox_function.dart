import 'package:dlox/src/callable/lox_callable.dart';
import 'package:dlox/src/environment/environment.dart';
import 'package:dlox/src/interpreter/interpreter.dart';
import 'package:dlox/src/stmt/stmt.dart';

class LoxFunction implements LoxCallable {
  LoxFunction(this._declaration);
  final Funct _declaration;

  @override
  int arity() {
    return _declaration.params.length;
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    Environment environment = Environment(interpreter.globals);
    for (int i = 0; i < _declaration.params.length; i++) {
      environment.define(_declaration.params[i].lexeme, arguments[i]);
    }

    interpreter.executeBlock(_declaration.body, environment);
    return null;
  }

  @override
  String toString() {
    return "<fn ${_declaration.name.lexeme}>";
  }
}
