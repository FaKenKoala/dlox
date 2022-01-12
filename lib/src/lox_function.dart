import 'package:dlox/src/lox_callable.dart';
import 'package:dlox/src/environment.dart';
import 'package:dlox/src/return_error.dart';
import 'package:dlox/src/lox_instance.dart';
import 'package:dlox/src/interpreter.dart';
import 'package:dlox/src/stmt.dart';

class LoxFunction implements LoxCallable {
  LoxFunction(this._declaration, this._closure, this.isInitializer);
  final Funct _declaration;
  final Environment _closure;

  final bool isInitializer;

  LoxFunction bind(LoxInstance instance) {
    Environment environment = Environment(_closure);
    environment.define("this", instance);
    return LoxFunction(_declaration, environment, isInitializer);
  }

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
    } on ReturnError catch (returnValue) {
      if (isInitializer) {
        return _closure.getAt(0, "this");
      }
      return returnValue.value;
    }

    if (isInitializer) {
      return _closure.getAt(0, "this");
    }
    return null;
  }

  @override
  String toString() {
    return "<fn ${_declaration.name.lexeme}>";
  }
}
