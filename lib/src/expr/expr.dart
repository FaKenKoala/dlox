import 'package:dlox/src/token/token.dart';

abstract class Expr {
  R accept<R>(Visitor<R> visitor);
}

abstract class Visitor<R> {
  R visitBinaryExpr(Binary expr);
  R visitGroupingExpr(Grouping expr);
  R visitLiteralExpr(Literal expr);
  R visitUnaryExpr(Unary expr);
}

class Binary extends Expr {
  Binary({
    required this.left,
    required this.operator,
    required this.right,
  });

  final Expr left;
  final Token operator;
  final Expr right;

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitBinaryExpr(this);
  }
}

class Grouping extends Expr {
  Grouping({
    required this.expression,
  });

  final Expr expression;

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitGroupingExpr(this);
  }
}

class Literal extends Expr {
  Literal({
    required this.value,
  });

  final Object? value;

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitLiteralExpr(this);
  }
}

class Unary extends Expr {
  Unary({
    required this.operator,
    required this.right,
  });

  final Token operator;
  final Expr right;

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitUnaryExpr(this);
  }
}
