import 'package:dlox/dlox.dart';
import 'package:dlox/src/environment/environment.dart';
import 'package:dlox/src/error/runtime_error.dart';
import 'package:dlox/src/expr/expr.dart' as expr;
import 'package:dlox/src/stmt/stmt.dart' as stmt;
import 'package:dlox/src/stmt/stmt.dart';
import 'package:dlox/src/token/token.dart';
import 'package:dlox/src/token/token_type.dart';

class Interpreter implements expr.Visitor<Object>, stmt.Visitor<void> {
  Environment _environment = Environment();
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
    return _environment.get(expr.name);
  }

  @override
  Object? visitAssignExpr(expr.Assign expr) {
    Object? value = evaluate(expr.value);
    _environment.assign(expr.name, value);
    return value;
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
