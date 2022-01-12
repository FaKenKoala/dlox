import 'package:dlox/dlox.dart';
import 'package:dlox/src/lox_callable.dart';
import 'package:dlox/src/lox_class.dart';
import 'package:dlox/src/environment.dart';
import 'package:dlox/src/return_error.dart';
import 'package:dlox/src/runtime_error.dart';
import 'package:dlox/src/expr.dart' as expr;
import 'package:dlox/src/lox_function.dart';
import 'package:dlox/src/lox_instance.dart';
import 'package:dlox/src/stmt.dart' as stmt;
import 'package:dlox/src/stmt.dart';
import 'package:dlox/src/token.dart';
import 'package:dlox/src/token_type.dart';

class _ClockLoxCallable implements LoxCallable {
  @override
  int arity() {
    return 0;
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    return DateTime.now().millisecondsSinceEpoch / 1000.0;
  }

  @override
  String toString() {
    return "<native fn>";
  }
}

class Interpreter implements expr.Visitor<Object>, stmt.Visitor<void> {
  final Environment globals = Environment();
  late Environment _environment = globals;
  final Map<expr.Expr, int> locals = {};

  Interpreter() {
    globals.define("clock", _ClockLoxCallable());
  }

  @override
  Object? visitBinaryExpr(expr.Binary expr) {
    Object? left = evaluate(expr.left);
    Object? right = evaluate(expr.right);

    switch (expr.operator.type) {
      case TokenType.greater:
        checkNumberOperands(expr.operator, left, right);
        return (left as double) > (right as double);
      case TokenType.greaterEqual:
        checkNumberOperands(expr.operator, left, right);
        return (left as double) >= (right as double);
      case TokenType.less:
        checkNumberOperands(expr.operator, left, right);
        return (left as double) < (right as double);
      case TokenType.lessEqual:
        checkNumberOperands(expr.operator, left, right);
        return (left as double) <= (right as double);
      case TokenType.bangEqual:
        return !isEqual(left, right);
      case TokenType.equalEqual:
        return isEqual(left, right);
      case TokenType.minus:
        checkNumberOperands(expr.operator, left, right);
        return (left as double) - (right as double);
      case TokenType.plus:
        checkNumberOperands(expr.operator, left, right);
        if (left is double && right is double) {
          return left + right;
        }
        if (left is String && right is String) {
          return '$left$right';
        }
        throw RuntimeError(
            expr.operator, "Operands must be two numbers or two strings.");
      case TokenType.slash:
        checkNumberOperands(expr.operator, left, right);
        return (left as double) / (right as double);
      case TokenType.star:
        checkNumberOperands(expr.operator, left, right);
        return (left as double) * (right as double);

      default:
        return null;
    }
  }

  @override
  Object? visitGroupingExpr(expr.Grouping expr) {
    return evaluate(expr.expression);
  }

  @override
  Object? visitLiteralExpr(expr.Literal expr) {
    return expr.value;
  }

  @override
  Object? visitLogicalExpr(expr.Logical expr) {
    Object? left = evaluate(expr.left);

    if (expr.operator.type == TokenType.or) {
      if (isTruthy(left)) {
        return left;
      }
    } else {
      if (!isTruthy(left)) {
        return left;
      }
    }
    return evaluate(expr.right);
  }

  @override
  Object? visitSetExpr(expr.Set expr) {
    Object? object = evaluate(expr.object);

    if (object is! LoxInstance) {
      throw RuntimeError(expr.name, "Only instances have fields");
    }

    Object? value = evaluate(expr.value);
    object.set(expr.name, value);
    return value;
  }

  @override
  Object? visitSuperExpr(expr.Super expr) {
    int? distance = locals[expr];
    LoxClass? superclass;
    LoxInstance? object;

    if (distance != null) {
      superclass = _environment.getAt(distance, "super") as LoxClass?;
      object = _environment.getAt(distance - 1, "this") as LoxInstance?;
    }

    LoxFunction? method = superclass?.findMethod(expr.method.lexeme);

    if (object == null || method == null) {
      throw RuntimeError(
          expr.method, "Undefined property '${expr.method.lexeme}'.");
    }
    return method.bind(object);
  }

  @override
  Object? visitThisExpr(expr.This expr) {
    return lookUpVariable(expr.keyword, expr);
  }

  @override
  Object? visitUnaryExpr(expr.Unary expr) {
    Object? right = evaluate(expr.right);

    switch (expr.operator.type) {
      case TokenType.bang:
        return !isTruthy(right);
      case TokenType.minus:
        checkNumberOperand(expr.operator, right);
        return -(right as double);

      default:
        return null;
    }
  }

  @override
  Object? visitVariableExpr(expr.Variable expr) {
    return lookUpVariable(expr.name, expr);
  }

  Object? lookUpVariable(Token name, expr.Expr expr) {
    int? distance = locals[expr];
    if (distance != null) {
      return _environment.getAt(distance, name.lexeme);
    } else {
      return globals.get(name);
    }
  }

  @override
  Object? visitAssignExpr(expr.Assign expr) {
    Object? value = evaluate(expr.value);
    int? distance = locals[expr];
    if (distance != null) {
      _environment.assignAt(distance, expr.name, value);
    } else {
      globals.assign(expr.name, value);
    }
    return value;
  }

  @override
  Object? visitCallExpr(expr.Call exprP) {
    Object? callee = evaluate(exprP.callee);

    List<Object?> arguments = exprP.arguments.map(evaluate).toList();

    if (callee is! LoxCallable) {
      throw RuntimeError(exprP.paren, "Can only call functions and classes.");
    }
    LoxCallable function = callee;
    if (arguments.length != function.arity()) {
      throw RuntimeError(exprP.paren,
          "Expected ${function.arity()} arguments but got ${arguments.length}.");
    }
    return function.call(this, arguments);
  }

  @override
  Object? visitGetExpr(expr.Get expr) {
    Object? object = evaluate(expr.object);
    if (object is LoxInstance) {
      return object.get(expr.name);
    }

    throw RuntimeError(expr.name, "Only instances have properties.");
  }

  @override
  void visitExpressionStmt(stmt.Expression stmt) {
    evaluate(stmt.expression);
  }

  @override
  void visitPrintStmt(stmt.Print stmt) {
    Object? value = evaluate(stmt.expression);
    print(stringify(value));
  }

  @override
  void visitVarStmt(stmt.Var stmt) {
    Object? value;
    if (stmt.initializer != null) {
      value = evaluate(stmt.initializer!);
    }

    _environment.define(stmt.name.lexeme, value);
  }

  @override
  void visitBlockStmt(stmt.Block stmt) {
    executeBlock(stmt.statements, Environment(_environment));
  }

  @override
  void visitClassStmt(stmt.Class stmtP) {
    Object? superclass;
    if (stmtP.superclass != null) {
      superclass = evaluate(stmtP.superclass!);
      if (superclass is! LoxClass) {
        throw RuntimeError(
            stmtP.superclass!.name, "Superclass must be a class.");
      }
    }

    _environment.define(stmtP.name.lexeme, null);

    if (stmtP.superclass != null) {
      _environment = Environment(_environment);
      _environment.define("super", superclass);
    }

    Map<String, LoxFunction> methods = {};
    for (stmt.Funct method in stmtP.methods) {
      LoxFunction function =
          LoxFunction(method, _environment, method.name.lexeme == 'init');
      methods[method.name.lexeme] = function;
    }

    LoxClass kclass =
        LoxClass(stmtP.name.lexeme, superclass as LoxClass?, methods);

    if (superclass != null) {
      _environment = _environment.enclosing!;
    }
    _environment.assign(stmtP.name, kclass);
  }

  @override
  void visitIfStmt(stmt.If stmt) {
    if (isTruthy(evaluate(stmt.condition))) {
      execute(stmt.thenBranch);
    } else if (stmt.elseBranch != null) {
      execute(stmt.elseBranch!);
    }
  }

  @override
  void visitWhileStmt(stmt.While stmt) {
    while (isTruthy(evaluate(stmt.condition))) {
      execute(stmt.body);
    }
  }

  @override
  void visitFunctStmt(stmt.Funct stmt) {
    LoxFunction function = LoxFunction(stmt, _environment, false);
    _environment.define(stmt.name.lexeme, function);
  }

  @override
  void visitReturnStmt(stmt.Return stmt) {
    Object? value;
    if (stmt.value != null) {
      value = evaluate(stmt.value!);
    }
    throw ReturnError(value);
  }

  checkNumberOperand(Token operator, Object? operand) {
    if (operand is double) {
      return;
    }
    throw RuntimeError(operator, 'Operand must be a number.');
  }

  checkNumberOperands(Token token, Object? left, Object? right) {
    if (left is double && right is double) {
      return;
    }
    return RuntimeError(token, 'Operands must be a number.');
  }

  bool isTruthy(Object? object) {
    if (object == null) {
      return false;
    }
    if (object is bool) {
      return object;
    }
    return true;
  }

  bool isEqual(Object? left, Object? right) {
    return left == right;
  }

  Object? evaluate(expr.Expr expr) {
    return expr.accept(this);
  }

  void execute(stmt.Stmt stmt) {
    stmt.accept(this);
  }

  void executeBlock(List<Stmt> statements, Environment environment) {
    Environment previous = _environment;
    try {
      _environment = environment;

      for (stmt.Stmt statement in statements) {
        execute(statement);
      }
    } finally {
      _environment = previous;
    }
  }

  void resolve(expr.Expr expr, int depth) {
    locals[expr] = depth;
  }

  void interpret(List<stmt.Stmt> statements) {
    try {
      for (stmt.Stmt statement in statements) {
        execute(statement);
      }
    } on RuntimeError catch (error) {
      Lox.runtimeError(error);
    }
  }

  String stringify(Object? object) {
    if (object == null) {
      return 'nil';
    }

    if (object is double) {
      String text = object.toString();
      if (text.endsWith('.0')) {
        text = text.substring(0, text.length - 2);
      }
      return text;
    }
    return object.toString();
  }
}
