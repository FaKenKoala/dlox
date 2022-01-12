import 'package:dlox/dlox.dart';
import 'package:dlox/src/expr/expr.dart' as expr;
import 'package:dlox/src/interpreter/interpreter.dart';
import 'package:dlox/src/stmt/stmt.dart' as stmt;
import 'package:dlox/src/token/token.dart';

enum _FunctionType {
  none,
  $function,
}

class Resolver implements expr.Visitor<void>, stmt.Visitor<void> {
  Resolver(this.interpreter);
  final Interpreter interpreter;
  final List<Map<String, bool>> scopes = [];
  _FunctionType _currentFunction = _FunctionType.none;

  void resolveStmtList(List<stmt.Stmt> statements) {
    for (stmt.Stmt statement in statements) {
      resolveStmt(statement);
    }
  }

  void resolveStmt(stmt.Stmt stmt) {
    stmt.accept(this);
  }

  void resolveExpr(expr.Expr expr) {
    expr.accept(this);
  }

  void beginScope() {
    scopes.insert(0, <String, bool>{});
  }

  void endScope() {
    scopes.removeAt(0);
  }

  void declare(Token name) {
    if (scopes.isEmpty) {
      return;
    }

    Map<String, bool> scope = scopes[0];

    if (scope.containsKey(name.lexeme)) {
      Lox.errorToken(name, "Already a variable with this name in this scope.");
    }

    scope[name.lexeme] = false;
  }

  void define(Token name) {
    if (scopes.isEmpty) {
      return;
    }

    scopes[0][name.lexeme] = true;
  }

  void resolveLocal(expr.Expr expr, Token name) {
    for (int i = scopes.length - 1; i >= 0; i--) {
      if (scopes[i].containsKey(name.lexeme)) {
        interpreter.resolve(expr, scopes.length - 1 - i);
        return;
      }
    }
  }

  void resolveFunction(stmt.Funct function, _FunctionType type) {
    _FunctionType enclosingFunction = _currentFunction;
    _currentFunction = type;
    beginScope();
    for (Token param in function.params) {
      declare(param);
      define(param);
    }
    resolveStmtList(function.body);
    endScope();
    _currentFunction = enclosingFunction;
  }

  @override
  void visitAssignExpr(expr.Assign expr) {
    resolveExpr(expr.value);
    resolveLocal(expr, expr.name);
  }

  @override
  void visitBinaryExpr(expr.Binary expr) {
    resolveExpr(expr.left);
    resolveExpr(expr.right);
  }

  @override
  void visitBlockStmt(stmt.Block stmt) {
    beginScope();
    resolveStmtList(stmt.statements);
    endScope();
  }

  @override
  void visitClassStmt(stmt.Class stmt) {
    declare(stmt.name);
    define(stmt.name);
  }

  @override
  void visitCallExpr(expr.Call exprP) {
    resolveExpr(exprP.callee);

    for (expr.Expr argument in exprP.arguments) {
      resolveExpr(argument);
    }
  }

  @override
  void visitGetExpr(expr.Get expr) {
    resolveExpr(expr.object);
  }

  @override
  void visitExpressionStmt(stmt.Expression stmt) {
    resolveExpr(stmt.expression);
  }

  @override
  void visitFunctStmt(stmt.Funct stmt) {
    declare(stmt.name);
    define(stmt.name);

    resolveFunction(stmt, _FunctionType.$function);
  }

  @override
  void visitGroupingExpr(expr.Grouping expr) {
    resolveExpr(expr.expression);
  }

  @override
  void visitIfStmt(stmt.If stmt) {
    resolveExpr(stmt.condition);
    resolveStmt(stmt.thenBranch);
    if (stmt.elseBranch != null) {
      resolveStmt(stmt.elseBranch!);
    }
  }

  @override
  void visitLiteralExpr(expr.Literal expr) {}

  @override
  void visitLogicalExpr(expr.Logical expr) {
    resolveExpr(expr.left);
    resolveExpr(expr.right);
  }

  @override
  void visitSetExpr(expr.Set expr) {
    resolveExpr(expr.value);
    resolveExpr(expr.object);
  }

  @override
  void visitPrintStmt(stmt.Print stmt) {
    resolveExpr(stmt.expression);
  }

  @override
  void visitReturnStmt(stmt.Return stmt) {
    if (_currentFunction == _FunctionType.none) {
      Lox.errorToken(stmt.keyword, "Can't return from top-level code.");
    }

    if (stmt.value != null) {
      resolveExpr(stmt.value!);
    }
  }

  @override
  void visitUnaryExpr(expr.Unary expr) {
    resolveExpr(expr.right);
  }

  @override
  void visitVarStmt(stmt.Var stmt) {
    declare(stmt.name);
    if (stmt.initializer != null) {
      resolveExpr(stmt.initializer!);
    }
    define(stmt.name);
  }

  @override
  void visitVariableExpr(expr.Variable expr) {
    if (scopes.isNotEmpty && scopes[0][expr.name.lexeme] == false) {
      Lox.errorToken(
          expr.name, "Can't read local variable in its own initializer");
    }

    resolveLocal(expr, expr.name);
  }

  @override
  void visitWhileStmt(stmt.While stmt) {
    resolveExpr(stmt.condition);
    resolveStmt(stmt.body);
  }
}
