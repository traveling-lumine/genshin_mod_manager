// Parses a tag query string into a tree of [TagParseElement]s.

typedef TagParseElement = bool Function(Set<String> tags);

TagParseElement _literal(final String value) =>
    (final tags) => tags.contains(value);

TagParseElement _notClause(final TagParseElement child) =>
    (final tags) => !child(tags);

TagParseElement _andClause(final List<TagParseElement> children) =>
    (final tags) => children.every((final element) => element(tags));

TagParseElement _orClause(final List<TagParseElement> children) =>
    (final tags) => children.any((final element) => element(tags));

TagParseElement _parenthesis(final TagParseElement child) => child;

enum _TokenType { and, or, not, lParen, rParen, literal }

class _Token {
  _Token(this.type, [this.value]);

  final _TokenType type;
  final String? value;
}

class _Lexer {
  _Lexer(this.text);

  static final literal = RegExp('[^&|!() ]');
  static final Map<String, _TokenType> keywords = {
    '&': _TokenType.and,
    '|': _TokenType.or,
    '!': _TokenType.not,
    '(': _TokenType.lParen,
    ')': _TokenType.rParen,
  };

  final String text;
  var position = 0;
  _Token? currentToken;

  _Token? nextToken() {
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
      return _Token(type);
    }

    if (literal.hasMatch(currentChar)) {
      final start = position;
      while (position < text.length && literal.hasMatch(text[position])) {
        position++;
      }
      final value = text.substring(start, position);
      return _Token(_TokenType.literal, value);
    }

    throw Exception('Unexpected character $currentChar at position $position');
  }
}

class _Parser {
  _Parser(this.lexer) {
    currentToken = lexer.nextToken();
  }

  final _Lexer lexer;
  _Token? currentToken;

  void eat(final _TokenType type) {
    if (currentToken?.type == type) {
      currentToken = lexer.nextToken();
    } else {
      throw Exception(
        'Expected token of type $type, got ${currentToken?.type}',
      );
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

    while (currentToken?.type == _TokenType.or) {
      eat(_TokenType.or);
      nodes.add(andClause());
    }

    if (nodes.length > 1) {
      return _orClause(nodes);
    } else {
      return nodes.first;
    }
  }

  TagParseElement andClause() {
    final nodes = [notClause()];

    while (currentToken?.type == _TokenType.and) {
      eat(_TokenType.and);
      nodes.add(notClause());
    }

    if (nodes.length > 1) {
      return _andClause(nodes);
    } else {
      return nodes.first;
    }
  }

  TagParseElement notClause() {
    if (currentToken?.type == _TokenType.not) {
      eat(_TokenType.not);
      return _notClause(notClause());
    }

    return primary();
  }

  TagParseElement primary() {
    if (currentToken?.type == _TokenType.lParen) {
      eat(_TokenType.lParen);
      final node = expression();
      eat(_TokenType.rParen);
      return _parenthesis(node);
    } else if (currentToken?.type == _TokenType.literal) {
      final token = currentToken!;
      eat(_TokenType.literal);
      return _literal(token.value!);
    } else {
      throw Exception('Unexpected token: ${currentToken?.type}');
    }
  }
}

/// Parses a tag query string into a tree of [TagParseElement]s.
TagParseElement parseTagQuery(final String query) {
  final lexer = _Lexer(query);
  final parser = _Parser(lexer);
  return parser.parse();
}
