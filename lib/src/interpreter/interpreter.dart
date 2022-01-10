import 'package:dlox/dlox.dart';
import 'package:dlox/src/error/runtime_error.dart';
import 'package:dlox/src/expr/expr.dart';
import 'package:dlox/src/token/token.dart';
import 'package:dlox/src/token/token_type.dart';

class Interpreter implements Visitor<Object> {
  @override
  Object? visitBinaryExpr(Binary expr) {
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
  Object? visitGroupingExpr(Grouping expr) {
    return evaluate(expr.expression);
  }

  @override
  Object? visitLiteralExpr(Literal expr) {
    return expr.value;
  }

  @override
  Object? visitUnaryExpr(Unary expr) {
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

  Object? evaluate(Expr expr) {
    return expr.accept(this);
  }

  void interpret(Expr expression) {
    try {
      Object? value = evaluate(expression);
      print(stringify(value));
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
