enum TokenType {
  // single-character tokens
  leftParen,
  rightParen,
  leftBrace,
  rightBrace,
  comma,
  dot,
  minus,
  plus,
  semicolon,
  slash,
  star,

  // one or two character tokens
  bang,
  bangEqual,
  equal,
  equalEqual,
  greater,
  greaterEqual,
  less,
  lessEqual,

  // literals
  identifier,
  string,
  number,

  // keywords
  and,
  classT,
  elseT,
  falseT,
  fun,
  forT,
  ifT,
  nil,
  or,
  print,
  returnT,
  superT,
  thisT,
  trueT,
  varT,
  whileT,
  eof
}
