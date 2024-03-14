/// A tag parser that can parse a query string and evaluate it against a set of tags.
library;

abstract class TagParseElement {
  bool evaluate(final Map<String, bool> tags);
}

class Literal extends TagParseElement {

  Literal(this.value);
  final String value;

  @override
  bool evaluate(final Map<String, bool> tags) => tags[value] ?? false;
}

class NotClause extends TagParseElement {

  NotClause(this.child);
  final TagParseElement child;

  @override
  bool evaluate(final Map<String, bool> tags) => !child.evaluate(tags);
}

class AndClause extends TagParseElement {

  AndClause(this.children);
  final List<TagParseElement> children;

  @override
  bool evaluate(final Map<String, bool> tags) => children.every((final element) => element.evaluate(tags));
}

class OrClause extends TagParseElement {

  OrClause(this.children);
  final List<TagParseElement> children;

  @override
  bool evaluate(final Map<String, bool> tags) => children.any((final element) => element.evaluate(tags));
}

class Parenthesis extends TagParseElement {

  Parenthesis(this.child);
  final TagParseElement child;

  @override
  bool evaluate(final Map<String, bool> tags) => child.evaluate(tags);
}

enum TokenType { and, or, not, lParen, rParen, literal }

class Token {

  Token(this.type, [this.value]);
  final TokenType type;
  final String? value;
}

class Lexer {

  Lexer(this.text);
  static final literal = RegExp('[^&|!() ]');
  static final Map<String, TokenType> keywords = {
    '&': TokenType.and,
    '|': TokenType.or,
    '!': TokenType.not,
    '(': TokenType.lParen,
    ')': TokenType.rParen,
  };

  final String text;
  int position = 0;
  Token? currentToken;

  Token? nextToken() {
    if (position >= text.length) {
      return null;
    }

    final currentChar = text[position];
    if (currentChar.trim().isEmpty) {
      position++;
      return nextToken(); // Skip whitespace
    }

    if (keywords.containsKey(currentChar)) {
      final type = keywords[currentChar]!;
      position++;
      return Token(type);
    }

    if (literal.hasMatch(currentChar)) {
      final start = position;
      while (position < text.length && literal.hasMatch(text[position])) {
        position++;
      }
      final value = text.substring(start, position);
      return Token(TokenType.literal, value);
    }

    throw Exception('Unexpected character $currentChar at position $position');
  }
}

class Parser {

  Parser(this.lexer) {
    currentToken = lexer.nextToken();
  }
  final Lexer lexer;
  Token? currentToken;

  void eat(final TokenType type) {
    if (currentToken?.type == type) {
      currentToken = lexer.nextToken();
    } else {
      throw Exception(
          'Expected token of type $type, got ${currentToken?.type}',);
    }
  }

  TagParseElement parse() {
    final result = expression();
    if (currentToken != null) {
      throw Exception('Unexpected input after expression');
    }
    return result;
  }

  TagParseElement expression() => orClause();

  TagParseElement orClause() {
    final nodes = [andClause()];

    while (currentToken?.type == TokenType.or) {
      eat(TokenType.or);
      nodes.add(andClause());
    }

    if (nodes.length > 1) {
      return OrClause(nodes);
    } else {
      return nodes.first;
    }
  }

  TagParseElement andClause() {
    final nodes = [notClause()];

    while (currentToken?.type == TokenType.and) {
      eat(TokenType.and);
      nodes.add(notClause());
    }

    if (nodes.length > 1) {
      return AndClause(nodes);
    } else {
      return nodes.first;
    }
  }

  TagParseElement notClause() {
    if (currentToken?.type == TokenType.not) {
      eat(TokenType.not);
      return NotClause(notClause());
    }

    return primary();
  }

  TagParseElement primary() {
    if (currentToken?.type == TokenType.lParen) {
      eat(TokenType.lParen);
      final node = expression();
      eat(TokenType.rParen);
      return Parenthesis(node);
    } else if (currentToken?.type == TokenType.literal) {
      final token = currentToken!;
      eat(TokenType.literal);
      return Literal(token.value!);
    } else {
      throw Exception('Unexpected token: ${currentToken?.type}');
    }
  }
}

TagParseElement parseTagQuery(final String query) {
  final lexer = Lexer(query);
  final parser = Parser(lexer);
  return parser.parse();
}
