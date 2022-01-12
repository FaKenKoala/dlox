import 'dart:io';

void main(List<String> arguments) {
  String? outputDir; // = arguments[0];

  if (arguments.length == 1) {
    // print('Usage: generate_ast <output directory>');
    // return;
    outputDir = arguments[0];
  }
  GenerateAst.defineAst(outputDir ?? 'lib/src/expr/', "Expr", [
    "Assign   : Token name, Expr value",
    "Binary   : Expr left, Token operator, Expr right",
    "Call     : Expr callee, Token paren, List<Expr> arguments",
    "Get      : Expr object, Token name",
    "Grouping : Expr expression",
    "Literal  : Object? value",
    "Logical  : Expr left, Token operator, Expr right",
    "Set      : Expr object, Token name, Expr value",
    "Unary    : Token operator, Expr right",
    "Variable : Token name"
  ]);

  GenerateAst.defineAst(outputDir ?? 'lib/src/stmt/', "Stmt", [
    "Block       : List<Stmt> statements",
    "Class       : Token name, List<Funct> methods",
    "Expression  : Expr expression",
    "Funct       : Token name, List<Token> params, List<Stmt> body",
    "If          : Expr condition, Stmt thenBranch, Stmt? elseBranch",
    "Return      : Token keyword, Expr? value",
    "Print       : Expr expression",
    "Var         : Token name, Expr? initializer",
    "While       : Expr condition, Stmt body"
  ]);
}

class GenerateAst {
  static void defineAst(
      String outputDir, String baseName, List<String> types) async {
    String path = "$outputDir/${baseName.toLowerCase()}.dart";
    File file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
    } else if (!file.parent.existsSync()) {
      file.parent.createSync();
    }
    final sink = file.openWrite();
    sink.writeln("import 'package:dlox/src/token/token.dart';");
    if (baseName == 'Stmt') {
      sink.writeln("import 'package:dlox/src/expr/expr.dart';");
    }
    sink.writeln();

    sink.writeln('abstract class $baseName {');
    sink.writeln('  R? accept<R>(Visitor<R> visitor);');
    sink.writeln('}');
    defineVisitor(sink, baseName, types);

    for (String type in types) {
      String className = type.split(':')[0].trim();
      String fields = type.split(':')[1].trim();
      defineType(sink, baseName, className, fields);
    }

    await sink.flush();
    await sink.close();
  }

  static void defineVisitor(IOSink sink, String baseName, List<String> types) {
    sink.writeln();
    sink.writeln("abstract class Visitor<R> {");

    for (String type in types) {
      String typeName = type.split(':')[0].trim();
      sink.writeln(
          "  R? visit$typeName$baseName($typeName ${baseName.toLowerCase()});");
    }
    sink.writeln("}");
  }

  static void defineType(
      IOSink sink, String baseName, String className, String filedList) {
    sink.writeln();
    sink.writeln("class $className extends $baseName {");
    List<String> fields = filedList.split(", ");

    sink.writeln("  $className({");
    for (String field in fields) {
      String name = field.split(" ")[1];
      sink.writeln("    required this.$name,");
    }
    sink.writeln("  });");
    sink.writeln();

    for (String field in fields) {
      sink.writeln("  final $field;");
    }

    sink.writeln();
    sink.writeln('  @override');
    sink.writeln('  R? accept<R>(Visitor<R> visitor) {');
    sink.writeln('    return visitor.visit$className$baseName(this);');
    sink.writeln('  }');

    sink.writeln("}");
  }
}
