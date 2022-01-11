import 'package:dlox/src/token/token.dart';
import 'package:dlox/src/expr/expr.dart';

abstract class Stmt {
  R? accept<R>(Visitor<R> visitor);
}

abstract class Visitor<R> {
  R? visitBlockStmt(Block stmt);
  R? visitExpressionStmt(Expression stmt);
  R? visitPrintStmt(Print stmt);
  R? visitVarStmt(Var stmt);
}

class Block extends Stmt {
  Block({
    required this.statements,
  });

  final List<Stmt> statements;

  @override
  R? accept<R>(Visitor<R> visitor) {
    return visitor.visitBlockStmt(this);
  }
}

class Expression extends Stmt {
  Expression({
    required this.expression,
  });

  final Expr expression;

  @override
  R? accept<R>(Visitor<R> visitor) {
    return visitor.visitExpressionStmt(this);
  }
}

class Print extends Stmt {
  Print({
    required this.expression,
  });

  final Expr expression;

  @override
  R? accept<R>(Visitor<R> visitor) {
    return visitor.visitPrintStmt(this);
  }
}

class Var extends Stmt {
  Var({
    required this.name,
    required this.initializer,
  });

  final Token name;
  final Expr? initializer;

  @override
  R? accept<R>(Visitor<R> visitor) {
    return visitor.visitVarStmt(this);
  }
}
