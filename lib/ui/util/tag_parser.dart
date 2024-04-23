/// Parses a tag query string into a tree of [TagParseElement]s.
// ignore: one_member_abstracts
abstract class TagParseElement {
  /// Evaluates the element against a set of tags.
  bool evaluate(final Set<String> tags);
}

class _Literal extends TagParseElement {
  _Literal(this.value);

  final String value;

  @override
  bool evaluate(final Set<String> tags) => tags.contains(value);
}

class _NotClause extends TagParseElement {
  _NotClause(this.child);

  final TagParseElement child;

  @override
  bool evaluate(final Set<String> tags) => !child.evaluate(tags);
}

class _AndClause extends TagParseElement {
  _AndClause(this.children);

  final List<TagParseElement> children;

  @override
  bool evaluate(final Set<String> tags) =>
      children.every((final element) => element.evaluate(tags));
}

class _OrClause extends TagParseElement {
  _OrClause(this.children);

  final List<TagParseElement> children;

  @override
  bool evaluate(final Set<String> tags) =>
      children.any((final element) => element.evaluate(tags));
}

class _Parenthesis extends TagParseElement {
  _Parenthesis(this.child);

  final TagParseElement child;

  @override
  bool evaluate(final Set<String> tags) => child.evaluate(tags);
}

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
  int position = 0;
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
      return _OrClause(nodes);
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
      return _AndClause(nodes);
    } else {
      return nodes.first;
    }
  }

  TagParseElement notClause() {
    if (currentToken?.type == _TokenType.not) {
      eat(_TokenType.not);
      return _NotClause(notClause());
    }

    return primary();
  }

  TagParseElement primary() {
    if (currentToken?.type == _TokenType.lParen) {
      eat(_TokenType.lParen);
      final node = expression();
      eat(_TokenType.rParen);
      return _Parenthesis(node);
    } else if (currentToken?.type == _TokenType.literal) {
      final token = currentToken!;
      eat(_TokenType.literal);
      return _Literal(token.value!);
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
