import 'dart:io';

import 'src/scanner/scanner.dart';
import 'src/token/token.dart';

class Lox {
  static bool hadError = false;

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

    for (Token token in tokens) {
      print(token);
    }
  }

  static void error(int line, String message) {
    _report(line, '', message);
  }

  static void _report(int line, String where, String message) {
    print('[line $line ] Error$where: $message');
    hadError = true;
  }
}
