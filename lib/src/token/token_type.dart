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
  $class,
  $else,
  $false,
  fun,
  $for,
  $if,
  nil,
  or,
  print,
  $return,
  $super,
  $this,
  $true,
  $var,
  $while,
  eof
}
