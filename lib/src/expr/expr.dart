import 'package:dlox/src/token/token.dart';

abstract class Expr {
  R? accept<R>(Visitor<R> visitor);
}

abstract class Visitor<R> {
  R? visitAssignExpr(Assign expr);
  R? visitBinaryExpr(Binary expr);
  R? visitCallExpr(Call expr);
  R? visitGroupingExpr(Grouping expr);
  R? visitLiteralExpr(Literal expr);
  R? visitLogicalExpr(Logical expr);
  R? visitUnaryExpr(Unary expr);
  R? visitVariableExpr(Variable expr);
}

class Assign extends Expr {
  Assign({
    required this.name,
    required this.value,
  });

  final Token name;
  final Expr value;

  @override
  R? accept<R>(Visitor<R> visitor) {
    return visitor.visitAssignExpr(this);
  }
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
  R? accept<R>(Visitor<R> visitor) {
    return visitor.visitBinaryExpr(this);
  }
}

class Call extends Expr {
  Call({
    required this.callee,
    required this.paren,
    required this.arguments,
  });

  final Expr callee;
  final Token paren;
  final List<Expr> arguments;

  @override
  R? accept<R>(Visitor<R> visitor) {
    return visitor.visitCallExpr(this);
  }
}

class Grouping extends Expr {
  Grouping({
    required this.expression,
  });

  final Expr expression;

  @override
  R? accept<R>(Visitor<R> visitor) {
    return visitor.visitGroupingExpr(this);
  }
}

class Literal extends Expr {
  Literal({
    required this.value,
  });

  final Object? value;

  @override
  R? accept<R>(Visitor<R> visitor) {
    return visitor.visitLiteralExpr(this);
  }
}

class Logical extends Expr {
  Logical({
    required this.left,
    required this.operator,
    required this.right,
  });

  final Expr left;
  final Token operator;
  final Expr right;

  @override
  R? accept<R>(Visitor<R> visitor) {
    return visitor.visitLogicalExpr(this);
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
  R? accept<R>(Visitor<R> visitor) {
    return visitor.visitUnaryExpr(this);
  }
}

class Variable extends Expr {
  Variable({
    required this.name,
  });

  final Token name;

  @override
  R? accept<R>(Visitor<R> visitor) {
    return visitor.visitVariableExpr(this);
  }
}
