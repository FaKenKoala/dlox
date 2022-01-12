import 'package:dlox/src/callable/lox_callable.dart';
import 'package:dlox/src/function/lox_function.dart';
import 'package:dlox/src/instance/lox_instance.dart';
import 'package:dlox/src/interpreter/interpreter.dart';

class LoxClass implements LoxCallable {
  LoxClass(this.name, this.methods);
  final String name;
  final Map<String, LoxFunction> methods;

  LoxFunction? findMethod(String name) {
    return methods[name];
  }

  @override
  String toString() {
    return name;
  }

  @override
  int arity() {
    return 0;
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    LoxInstance instance = LoxInstance(this);
    return instance;
  }
}
