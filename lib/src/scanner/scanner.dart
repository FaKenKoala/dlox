import 'package:dlox/src/token/token.dart';
import 'package:dlox/src/token/token_type.dart';

import '../../dlox.dart';

class Scanner {
  Scanner(this.source);

  final String source;
  final List<Token> tokens = [];
  int _start = 0;
  int _current = 0;
  int _line = 1;

  final Map<String, TokenType> keywords = {
    "and": TokenType.and,
    "class": TokenType.classT,
    "else": TokenType.elseT,
    "false": TokenType.falseT,
    "for": TokenType.forT,
    "fun": TokenType.fun,
    "if": TokenType.ifT,
    "nil": TokenType.nil,
    "or": TokenType.or,
    "print": TokenType.print,
    "return": TokenType.returnT,
    "super": TokenType.superT,
    "this": TokenType.thisT,
    "true": TokenType.trueT,
    "var": TokenType.varT,
    "while": TokenType.whileT
  };

  List<Token> scanTokens() {
    while (!isAtEnd()) {
      _start = _current;
      _scanToken();
    }

    tokens.add(
        Token(type: TokenType.eof, lexeme: "", line: _line, literal: null));
    return tokens;
  }

  bool isAtEnd() {
    return _current >= source.length;
  }

  void _scanToken() {
    String c = advance();
    switch (c) {
      case '(':
        _addToken(TokenType.leftParen);
        break;
      case ')':
        _addToken(TokenType.rightParen);
        break;
      case '{':
        _addToken(TokenType.leftBrace);
        break;
      case '}':
        _addToken(TokenType.rightBrace);
        break;
      case ',':
        _addToken(TokenType.comma);
        break;
      case '.':
        _addToken(TokenType.dot);
        break;
      case '-':
        _addToken(TokenType.minus);
        break;
      case '+':
        _addToken(TokenType.plus);
        break;
      case ';':
        _addToken(TokenType.semicolon);
        break;
      case '*':
        _addToken(TokenType.star);
        break;

      case '!':
        _addToken(match('=') ? TokenType.bangEqual : TokenType.bang);
        break;

      case '=':
        _addToken(match('=') ? TokenType.equalEqual : TokenType.equal);
        break;

      case '<':
        _addToken(match('=') ? TokenType.lessEqual : TokenType.less);
        break;

      case '>':
        _addToken(match('=') ? TokenType.greaterEqual : TokenType.greater);
        break;

      case '/':
        if (match('/')) {
          while (peek() != '\n' && !isAtEnd()) {
            advance();
          }
        } else {
          _addToken(TokenType.slash);
        }
        break;

      case ' ':
      case '\r':
      case '\t':
        break;

      case '\n':
        _line++;
        break;

      case '"':
        string();
        break;

      default:
        if (isDigit(c)) {
          number();
        } else if (isAlpha(c)) {
          identifier();
        } else {
          Lox.error(_line, 'Unexpected character: $c');
        }
        break;
    }
  }

  void string() {
    while (peek() != '"' && !isAtEnd()) {
      if (peek() == '\n') {
        _line++;
      }
      advance();
    }

    if (isAtEnd()) {
      Lox.error(_line, 'Unterminated string.');
      return;
    }

    advance();

    String value = source.substring(_start + 1, _current - 1);
    _addToken(TokenType.string, value);
  }

  String peek() {
    if (isAtEnd()) {
      /// 结束符
      return String.fromCharCode(0x00);
    }
    return source.substring(_current, _current + 1);
  }

  String advance() {
    return source.substring(_current++, _current);
  }

  void _addToken(TokenType type, [Object? literal]) {
    String text = source.substring(_start, _current);
    tokens.add(Token(type: type, lexeme: text, line: _line, literal: literal));
  }

  bool match(String expected) {
    if (isAtEnd()) return false;
    final text = source.substring(_current, _current + 1);
    print('比对: $text');
    if (source.substring(_current, _current + 1) != expected) return false;

    _current++;
    return true;
  }

  bool isDigit(String c) {
    int code = c.codeUnitAt(0);
    int zeroCode = "0".codeUnitAt(0);
    int nineCode = "9".codeUnitAt(0);
    return code >= zeroCode && code <= nineCode;
  }

  void number() {
    while (isDigit(peek())) {
      advance();
    }
    if (peek() == '.' && isDigit(peekNext())) {
      advance();
      while (isDigit(peek())) {
        advance();
      }
    }

    _addToken(
        TokenType.number, double.parse(source.substring(_start, _current)));
  }

  String peekNext() {
    if (_current + 1 >= source.length) {
      return String.fromCharCode(0x00);
    }
    return source.substring(_current + 1, _current + 2);
  }

  void identifier() {
    while (isAlphaNumeric(peek())) {
      advance();
    }

    String text = source.substring(_start, _current);
    TokenType type = keywords[text] ?? TokenType.identifier;
    _addToken(type);
  }

  bool isAlpha(String c) {
    int code = c.codeUnitAt(0);
    return code >= 'a'.codeUnitAt(0) && code <= 'z'.codeUnitAt(0) ||
        code >= 'A'.codeUnitAt(0) && code <= 'Z'.codeUnitAt(0) ||
        c == '_';
  }

  bool isAlphaNumeric(String c) {
    return isAlpha(c) || isDigit(c);
  }
}
