import 'package:dlox/src/token.dart';
import 'package:dlox/src/expr.dart';

abstract class Stmt {
  R? accept<R>(Visitor<R> visitor);
}

abstract class Visitor<R> {
  R? visitBlockStmt(Block stmt);
  R? visitClassStmt(Class stmt);
  R? visitExpressionStmt(Expression stmt);
  R? visitFunctStmt(Funct stmt);
  R? visitIfStmt(If stmt);
  R? visitReturnStmt(Return stmt);
  R? visitPrintStmt(Print stmt);
  R? visitVarStmt(Var stmt);
  R? visitWhileStmt(While stmt);
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

class Class extends Stmt {
  Class({
    required this.name,
    required this.superclass,
    required this.methods,
  });

  final Token name;
  final Variable? superclass;
  final List<Funct> methods;

  @override
  R? accept<R>(Visitor<R> visitor) {
    return visitor.visitClassStmt(this);
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

class Funct extends Stmt {
  Funct({
    required this.name,
    required this.params,
    required this.body,
  });

  final Token name;
  final List<Token> params;
  final List<Stmt> body;

  @override
  R? accept<R>(Visitor<R> visitor) {
    return visitor.visitFunctStmt(this);
  }
}

class If extends Stmt {
  If({
    required this.condition,
    required this.thenBranch,
    required this.elseBranch,
  });

  final Expr condition;
  final Stmt thenBranch;
  final Stmt? elseBranch;

  @override
  R? accept<R>(Visitor<R> visitor) {
    return visitor.visitIfStmt(this);
  }
}

class Return extends Stmt {
  Return({
    required this.keyword,
    required this.value,
  });

  final Token keyword;
  final Expr? value;

  @override
  R? accept<R>(Visitor<R> visitor) {
    return visitor.visitReturnStmt(this);
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

class While extends Stmt {
  While({
    required this.condition,
    required this.body,
  });

  final Expr condition;
  final Stmt body;

  @override
  R? accept<R>(Visitor<R> visitor) {
    return visitor.visitWhileStmt(this);
  }
}
