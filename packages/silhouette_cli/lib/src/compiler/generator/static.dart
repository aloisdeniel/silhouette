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

    // Generate user imports
    for (final import in analysis.imports) {
      if (import.alias != null) {
        _writeLine("import '${import.uri}' as ${import.alias};");
      } else {
        _writeLine("import '${import.uri}';");
      }
    }
    if (analysis.imports.isNotEmpty) {
      _writeLine();
    }

    // Generate class
    final className = componentName;
    _writeLine('class $className {');
    _indent++;

    // Generate property fields (only props are supported)
    _generatePropertyFields();

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

  /// Generate constructor
  void _generateConstructor(String className) {
    // Generate constructor with named parameters for properties
    final hasProps = analysis.propBindings.isNotEmpty;

    if (hasProps) {
      _write('$className({');
      for (var i = 0; i < analysis.propBindings.length; i++) {
        final binding = analysis.propBindings[i];
        if (binding.initializer != null) {
          _write('this.${binding.name} = ${binding.initializer}');
        } else {
          _write('required this.${binding.name}');
        }
        if (i < analysis.propBindings.length - 1) {
          _write(', ');
        }
      }
      _write('});');
      _output.writeln();
    } else {
      _writeLine('$className();');
    }
    _writeLine();
  }

  /// Generate build method
  void _generateBuildMethod() {
    _writeLine('String build() {');
    _indent++;
    
    _writeLine('final buffer = StringBuffer();');
    
    // Generate HTML from template
    _generateFragment(ast.fragment);
    
    _writeLine('return buffer.toString();');
    
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
      default:
        break;
    }
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
      _writeLine('buffer.write($componentClass().build());');
    } else {
      _write('buffer.write($componentClass(');
      for (var i = 0; i < propParams.length; i++) {
        final param = propParams[i];
        _write(param);
        if (i < propParams.length - 1) {
          _write(', ');
        }
      }
      _write(').build());');
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
      final text = attr.value.whereType<TextAttributeValue>().map((v) => v.text).join();
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
    _writeLine('for (var $indexName = 0; $indexName < ${node.expression}.length; $indexName++) {');
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
