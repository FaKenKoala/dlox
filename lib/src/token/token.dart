import 'package:dlox/src/token/token_type.dart';

class Token {
  Token(
      {required this.type,
      required this.lexeme,
      required this.line,
      required this.literal});

  final TokenType type;
  final String lexeme;
  final Object? literal;
  final int line;

  @override
  String toString() {
    return '$type $lexeme $literal';
  }
}
