import 'dart:io';

import 'package:dlox/src/ast_printer/ast_printer.dart';
import 'package:dlox/src/error/runtime_error.dart';
import 'package:dlox/src/expr/expr.dart';
import 'package:dlox/src/interpreter/interpreter.dart';
import 'package:dlox/src/parser/parser.dart';
import 'package:dlox/src/token/token_type.dart';

import 'src/scanner/scanner.dart';
import 'src/token/token.dart';

class Lox {
  static final Interpreter interpreter = Interpreter();
  static bool hadError = false;
  static bool hadRuntimeError = false;

  static void run(List<String> arguments) {
    if (arguments.length > 1) {
      print('Usage: dlox [script]');
    } else if (arguments.length == 1) {
      _runFile(arguments[0]);
    } else {
      _runPrompt();
    }
  }

  static void _runFile(String path) {
    String bytes = File(path).readAsStringSync();
    _run(bytes);

    if (hadError) {
      exit(65);
    }
    if (hadRuntimeError) {
      exit(70);
    }
  }

  static void _runPrompt() {
    for (;;) {
      stdout.write('> ');
      String? line = stdin.readLineSync();
      if (line == null) {
        break;
      }
      _run(line);
      hadError = false;
    }
  }

  static void _run(String source) {
    Scanner scanner = Scanner(source);
    List<Token> tokens = scanner.scanTokens();
    Parser parser = Parser(tokens);
    Expr? expression = parser.parse();

    if (hadError || expression == null) {
      return;
    }
    interpreter.interpret(expression);
  }

  static void error(int line, String message) {
    _report(line, '', message);
  }

  static void _report(int line, String where, String message) {
    print('[line $line ] Error$where: $message');
    hadError = true;
  }

  static void errorToken(Token token, String message) {
    if (token.type == TokenType.eof) {
      _report(token.line, " at end", message);
    } else {
      _report(token.line, " at '${token.lexeme}'", message);
    }
  }

  static void runtimeError(RuntimeError error) {
    print("${error.message}\n[line ${error.token.line}]}");
    hadRuntimeError = true;
  }
}
