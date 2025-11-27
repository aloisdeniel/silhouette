/// Static code generator for Silhouette components
///
/// Generates Dart code that renders HTML as a string
library;

import '../ast.dart';
import '../analyzer.dart';

class StaticCodeGenerator {
  final RootNode ast;
  final AnalysisResult analysis;
  final String componentName;
  final StringBuffer _output = StringBuffer();
  int _indent = 0;

  StaticCodeGenerator(this.ast, this.analysis, {this.componentName = 'Component'});

  /// Generate Dart code
  String generate() {
    _output.clear();

    // Generate user imports (replace .client.g.dart and .silhouette with .static.g.dart)
    for (final import in analysis.imports) {
      var uri = import.uri.replaceAll('.client.g.dart', '.static.g.dart');
      uri = uri.replaceAll('.silhouette', '.static.g.dart');
      if (import.alias != null) {
        _writeLine("import '$uri' as ${import.alias};");
      } else {
        _writeLine("import '$uri';");
      }
    }
    if (analysis.imports.isNotEmpty) {
      _writeLine();
    }

    // Generate class
    final className = componentName;
    _writeLine('class $className {');
    _indent++;

    // Generate property fields (props and state)
    _generatePropertyFields();

    // Generate state fields
    _generateStateFields();

    // Generate derived fields
    _generateDerivedFields();

    // Generate constructor
    _generateConstructor(className);

    // Generate build method
    _generateBuildMethod();

    _indent--;
    _writeLine('}');
    _writeLine();

    return _output.toString();
  }

  /// Generate property fields
  void _generatePropertyFields() {
    for (final binding in analysis.propBindings) {
      final type = binding.type ?? 'dynamic';
      _writeLine('final $type ${binding.name};');
    }
    if (analysis.propBindings.isNotEmpty) {
      _writeLine();
    }
  }

  /// Generate state fields (treated as props in static mode)
  void _generateStateFields() {
    for (final binding in analysis.stateBindings) {
      final type = binding.type ?? 'dynamic';
      _writeLine('final $type ${binding.name};');
    }
    if (analysis.stateBindings.isNotEmpty) {
      _writeLine();
    }
  }

  /// Generate derived fields
  void _generateDerivedFields() {
    for (final binding in analysis.derivedBindings) {
      final type = binding.type ?? 'dynamic';
      _writeLine('late final $type ${binding.name};');
    }
    if (analysis.derivedBindings.isNotEmpty) {
      _writeLine();
    }
  }

  /// Generate constructor
  void _generateConstructor(String className) {
    // Generate constructor with named parameters for properties and state
    final hasProps = analysis.propBindings.isNotEmpty;
    final hasState = analysis.stateBindings.isNotEmpty;
    final hasParams = hasProps || hasState;
    final hasDerived = analysis.derivedBindings.isNotEmpty;

    if (hasParams) {
      _write('$className({');
      
      // Add prop parameters
      var paramIndex = 0;
      for (var i = 0; i < analysis.propBindings.length; i++) {
        final binding = analysis.propBindings[i];
        if (binding.initializer != null) {
          _write('this.${binding.name} = ${binding.initializer}');
        } else {
          _write('required this.${binding.name}');
        }
        paramIndex++;
        if (paramIndex < analysis.propBindings.length + analysis.stateBindings.length) {
          _write(', ');
        }
      }
      
      // Add state parameters (treated as props with default values)
      for (var i = 0; i < analysis.stateBindings.length; i++) {
        final binding = analysis.stateBindings[i];
        final defaultValue = binding.initializer ?? '0';
        _write('this.${binding.name} = $defaultValue');
        paramIndex++;
        if (paramIndex < analysis.propBindings.length + analysis.stateBindings.length) {
          _write(', ');
        }
      }
      
      _write('})');
      
      if (hasDerived) {
        _write(' {');
        _output.writeln();
        _indent++;
        _generateDerivedInitializations();
        _indent--;
        _writeLine('}');
      } else {
        _write(';');
        _output.writeln();
      }
    } else {
      if (hasDerived) {
        _writeLine('$className() {');
        _indent++;
        _generateDerivedInitializations();
        _indent--;
        _writeLine('}');
      } else {
        _writeLine('$className();');
      }
    }
    _writeLine();
  }

  /// Generate derived value initializations
  void _generateDerivedInitializations() {
    if (ast.script == null) return;
    
    final content = ast.script!.content;
    
    // Parse $derived declarations
    final derivedPattern = RegExp(
      r'(?:final|late)\s+[A-Za-z_]\w*(?:<[^>]+>)?\s+(\w+)\s*=\s*\$derived\s*\(',
      multiLine: true,
    );

    for (final match in derivedPattern.allMatches(content)) {
      final varName = match.group(1)!;
      final startPos = match.end; // Position after '$derived('

      // Find the matching closing paren by counting
      var parenCount = 1;
      var inString = false;
      var stringChar = '';
      var i = startPos;

      while (i < content.length && parenCount > 0) {
        final char = content[i];

        // Handle strings
        if (!inString && (char == '"' || char == "'")) {
          inString = true;
          stringChar = char;
        } else if (inString &&
            char == stringChar &&
            (i == 0 || content[i - 1] != '\\')) {
          inString = false;
        }

        if (!inString) {
          if (char == '(') parenCount++;
          if (char == ')') parenCount--;
        }

        i++;
      }

      if (parenCount == 0) {
        final derivedBody = content.substring(startPos, i - 1);
        // Extract the expression from the arrow function
        // For () => expr, we want just expr
        // For () { return expr; }, we want expr
        String expression = derivedBody.trim();
        
        if (expression.startsWith('()')) {
          expression = expression.substring(2).trim();
          
          if (expression.startsWith('=>')) {
            // Arrow function: () => expr
            expression = expression.substring(2).trim();
          } else if (expression.startsWith('{')) {
            // Block function: () { ... }
            // For simplicity, try to extract return statement
            final returnMatch = RegExp(r'return\s+(.+?);').firstMatch(expression);
            if (returnMatch != null) {
              expression = returnMatch.group(1)!.trim();
            }
          }
        }
        
        _writeLine('$varName = $expression;');
      }
    }
  }

  /// Generate build method
  void _generateBuildMethod() {
    _writeLine('void build(StringBuffer buffer) {');
    _indent++;
    
    // Generate HTML from template
    _generateFragment(ast.fragment);
    
    _indent--;
    _writeLine('}');
  }

  /// Generate code for a fragment
  void _generateFragment(FragmentNode fragment) {
    for (final node in fragment.nodes) {
      _generateTemplateNode(node);
    }
  }

  /// Generate code for a template node
  void _generateTemplateNode(TemplateNode node) {
    switch (node) {
      case TextNode():
        _generateTextNode(node);
      case ExpressionTagNode():
        _generateExpressionTag(node);
      case HtmlTagNode():
        _generateHtmlTag(node);
      case ElementNode():
        _generateElement(node);
      case IfBlockNode():
        _generateIfBlock(node);
      case EachBlockNode():
        _generateEachBlock(node);
      case AwaitBlockNode():
        // Await blocks are not supported in static generation
        _writeLine('// Await blocks are not supported in static generation');
      case SnippetBlockNode():
        _generateSnippetBlock(node);
      case RenderTagNode():
        _generateRenderTag(node);
      default:
        break;
    }
  }

  /// Generate snippet block
  void _generateSnippetBlock(SnippetBlockNode node) {
    _writeLine('dynamic ${node.name}(${node.parameters}) {');
    _indent++;
    _writeLine('return (StringBuffer buffer) {');
    _indent++;

    for (final child in node.body) {
      _generateTemplateNode(child);
    }

    _indent--;
    _writeLine('};');
    _indent--;
    _writeLine('}');
    _writeLine();
  }

  /// Generate render tag
  void _generateRenderTag(RenderTagNode node) {
    _writeLine('(${node.expression})?.call(buffer);');
  }

  /// Generate text node
  void _generateTextNode(TextNode node) {
    if (node.data.trim().isEmpty) return;
    _writeLine('buffer.write("${_escapeString(node.data)}");');
  }

  /// Generate expression tag
  void _generateExpressionTag(ExpressionTagNode node) {
    _writeLine('buffer.write(${node.expression});');
  }

  /// Generate HTML tag
  void _generateHtmlTag(HtmlTagNode node) {
    _writeLine('buffer.write(${node.expression});');
  }

  /// Generate element
  void _generateElement(ElementNode node) {
    if (node.isComponent) {
      _generateComponent(node);
    } else {
      _generateHtmlElement(node);
    }
  }

  /// Generate HTML element
  void _generateHtmlElement(ElementNode node) {
    // Opening tag
    _writeLine('buffer.write("<${node.name}");');

    // Generate attributes
    for (final attr in node.attributes) {
      _generateAttribute(attr);
    }

    _writeLine('buffer.write(">");');

    // Generate children
    for (final child in node.children) {
      _generateTemplateNode(child);
    }

    // Closing tag
    _writeLine('buffer.write("</${node.name}>");');
  }

  /// Generate component
  void _generateComponent(ElementNode node) {
    final componentClass = _capitalize(node.name);
    
    // Build props map from attributes
    final propParams = <String>[];
    for (final attr in node.attributes) {
      if (attr is RegularAttribute) {
        // Handle prop passing
        if (attr.value.isEmpty) {
          // Boolean prop (just presence)
          propParams.add('${attr.name}: true');
        } else if (attr.value.length == 1 && attr.value.first is ExpressionAttributeValue) {
          // Expression value
          final expr = (attr.value.first as ExpressionAttributeValue).expression;
          propParams.add('${attr.name}: $expr');
        } else if (attr.value.every((v) => v is TextAttributeValue)) {
          // Pure static text
          final text = attr.value.whereType<TextAttributeValue>().map((v) => v.text).join();
          propParams.add('${attr.name}: "${_escapeString(text)}"');
        } else {
          // Mixed text and expressions - use string interpolation
          final parts = <String>[];
          for (final value in attr.value) {
            if (value is TextAttributeValue) {
              parts.add(_escapeString(value.text));
            } else if (value is ExpressionAttributeValue) {
              parts.add('\${${value.expression}}');
            }
          }
          propParams.add('${attr.name}: "${parts.join()}"');
        }
      }
    }
    
    // Create component instance and render
    if (propParams.isEmpty) {
      _writeLine('$componentClass().build(buffer);');
    } else {
      _write('$componentClass(');
      for (var i = 0; i < propParams.length; i++) {
        final param = propParams[i];
        _write(param);
        if (i < propParams.length - 1) {
          _write(', ');
        }
      }
      _write(').build(buffer);');
      _output.writeln();
    }
  }

  /// Generate attribute
  void _generateAttribute(AttributeNode attr) {
    switch (attr) {
      case RegularAttribute():
        _generateRegularAttribute(attr);
      case SpreadAttribute():
        // Spread attributes not supported in static generation
        _writeLine('// Spread attributes are not supported in static generation');
      case EventAttribute():
        // Event attributes not supported in static generation
        break;
      case BindDirective():
        // Bind directives not supported in static generation
        break;
    }
  }

  /// Generate regular attribute
  void _generateRegularAttribute(RegularAttribute attr) {
    if (attr.value.isEmpty) {
      _writeLine('buffer.write(" ${attr.name}");');
      return;
    }

    // Check if attribute contains expressions
    final hasExpression = attr.value.any((v) => v is ExpressionAttributeValue);

    if (hasExpression) {
      // Build attribute value from mixed content
      _write('buffer.write(" ${attr.name}=\\"");');
      _output.writeln();
      
      for (final value in attr.value) {
        if (value is TextAttributeValue) {
          _writeLine('buffer.write("${_escapeString(value.text)}");');
        } else if (value is ExpressionAttributeValue) {
          _writeLine('buffer.write(${value.expression});');
        }
      }
      
      _writeLine('buffer.write("\\"");');
    } else {
      // Static attribute
      final text =
          attr.value.whereType<TextAttributeValue>().map((v) => v.text).join();
      _writeLine('buffer.write(" ${attr.name}=\\"${_escapeString(text)}\\"");');
    }
  }

  /// Generate if block
  void _generateIfBlock(IfBlockNode node) {
    _writeLine('if (${node.condition}) {');
    _indent++;

    for (final child in node.consequent) {
      _generateTemplateNode(child);
    }

    _indent--;
    _writeLine('}');

    if (node.alternate != null && node.alternate!.isNotEmpty) {
      _writeLine('else {');
      _indent++;

      for (final child in node.alternate!) {
        _generateTemplateNode(child);
      }

      _indent--;
      _writeLine('}');
    }
  }

  /// Generate each block
  void _generateEachBlock(EachBlockNode node) {
    final indexName = node.indexName ?? 'index';
    _writeLine(
        'for (var $indexName = 0; $indexName < ${node.expression}.length; $indexName++) {');
    _indent++;
    _writeLine('final ${node.itemName} = ${node.expression}[$indexName];');

    for (final child in node.body) {
      _generateTemplateNode(child);
    }

    _indent--;
    _writeLine('}');
  }

  /// Capitalize first letter
  String _capitalize(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1);
  }

  /// Escape string for Dart and HTML
  String _escapeString(String str) {
    return str
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }

  /// Write a line with proper indentation
  void _writeLine([String line = '']) {
    if (line.isEmpty) {
      _output.writeln();
    } else {
      _output.writeln('${'  ' * _indent}$line');
    }
  }

  /// Write text without a newline
  void _write(String text) {
    if (_output.isEmpty || _output.toString().endsWith('\n')) {
      _output.write('${'  ' * _indent}$text');
    } else {
      _output.write(text);
    }
  }
}
