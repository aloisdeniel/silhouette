/// Parser for Silhouette template syntax
///
/// Parses Svelte-like template syntax into an AST
library;

import 'ast.dart';

class ParseError implements Exception {
  final String message;
  final int position;

  ParseError(this.message, this.position);

  @override
  String toString() => 'ParseError at $position: $message';
}

class Parser {
  final String source;
  int _index = 0;

  Parser(this.source);

  /// Parse the source into an AST
  RootNode parse() {
    ScriptNode? script;
    ScriptNode? moduleScript;
    StyleNode? style;
    final templateNodes = <TemplateNode>[];

    // Parse all top-level content
    while (!_isAtEnd()) {
      _skipWhitespace();
      if (_isAtEnd()) break;

      if (_peek() == '<') {
        final tagStart = _index;
        _advance(); // consume <

        if (_match('script')) {
          final isModule = _parseScriptTag();
          final content = _readUntil('</script>');
          final end = _index;
          
          final scriptNode = ScriptNode(
            content: content,
            isModule: isModule,
            start: tagStart,
            end: end,
          );

          if (isModule) {
            moduleScript = scriptNode;
          } else {
            script = scriptNode;
          }
        } else if (_match('style')) {
          final scoped = _parseStyleTag();
          final content = _readUntil('</style>');
          style = StyleNode(
            content: content,
            scoped: scoped,
            start: tagStart,
            end: _index,
          );
        } else {
          // Template content
          _index = tagStart;
          final node = _parseTemplateNode();
          if (node != null) {
            templateNodes.add(node);
          }
        }
      } else {
        // Text or other content
        final node = _parseTemplateNode();
        if (node != null) {
          templateNodes.add(node);
        }
      }
    }

    final fragment = FragmentNode(
      nodes: templateNodes,
      start: 0,
      end: source.length,
    );

    return RootNode(
      script: script,
      moduleScript: moduleScript,
      style: style,
      fragment: fragment,
      start: 0,
      end: source.length,
    );
  }

  /// Parse script tag attributes and return if it's a module script
  bool _parseScriptTag() {
    _skipWhitespace();
    
    bool isModule = false;
    while (_peek() != '>' && !_isAtEnd()) {
      if (_match('context')) {
        _skipWhitespace();
        if (_match('=')) {
          _skipWhitespace();
          final quote = _peek();
          if (quote == '"' || quote == "'") {
            _advance();
            final value = _readUntil(quote);
            if (value == 'module') {
              isModule = true;
            }
          }
        }
      } else {
        _advance();
      }
    }
    
    if (_peek() == '>') _advance();
    return isModule;
  }

  /// Parse style tag attributes and return if it's scoped
  bool _parseStyleTag() {
    _skipWhitespace();
    
    bool scoped = false;
    while (_peek() != '>' && !_isAtEnd()) {
      if (_match('scoped')) {
        scoped = true;
      }
      _advance();
    }
    
    if (_peek() == '>') _advance();
    return scoped;
  }

  /// Parse a fragment (list of template nodes)
  List<TemplateNode> _parseFragment([List<String>? untilAny]) {
    final nodes = <TemplateNode>[];

    while (!_isAtEnd()) {
      if (untilAny != null) {
        var shouldBreak = false;
        for (final until in untilAny) {
          if (_peek(until.length) == until) {
            shouldBreak = true;
            break;
          }
        }
        if (shouldBreak) break;
      }

      _skipWhitespace();
      if (_isAtEnd()) break;
      
      if (untilAny != null) {
        var shouldBreak = false;
        for (final until in untilAny) {
          if (_peek(until.length) == until) {
            shouldBreak = true;
            break;
          }
        }
        if (shouldBreak) break;
      }

      final node = _parseTemplateNode();
      if (node != null) {
        nodes.add(node);
      }
    }

    return nodes;
  }

  /// Parse a single template node
  TemplateNode? _parseTemplateNode() {
    final start = _index;

    if (_peek() == '{') {
      return _parseTag();
    } else if (_peek() == '<') {
      return _parseElement();
    } else {
      return _parseText();
    }
  }

  /// Parse a tag ({expression}, {@html}, {#if}, etc.)
  TemplateNode _parseTag() {
    final start = _index;
    _advance(); // consume {
    _skipWhitespace();

    // Check for special tags
    if (_peek() == '@') {
      _advance(); // consume @
      if (_match('html')) {
        _skipWhitespace();
        final expression = _readUntil('}');
        return HtmlTagNode(
          expression: expression.trim(),
          start: start,
          end: _index,
        );
      }
    } else if (_peek() == '#') {
      _advance(); // consume #
      
      if (_match('if')) {
        return _parseIfBlock(start);
      } else if (_match('each')) {
        return _parseEachBlock(start);
      } else if (_match('await')) {
        return _parseAwaitBlock(start);
      }
    }

    // Regular expression tag
    final expression = _readUntil('}');
    return ExpressionTagNode(
      expression: expression.trim(),
      start: start,
      end: _index,
    );
  }

  /// Parse an if block
  IfBlockNode _parseIfBlock(int start) {
    _skipWhitespace();
    final condition = _readUntil('}').trim();

    final consequent = _parseFragment(['{:else}', '{/if}']);
    
    List<TemplateNode>? alternate;
    if (_peek(7) == '{:else}') {
      _advance(7); // consume {:else}
      alternate = _parseFragment(['{/if}']);
    }

    _match('{/if}');
    return IfBlockNode(
      condition: condition,
      consequent: consequent,
      alternate: alternate,
      start: start,
      end: _index,
    );
  }

  /// Parse an each block
  EachBlockNode _parseEachBlock(int start) {
    _skipWhitespace();
    final eachExpression = _readUntil('}').trim();
    
    // Parse "items as item, index (key)"
    final parts = eachExpression.split(' as ');
    if (parts.length != 2) {
      throw ParseError('Invalid each syntax', start);
    }

    final expression = parts[0].trim();
    var rest = parts[1].trim();
    
    String? keyExpression;
    if (rest.contains('(')) {
      final keyStart = rest.indexOf('(');
      final keyEnd = rest.indexOf(')', keyStart);
      if (keyEnd == -1) {
        throw ParseError('Unclosed key expression', start);
      }
      keyExpression = rest.substring(keyStart + 1, keyEnd).trim();
      rest = rest.substring(0, keyStart).trim();
    }

    final itemParts = rest.split(',').map((e) => e.trim()).toList();
    final itemName = itemParts[0];
    final indexName = itemParts.length > 1 ? itemParts[1] : null;

    final body = _parseFragment(['{:else}', '{/each}']);
    
    List<TemplateNode>? fallback;
    if (_peek(7) == '{:else}') {
      _advance(7);
      fallback = _parseFragment(['{/each}']);
    }

    _match('{/each}');
    return EachBlockNode(
      expression: expression,
      itemName: itemName,
      indexName: indexName,
      keyExpression: keyExpression,
      body: body,
      fallback: fallback,
      start: start,
      end: _index,
    );
  }

  /// Parse an await block
  AwaitBlockNode _parseAwaitBlock(int start) {
    _skipWhitespace();
    final expression = _readUntil('}').trim();

    List<TemplateNode>? pending;
    List<TemplateNode>? thenBlock;
    List<TemplateNode>? catchBlock;
    String? thenVariable;
    String? catchVariable;

    // Parse pending block
    pending = _parseFragment(['{:then', '{:catch', '{/await}']);
    
    if (_peek(6) == '{:then') {
      _advance(6);
      _skipWhitespace();
      if (_peek() != '}') {
        thenVariable = _readUntil('}').trim();
      } else {
        _advance(); // consume }
      }
      thenBlock = _parseFragment(['{:catch', '{/await}']);
    }

    if (_peek(7) == '{:catch') {
      _advance(7);
      _skipWhitespace();
      if (_peek() != '}') {
        catchVariable = _readUntil('}').trim();
      } else {
        _advance(); // consume }
      }
      catchBlock = _parseFragment(['{/await}']);
    }

    _match('{/await}');
    return AwaitBlockNode(
      expression: expression,
      thenVariable: thenVariable,
      catchVariable: catchVariable,
      pending: pending,
      then: thenBlock,
      catchBlock: catchBlock,
      start: start,
      end: _index,
    );
  }

  /// Parse an HTML element or component
  ElementNode _parseElement() {
    final start = _index;
    _advance(); // consume <

    // Check for closing tag
    if (_peek() == '/') {
      throw ParseError('Unexpected closing tag', start);
    }

    // Read tag name
    final name = _readIdentifier();
    final isComponent = name.isNotEmpty && name[0].toUpperCase() == name[0];

    // Parse attributes
    final attributes = <AttributeNode>[];
    while (_peek() != '>' && _peek() != '/' && !_isAtEnd()) {
      _skipWhitespace();
      if (_peek() == '>' || _peek() == '/') break;

      final attr = _parseAttribute();
      if (attr != null) {
        attributes.add(attr);
      }
    }

    // Check for self-closing
    final selfClosing = _peek() == '/' && _peek(2) == '/>';
    if (selfClosing) {
      _advance(2); // consume />
      return ElementNode(
        name: name,
        attributes: attributes,
        children: [],
        isComponent: isComponent,
        start: start,
        end: _index,
      );
    }

    if (_peek() == '>') _advance();

    // Parse children
    final children = _parseFragment(['</$name>']);

    // Consume closing tag
    _match('</$name>');

    return ElementNode(
      name: name,
      attributes: attributes,
      children: children,
      isComponent: isComponent,
      start: start,
      end: _index,
    );
  }

  /// Parse an attribute
  AttributeNode? _parseAttribute() {
    final start = _index;
    _skipWhitespace();

    if (_peek() == '{') {
      // Spread attribute {...props}
      _advance(); // consume {
      if (_peek() != '.') {
        _index = start;
        return null;
      }
      _advance(3); // consume ...
      final expression = _readUntil('}');
      return SpreadAttribute(
        expression: expression.trim(),
        start: start,
        end: _index,
      );
    }

    final name = _readAttributeName();
    if (name.isEmpty) return null;

    // Check for event handler
    if (name.startsWith('on:')) {
      final event = name.substring(3);
      _skipWhitespace();
      String? handler;
      if (_peek() == '=') {
        _advance();
        _skipWhitespace();
        if (_peek() == '{') {
          _advance();
          handler = _readUntil('}');
        }
      }
      return EventAttribute(
        event: event,
        handler: handler,
        start: start,
        end: _index,
      );
    }

    // Check for bind directive
    if (name.startsWith('bind:')) {
      final property = name.substring(5);
      _skipWhitespace();
      String value = property;
      if (_peek() == '=') {
        _advance();
        _skipWhitespace();
        if (_peek() == '{') {
          _advance();
          value = _readUntil('}');
        }
      }
      return BindDirective(
        property: property,
        value: value,
        start: start,
        end: _index,
      );
    }

    // Regular attribute
    _skipWhitespace();
    final values = <AttributeValue>[];
    
    if (_peek() == '=') {
      _advance();
      _skipWhitespace();
      
      final quote = _peek();
      if (quote == '"' || quote == "'") {
        _advance();
        values.addAll(_parseAttributeValue(quote));
      } else if (_peek() == '{') {
        _advance();
        final expr = _readUntil('}');
        values.add(ExpressionAttributeValue(
          expression: expr,
          start: _index - expr.length - 2,
          end: _index,
        ));
      }
    }

    return RegularAttribute(
      name: name,
      value: values,
      start: start,
      end: _index,
    );
  }

  /// Parse attribute value (can contain text and expressions)
  List<AttributeValue> _parseAttributeValue(String quote) {
    final values = <AttributeValue>[];
    final buffer = StringBuffer();
    final start = _index;

    while (_peek() != quote && !_isAtEnd()) {
      if (_peek() == '{') {
        // Save text before expression
        if (buffer.isNotEmpty) {
          values.add(TextAttributeValue(
            text: buffer.toString(),
            start: start,
            end: _index,
          ));
          buffer.clear();
        }

        _advance(); // consume {
        final expr = _readUntil('}');
        values.add(ExpressionAttributeValue(
          expression: expr,
          start: _index - expr.length - 2,
          end: _index,
        ));
      } else {
        buffer.write(_advance());
      }
    }

    if (buffer.isNotEmpty) {
      values.add(TextAttributeValue(
        text: buffer.toString(),
        start: start,
        end: _index,
      ));
    }

    if (_peek() == quote) _advance();
    return values;
  }

  /// Parse plain text
  TextNode _parseText() {
    final start = _index;
    final buffer = StringBuffer();

    while (!_isAtEnd()) {
      if (_peek() == '<' || _peek() == '{') {
        break;
      }
      buffer.write(_advance());
    }

    return TextNode(
      data: buffer.toString(),
      start: start,
      end: _index,
    );
  }

  /// Read an identifier
  String _readIdentifier() {
    final buffer = StringBuffer();
    while (!_isAtEnd() && _isIdentifierChar(_peek())) {
      buffer.write(_advance());
    }
    return buffer.toString();
  }

  /// Read an attribute name (can include : and -)
  String _readAttributeName() {
    final buffer = StringBuffer();
    while (!_isAtEnd() && _isAttributeNameChar(_peek())) {
      buffer.write(_advance());
    }
    return buffer.toString();
  }

  /// Read until a specific string
  String _readUntil(String delimiter) {
    final buffer = StringBuffer();
    while (!_isAtEnd() && _peek(delimiter.length) != delimiter) {
      buffer.write(_advance());
    }
    if (_peek(delimiter.length) == delimiter) {
      _index += delimiter.length;
    }
    return buffer.toString();
  }

  /// Check if character is valid in an identifier
  bool _isIdentifierChar(String char) {
    return RegExp(r'[a-zA-Z0-9_]').hasMatch(char);
  }

  /// Check if character is valid in an attribute name
  bool _isAttributeNameChar(String char) {
    return RegExp(r'[a-zA-Z0-9_:\-]').hasMatch(char);
  }

  /// Skip whitespace
  void _skipWhitespace() {
    while (!_isAtEnd() && RegExp(r'\s').hasMatch(_peek())) {
      _advance();
    }
  }

  /// Check if string matches at current position
  bool _match(String str) {
    if (_peek(str.length) == str) {
      _index += str.length;
      return true;
    }
    return false;
  }

  /// Peek at current character or substring
  String _peek([int length = 1]) {
    if (_index + length > source.length) {
      return source.substring(_index);
    }
    return source.substring(_index, _index + length);
  }

  /// Advance and return current character
  String _advance([int count = 1]) {
    final char = _peek(count);
    _index += count;
    return char;
  }

  /// Check if at end of source
  bool _isAtEnd() {
    return _index >= source.length;
  }
}
