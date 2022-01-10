import 'dart:io';

void main(List<String> arguments) {
  if (arguments.length != 1) {
    print('Usage: generate_ast <output directory>');
    return;
  }
  String outputDir = arguments[0];
  GenerateAst.defineAst(outputDir, "Expr", [
    "Binary   : Expr left, Token operator, Expr right",
    "Grouping : Expr expression",
    "Literal  : Object? value",
    "Unary    : Token operator, Expr right"
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

    // @override
    // R accept<R>(Visitor<R> visitor) {
    //   return visitor.visitBinaryExpr(this);
    // }

    sink.writeln();
    sink.writeln('  @override');
    sink.writeln('  R? accept<R>(Visitor<R> visitor) {');
    sink.writeln('    return visitor.visit$className$baseName(this);');
    sink.writeln('  }');

    sink.writeln("}");
  }
}
