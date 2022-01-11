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
      if (match([TokenType.fun])) {
        return function("function");
      }

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
    if (match([TokenType.$for])) {
      return forStatement();
    }

    if (match([TokenType.$if])) {
      return ifStatement();
    }

    if (match([TokenType.print])) {
      return printStatement();
    }

    if (match([TokenType.$return])) {
      return returnStatement();
    }

    if (match([TokenType.$while])) {
      return whileStatement();
    }

    if (match([TokenType.leftBrace])) {
      return Block(statements: block());
    }
    return expressionStatement();
  }

  Stmt forStatement() {
    consume(TokenType.leftParen, "Expect '(' after 'for'.");
    Stmt? initializer;
    if (match([TokenType.semicolon])) {
      initializer = null;
    } else if (match([TokenType.$var])) {
      initializer = varDeclaration();
    } else {
      initializer = expressionStatement();
    }

    Expr? condition;
    if (!check(TokenType.semicolon)) {
      condition = expression();
    }
    consume(TokenType.semicolon, "Expect ';' after loop condition.");

    Expr? increment;
    if (!check(TokenType.rightParen)) {
      increment = expression();
    }
    consume(TokenType.rightParen, "Expect ')' after for clauses.");
    Stmt body = statement();

    if (increment != null) {
      body = Block(statements: [body, Expression(expression: increment)]);
    }

    condition ??= Literal(value: true);
    body = While(condition: condition, body: body);

    if (initializer != null) {
      body = Block(statements: [initializer, body]);
    }

    return body;
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

  Stmt returnStatement() {
    Token keyword = previous();
    Expr? value;
    if (!check(TokenType.semicolon)) {
      value = expression();
    }

    consume(TokenType.semicolon, "Expect ';' after return value.");
    return Return(keyword: keyword, value: value);
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

  Funct function(String kind) {
    Token name = consume(TokenType.identifier, "Expect $kind name.");
    consume(TokenType.leftParen, "Expect '(' after $kind name.");
    List<Token> parameters = [];
    if (!check(TokenType.rightParen)) {
      do {
        if (parameters.length >= 255) {
          error(peek(), "Can't have more than 255 parameters.");
        }

        parameters.add(consume(TokenType.identifier, "Expect parameter name."));
      } while (match([TokenType.comma]));
    }
    consume(TokenType.rightParen, "Expect ')' after parameters.");

    consume(TokenType.leftBrace, "Expect '{' before $kind body.");
    List<Stmt> body = block();
    return Funct(name: name, params: parameters, body: body);
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

    return call();
  }

  Expr call() {
    Expr expr = primary();

    while (true) {
      if (match([TokenType.leftParen])) {
        expr = finishCall(expr);
      } else {
        break;
      }
    }
    return expr;
  }

  Expr finishCall(Expr callee) {
    List<Expr> arguments = [];
    if (!check(TokenType.rightParen)) {
      do {
        if (arguments.length >= 255) {
          error(peek(), "Can't have more than 255 arguments");
        }
        arguments.add(expression());
      } while (match([TokenType.comma]));
    }

    Token paren = consume(TokenType.rightParen, "Expect ')' after arguments.");

    return Call(callee: callee, paren: paren, arguments: arguments);
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

    throw error(peek(), 'Expect expression.');
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
