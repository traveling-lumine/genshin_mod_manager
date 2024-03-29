abstract class TagParseElement {
  bool evaluate(Map<String, bool> tags);
}

class Literal extends TagParseElement {
  final String value;

  Literal(this.value);

  @override
  bool evaluate(Map<String, bool> tags) {
    return tags[value] ?? false;
  }
}

class NotClause extends TagParseElement {
  final TagParseElement child;

  NotClause(this.child);

  @override
  bool evaluate(Map<String, bool> tags) {
    return !child.evaluate(tags);
  }
}

class AndClause extends TagParseElement {
  final List<TagParseElement> children;

  AndClause(this.children);

  @override
  bool evaluate(Map<String, bool> tags) {
    return children.every((element) => element.evaluate(tags));
  }
}

class OrClause extends TagParseElement {
  final List<TagParseElement> children;

  OrClause(this.children);

  @override
  bool evaluate(Map<String, bool> tags) {
    return children.any((element) => element.evaluate(tags));
  }
}

class Parenthesis extends TagParseElement {
  final TagParseElement child;

  Parenthesis(this.child);

  @override
  bool evaluate(Map<String, bool> tags) {
    return child.evaluate(tags);
  }
}

enum TokenType { and, or, not, lParen, rParen, literal }

class Token {
  final TokenType type;
  final String? value;

  Token(this.type, [this.value]);
}

class Lexer {
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

  Lexer(this.text);

  Token? nextToken() {
    if (position >= text.length) {
      return null;
    }

    var currentChar = text[position];
    if (currentChar.trim().isEmpty) {
      position++;
      return nextToken(); // Skip whitespace
    }

    if (keywords.containsKey(currentChar)) {
      var type = keywords[currentChar]!;
      position++;
      return Token(type);
    }

    if (RegExp(r'[^&|!() ]').hasMatch(currentChar)) {
      var start = position;
      while (position < text.length &&
          RegExp(r'[^&|!() ]').hasMatch(text[position])) {
        position++;
      }
      var value = text.substring(start, position);
      return Token(TokenType.literal, value);
    }

    throw Exception('Unexpected character $currentChar at position $position');
  }
}

class Parser {
  final Lexer lexer;
  Token? currentToken;

  Parser(this.lexer) {
    currentToken = lexer.nextToken();
  }

  void eat(TokenType type) {
    if (currentToken?.type == type) {
      currentToken = lexer.nextToken();
    } else {
      throw Exception(
          'Expected token of type $type, got ${currentToken?.type}');
    }
  }

  TagParseElement parse() {
    var result = expression();
    if (currentToken != null) {
      throw Exception('Unexpected input after expression');
    }
    return result;
  }

  TagParseElement expression() => orClause();

  TagParseElement orClause() {
    var nodes = [andClause()];

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
    var nodes = [notClause()];

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
      var node = expression();
      eat(TokenType.rParen);
      return Parenthesis(node);
    } else if (currentToken?.type == TokenType.literal) {
      var token = currentToken!;
      eat(TokenType.literal);
      return Literal(token.value!);
    } else {
      throw Exception('Unexpected token: ${currentToken?.type}');
    }
  }
}

TagParseElement parseTagQuery(String query) {
  var lexer = Lexer(query);
  var parser = Parser(lexer);
  return parser.parse();
}
