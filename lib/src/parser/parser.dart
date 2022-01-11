import 'package:dlox/src/expr/expr.dart';
import 'package:dlox/src/parser/parse_error.dart';
import 'package:dlox/src/stmt/stmt.dart';
import 'package:dlox/src/token/token.dart';
import 'package:dlox/src/token/token_type.dart';

import '../../dlox.dart';

class Parser {
  Parser(this._tokens);
  final List<Token> _tokens;
  int _current = 0;

  List<Stmt> parse() {
    List<Stmt> statements = [];
    while (!isAtEnd()) {
      Stmt? result = declaration();

      /// add nonnull value to list
      if (result != null) {
        statements.add(result);
      }
    }
    return statements;
  }

  Stmt? declaration() {
    try {
      if (match([TokenType.$var])) {
        return varDeclaration();
      }

      return statement();
    } on ParseError catch (error) {
      synchronize();
      return null;
    }
  }

  Stmt statement() {
    if (match([TokenType.$if])) {
      return ifStatement();
    }

    if (match([TokenType.print])) {
      return printStatement();
    }

    if (match([TokenType.$while])) {
      return whileStatement();
    }

    if (match([TokenType.leftBrace])) {
      return Block(statements: block());
    }
    return expressionStatement();
  }

  Stmt ifStatement() {
    consume(TokenType.leftParen, "Expect '(' after 'if'.");
    Expr condition = expression();
    consume(TokenType.rightParen, "Expect ')' after if condition");

    Stmt thenBranch = statement();
    Stmt? elseBranch;
    if (match([TokenType.$else])) {
      elseBranch = statement();
    }

    return If(
        condition: condition, thenBranch: thenBranch, elseBranch: elseBranch);
  }

  Stmt printStatement() {
    Expr value = expression();
    consume(TokenType.semicolon, "Expect ';' after value.");
    return Print(expression: value);
  }

  Stmt whileStatement() {
    consume(TokenType.leftParen, "Expect '(' after 'while'.");
    Expr condition = expression();
    consume(TokenType.rightParen, "Expect ')' after condition.");
    Stmt body = statement();

    return While(condition: condition, body: body);
  }

  Stmt varDeclaration() {
    Token name = consume(TokenType.identifier, 'Expect variable name.');

    Expr? initializer;
    if (match([TokenType.equal])) {
      initializer = expression();
    }

    consume(TokenType.semicolon, "Expect ';' after variable declaration.");
    return Var(name: name, initializer: initializer);
  }

  Stmt expressionStatement() {
    Expr expr = expression();
    consume(TokenType.semicolon, "Expect ';' after expression.");
    return Expression(expression: expr);
  }

  List<Stmt> block() {
    List<Stmt> statements = [];

    while (!check(TokenType.rightBrace) && !isAtEnd()) {
      final result = declaration();
      if (result != null) {
        statements.add(result);
      }
    }

    consume(TokenType.rightBrace, "Expect '}' after block.");
    return statements;
  }

  Expr expression() {
    return assignment();
  }

  Expr assignment() {
    Expr expr = or();
    if (match([TokenType.equal])) {
      Token equals = previous();
      Expr value = assignment();

      if (expr is Variable) {
        Token name = expr.name;
        return Assign(name: name, value: value);
      }

      error(equals, "Invalid assignment target.");
    }
    return expr;
  }

  Expr or() {
    Expr expr = and();

    while (match([TokenType.or])) {
      Token operator = previous();
      Expr right = and();
      expr = Logical(left: expr, operator: operator, right: right);
    }

    return expr;
  }

  Expr and() {
    Expr expr = equality();

    while (match([TokenType.and])) {
      Token operator = previous();
      Expr right = equality();
      expr = Logical(left: expr, operator: operator, right: right);
    }

    return expr;
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

    if (match([TokenType.identifier])) {
      return Variable(name: previous());
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
