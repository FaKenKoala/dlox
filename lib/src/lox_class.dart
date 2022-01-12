import 'package:dlox/src/lox_callable.dart';
import 'package:dlox/src/lox_function.dart';
import 'package:dlox/src/lox_instance.dart';
import 'package:dlox/src/interpreter.dart';

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
    LoxFunction? initializer = findMethod("init");
    if (initializer == null) {
      return 0;
    }
    return initializer.arity();
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    LoxInstance instance = LoxInstance(this);
    LoxFunction? initializer = findMethod("init");
    if (initializer != null) {
      initializer.bind(instance).call(interpreter, arguments);
    }
    return instance;
  }
}
