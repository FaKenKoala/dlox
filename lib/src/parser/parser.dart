import 'package:dlox/src/expr/expr.dart';
import 'package:dlox/src/parser/parse_error.dart';
import 'package:dlox/src/token/token.dart';
import 'package:dlox/src/token/token_type.dart';

import '../../dlox.dart';

class Parser {
  Parser(this._tokens);
  final List<Token> _tokens;
  int _current = 0;

  Expr? parse() {
    try {
      return expression();
    } on ParseError catch (error) {
      return null;
    }
  }

  Expr expression() {
    return equality();
  }

  Expr equality() {
    Expr expr = comparison();

    while (match([TokenType.bangEqual, TokenType.equalEqual])) {
      Token operator = previous();
      Expr right = comparison();
      expr = Binary(left: expr, operator: operator, right: right);
    }

    return expr;
  }

  Expr comparison() {
    Expr expr = term();

    while (match([
      TokenType.greater,
      TokenType.greaterEqual,
      TokenType.less,
      TokenType.lessEqual
    ])) {
      Token operator = previous();
      Expr right = term();
      expr = Binary(left: expr, operator: operator, right: right);
    }
    return expr;
  }

  Expr term() {
    Expr expr = factor();

    while (match([TokenType.minus, TokenType.plus])) {
      Token operator = previous();
      Expr right = factor();
      expr = Binary(left: expr, operator: operator, right: right);
    }

    return expr;
  }

  Expr factor() {
    Expr expr = unary();

    while (match([TokenType.slash, TokenType.star])) {
      Token operator = previous();
      Expr right = unary();
      expr = Binary(left: expr, operator: operator, right: right);
    }

    return expr;
  }

  Expr unary() {
    if (match([TokenType.bang, TokenType.minus])) {
      Token operator = previous();
      Expr right = unary();
      return Unary(operator: operator, right: right);
    }

    return primary();
  }

  Expr primary() {
    if (match([TokenType.$false])) {
      return Literal(value: false);
    }

    if (match([TokenType.$true])) {
      return Literal(value: true);
    }

    if (match([TokenType.nil])) {
      return Literal(value: null);
    }

    if (match([TokenType.number, TokenType.string])) {
      return Literal(value: previous().literal);
    }

    if (match([TokenType.leftParen])) {
      Expr expr = expression();
      consume(TokenType.rightParen, "Expect ')' after expression.");
      return Grouping(expression: expr);
    }

    throw error(peek(), 'Excect expression.');
  }

  bool match(List<TokenType> types) {
    for (TokenType type in types) {
      if (check(type)) {
        advance();
        return true;
      }
    }
    return false;
  }

  Token consume(TokenType type, String message) {
    if (check(type)) {
      return advance();
    }
    throw error(peek(), message);
  }

  bool check(TokenType type) {
    if (isAtEnd()) {
      return false;
    }
    return peek().type == type;
  }

  Token advance() {
    if (!isAtEnd()) {
      _current++;
    }
    return previous();
  }

  bool isAtEnd() {
    return peek().type == TokenType.eof;
  }

  Token peek() {
    return _tokens[_current];
  }

  Token previous() {
    return _tokens[_current - 1];
  }

  ParseError error(Token token, String message) {
    Lox.errorToken(token, message);
    return ParseError();
  }

  void synchronize() {
    advance();

    while (!isAtEnd()) {
      if (previous().type == TokenType.semicolon) {
        return;
      }

      switch (peek().type) {
        case TokenType.$class:
        case TokenType.fun:
        case TokenType.$var:
        case TokenType.$for:
        case TokenType.$if:
        case TokenType.$while:
        case TokenType.print:
        case TokenType.$return:
          return;

        default:
          break;
      }
      advance();
    }
  }
}
