import 'package:dlox/src/expr/expr.dart';

class AstPrinter implements Visitor<String> {
  String print(Expr expr) {
    return expr.accept(this) ?? 'empty';
  }

  @override
  String visitBinaryExpr(Binary expr) {
    return parenthesize(expr.operator.lexeme, [expr.left, expr.right]);
  }

  @override
  String visitGroupingExpr(Grouping expr) {
    return parenthesize("group", [expr.expression]);
  }

  @override
  String visitLiteralExpr(Literal expr) {
    return '${expr.value ?? 'nil'}';
  }

  @override
  String visitUnaryExpr(Unary expr) {
    return parenthesize(expr.operator.lexeme, [expr.right]);
  }

  String parenthesize(String name, [List<Expr> exprs = const []]) {
    StringBuffer buffer = StringBuffer();

    buffer.write('($name');
    for (Expr expr in exprs) {
      buffer.write(' ');
      buffer.write(expr.accept(this));
    }
    buffer.write(')');
    return buffer.toString();
  }

  @override
  String? visitVariableExpr(Variable expr) {
    // TODO: implement visitVariableExpr
    throw UnimplementedError();
  }

  @override
  String? visitAssignExpr(Assign expr) {
    // TODO: implement visitAssignExpr
    throw UnimplementedError();
  }

  @override
  String? visitLogicalExpr(Logical expr) {
    // TODO: implement visitLogicalExpr
    throw UnimplementedError();
  }

  @override
  String? visitCallExpr(Call expr) {
    // TODO: implement visitCallExpr
    throw UnimplementedError();
  }
}
