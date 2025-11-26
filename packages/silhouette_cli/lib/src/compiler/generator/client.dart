/// Code generator for Silhouette components
///
/// Generates Dart code using package:web APIs
library;

import '../ast.dart';
import '../analyzer.dart';

class ClientCodeGenerator {
  final RootNode ast;
  final AnalysisResult analysis;
  final StringBuffer _output = StringBuffer();
  int _indent = 0;
  int _tempVarCounter = 0;
  final Map<String, String> _elementVars = {};

  ClientCodeGenerator(this.ast, this.analysis);

  /// Generate Dart code
  String generate() {
    _output.clear();

    // Generate imports
    _writeLine("import 'dart:js_interop';");
    _writeLine("import 'package:web/web.dart';");
    _writeLine("import 'package:silhouette_cli/src/runtime/runtime.dart';");
    _writeLine();

    // Generate class
    final className = 'Component';
    _writeLine('class $className {');
    _indent++;

    // Generate state fields
    _generateStateFields();

    // Generate derived fields
    _generateDerivedFields();

    // Generate element field
    _writeLine('late final HTMLElement root;');
    _writeLine();

    // Generate constructor
    _generateConstructor(className);

    // Generate user methods
    _generateUserMethods();

    // Generate mount method
    _generateMountMethod();

    // Generate destroy method
    _generateDestroyMethod();

    _indent--;
    _writeLine('}');

    return _output.toString();
  }

  /// Generate state fields
  void _generateStateFields() {
    for (final binding in analysis.stateBindings) {
      _writeLine('late final State<dynamic> _${binding.name};');

      // Generate getter
      _writeLine('get ${binding.name} => _${binding.name}.value;');

      // Generate setter
      _writeLine(
          'set ${binding.name}(value) => _${binding.name}.value = value;');
      _writeLine();
    }
  }

  /// Generate derived fields
  void _generateDerivedFields() {
    for (final binding in analysis.derivedBindings) {
      _writeLine('late final Derived<dynamic> _${binding.name};');

      // Generate getter
      _writeLine('get ${binding.name} => _${binding.name}.value;');
      _writeLine();
    }
  }

  /// Generate constructor
  void _generateConstructor(String className) {
    _writeLine('$className() {');
    _indent++;

    // Initialize state and derived values from script
    if (ast.script != null) {
      _generateVariableInitializations(ast.script!);
    }

    // Run script content (effects, etc.)
    if (ast.script != null) {
      _generateScriptEffects(ast.script!);
    }

    _indent--;
    _writeLine('}');
    _writeLine();
  }

  /// Generate variable initializations from script
  void _generateVariableInitializations(ScriptNode script) {
    final content = script.content;

    // Simple approach: use regex to match complete rune declarations
    // For state: var name = state(value);
    final statePattern = RegExp(
      r'(?:var|final|late)\s+(\w+)\s*=\s*state\s*\(([^)]*)\)\s*;',
      multiLine: true,
    );

    final stateMatches = statePattern.allMatches(content);
    for (final match in stateMatches) {
      final varName = match.group(1)!;
      final init = match.group(2)!;
      _writeLine('_$varName = state($init);');
    }

    // For derived: need to handle both arrow functions and block functions
    // Use manual parsing to find derived declarations
    final derivedPattern = RegExp(
      r'(?:var|final|late)\s+(\w+)\s*=\s*derived\s*\(',
      multiLine: true,
    );

    for (final match in derivedPattern.allMatches(content)) {
      final varName = match.group(1)!;
      final startPos = match.end; // Position after 'derived('

      // Find the matching closing paren by counting
      var parenCount = 1;
      var braceCount = 0;
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
          if (char == '{') braceCount++;
          if (char == '}') braceCount--;
        }

        i++;
      }

      if (parenCount == 0) {
        final derivedBody = content.substring(startPos, i - 1);
        _writeLine('_$varName = derived($derivedBody);');
      }
    }

    // For props: var name = props();
    final propsPattern = RegExp(
      r'(?:var|final|late)\s+(\w+)\s*=\s*props\s*\(\s*\)\s*;',
      multiLine: true,
    );

    final propsMatches = propsPattern.allMatches(content);
    for (final match in propsMatches) {
      final varName = match.group(1)!;
      _writeLine('_$varName = props();');
    }
  }

  /// Generate script effects
  void _generateScriptEffects(ScriptNode script) {
    // Extract and generate effect calls - use simpler regex-based approach
    final content = script.content;
    final effectPattern = RegExp(
      r'effect\s*\(\s*\(\s*\)\s*\{[^}]*\}\s*\)\s*;',
      multiLine: true,
      dotAll: true,
    );

    final matches = effectPattern.allMatches(content);
    for (final match in matches) {
      _writeLine(match.group(0)!);
    }
  }

  /// Generate user-defined methods
  void _generateUserMethods() {
    if (ast.script == null) return;

    final content = ast.script!.content;
    // Extract method definitions (void/return type followed by name and parens)
    final methodPattern = RegExp(
      r'(?:void|int|String|bool|double|dynamic|Future<[^>]+>|[A-Z]\w*)\s+(\w+)\s*\([^)]*\)\s*\{[^}]*\}',
      multiLine: true,
      dotAll: true,
    );

    final matches = methodPattern.allMatches(content);
    for (final match in matches) {
      _writeLine(match.group(0)!);
      _writeLine();
    }
  }

  /// Generate mount method
  void _generateMountMethod() {
    _writeLine('void mount(HTMLElement target) {');
    _indent++;

    _writeLine("root = document.createElement('div') as HTMLElement;");
    _writeLine();

    // Generate template
    _generateFragment(ast.fragment, 'root');

    _writeLine();
    _writeLine('target.appendChild(root);');

    _indent--;
    _writeLine('}');
    _writeLine();
  }

  /// Generate destroy method
  void _generateDestroyMethod() {
    _writeLine('void destroy() {');
    _indent++;
    _writeLine('root.remove();');
    _indent--;
    _writeLine('}');
  }

  /// Generate code for a fragment
  void _generateFragment(FragmentNode fragment, String parent) {
    for (final node in fragment.nodes) {
      _generateTemplateNode(node, parent);
    }
  }

  /// Generate code for a template node
  void _generateTemplateNode(TemplateNode node, String parent) {
    switch (node) {
      case TextNode():
        _generateTextNode(node, parent);
      case ExpressionTagNode():
        _generateExpressionTag(node, parent);
      case HtmlTagNode():
        _generateHtmlTag(node, parent);
      case ElementNode():
        _generateElement(node, parent);
      case IfBlockNode():
        _generateIfBlock(node, parent);
      case EachBlockNode():
        _generateEachBlock(node, parent);
      case AwaitBlockNode():
        _generateAwaitBlock(node, parent);
      default:
        break;
    }
  }

  /// Generate text node
  void _generateTextNode(TextNode node, String parent) {
    if (node.data.trim().isEmpty) return;

    final textVar = _tempVar('text');
    _writeLine(
        'final $textVar = document.createTextNode("${_escapeString(node.data)}");');
    _writeLine('$parent.appendChild($textVar);');
  }

  /// Generate expression tag
  void _generateExpressionTag(ExpressionTagNode node, String parent) {
    final textVar = _tempVar('text');
    _writeLine('final $textVar = document.createTextNode("");');
    _writeLine('$parent.appendChild($textVar);');

    // Create effect to update text
    _writeLine('effect(() {');
    _indent++;
    _writeLine('$textVar.textContent = "\${${node.expression}}";');
    _indent--;
    _writeLine('});');
  }

  /// Generate HTML tag
  void _generateHtmlTag(HtmlTagNode node, String parent) {
    final spanVar = _tempVar('html');
    _writeLine("final $spanVar = document.createElement('span');");
    _writeLine('$parent.appendChild($spanVar);');

    // Create effect to update innerHTML
    _writeLine('effect(() {');
    _indent++;
    _writeLine('$spanVar.innerHTML = ${node.expression};');
    _indent--;
    _writeLine('});');
  }

  /// Generate element
  void _generateElement(ElementNode node, String parent) {
    final elemVar = _tempVar(node.name);
    _elementVars[node.name] = elemVar;

    _writeLine("final $elemVar = document.createElement('${node.name}');");

    // Generate attributes
    for (final attr in node.attributes) {
      _generateAttribute(attr, elemVar);
    }

    // Generate children
    for (final child in node.children) {
      _generateTemplateNode(child, elemVar);
    }

    _writeLine('$parent.appendChild($elemVar);');
  }

  /// Generate attribute
  void _generateAttribute(AttributeNode attr, String element) {
    switch (attr) {
      case RegularAttribute():
        _generateRegularAttribute(attr, element);
      case SpreadAttribute():
        _generateSpreadAttribute(attr, element);
      case EventAttribute():
        _generateEventAttribute(attr, element);
      case BindDirective():
        _generateBindDirective(attr, element);
    }
  }

  /// Generate regular attribute
  void _generateRegularAttribute(RegularAttribute attr, String element) {
    if (attr.value.isEmpty) {
      _writeLine('$element.setAttribute("${attr.name}", "");');
      return;
    }

    // Check if attribute contains expressions
    final hasExpression = attr.value.any((v) => v is ExpressionAttributeValue);

    if (hasExpression) {
      // Create effect to update attribute
      _writeLine('effect(() {');
      _indent++;

      final parts = <String>[];
      for (final value in attr.value) {
        if (value is TextAttributeValue) {
          parts.add('"${_escapeString(value.text)}"');
        } else if (value is ExpressionAttributeValue) {
          parts.add('\${${value.expression}}');
        }
      }

      _writeLine('$element.setAttribute("${attr.name}", "${parts.join()}");');
      _indent--;
      _writeLine('});');
    } else {
      // Static attribute
      final text =
          attr.value.whereType<TextAttributeValue>().map((v) => v.text).join();
      _writeLine(
          '$element.setAttribute("${attr.name}", "${_escapeString(text)}");');
    }
  }

  /// Generate spread attribute
  void _generateSpreadAttribute(SpreadAttribute attr, String element) {
    _writeLine('// TODO: Spread attributes not yet implemented');
  }

  /// Generate event attribute
  void _generateEventAttribute(EventAttribute attr, String element) {
    if (attr.handler != null) {
      _writeLine("$element.addEventListener('${attr.event}', (Event event) {");
      _indent++;

      final handler = attr.handler!.trim();

      // Check if handler is a lambda expression: () => expression
      if (handler.startsWith('()') && handler.contains('=>')) {
        // Extract the expression after =>
        final arrowIndex = handler.indexOf('=>');
        final expression = handler.substring(arrowIndex + 2).trim();
        _writeLine('$expression;');
      }
      // Check if handler is just a function name
      else if (RegExp(r'^[a-zA-Z_]\w*$').hasMatch(handler)) {
        // Simple function name, call it
        _writeLine('$handler();');
      }
      // Otherwise treat as expression
      else {
        _writeLine('$handler;');
      }

      _indent--;
      _writeLine('}.toJS);');
    }
  }

  /// Generate bind directive
  void _generateBindDirective(BindDirective attr, String element) {
    // Two-way binding
    if (attr.property == 'value') {
      // Update element when state changes
      _writeLine('effect(() {');
      _indent++;
      _writeLine('if ($element.isA<HTMLInputElement>()) {');
      _indent++;
      _writeLine(
          '($element as HTMLInputElement).value = ${attr.value}.toString();');
      _indent--;
      _writeLine('}');
      _indent--;
      _writeLine('});');

      // Update state when element changes
      _writeLine("$element.addEventListener('input', (Event event) {");
      _indent++;
      _writeLine('if ($element.isA<HTMLInputElement>()) {');
      _indent++;
      _writeLine('${attr.value} = ($element as HTMLInputElement).value;');
      _indent--;
      _writeLine('}');
      _indent--;
      _writeLine('}.toJS);');
    }
  }

  /// Generate if block
  void _generateIfBlock(IfBlockNode node, String parent) {
    final containerVar = _tempVar('if');
    _writeLine("final $containerVar = document.createElement('span');");
    _writeLine('$parent.appendChild($containerVar);');

    _writeLine('effect(() {');
    _indent++;
    _writeLine('while ($containerVar.firstChild != null) {');
    _indent++;
    _writeLine('$containerVar.removeChild($containerVar.firstChild!);');
    _indent--;
    _writeLine('}');
    _writeLine('if (${node.condition}) {');
    _indent++;

    for (final child in node.consequent) {
      _generateTemplateNode(child, containerVar);
    }

    _indent--;
    _writeLine('}');

    if (node.alternate != null && node.alternate!.isNotEmpty) {
      _writeLine('else {');
      _indent++;

      for (final child in node.alternate!) {
        _generateTemplateNode(child, containerVar);
      }

      _indent--;
      _writeLine('}');
    }

    _indent--;
    _writeLine('});');
  }

  /// Generate each block
  void _generateEachBlock(EachBlockNode node, String parent) {
    final containerVar = _tempVar('each');
    _writeLine("final $containerVar = document.createElement('span');");
    _writeLine('$parent.appendChild($containerVar);');

    _writeLine('effect(() {');
    _indent++;
    _writeLine('while ($containerVar.firstChild != null) {');
    _indent++;
    _writeLine('$containerVar.removeChild($containerVar.firstChild!);');
    _indent--;
    _writeLine('}');

    final indexName = node.indexName ?? 'index';
    _writeLine(
        'for (var $indexName = 0; $indexName < ${node.expression}.length; $indexName++) {');
    _indent++;
    _writeLine('final ${node.itemName} = ${node.expression}[$indexName];');

    for (final child in node.body) {
      _generateTemplateNode(child, containerVar);
    }

    _indent--;
    _writeLine('}');
    _indent--;
    _writeLine('});');
  }

  /// Generate await block
  void _generateAwaitBlock(AwaitBlockNode node, String parent) {
    final containerVar = _tempVar('await');
    _writeLine("final $containerVar = document.createElement('span');");
    _writeLine('$parent.appendChild($containerVar);');

    // Show pending state
    if (node.pending != null) {
      for (final child in node.pending!) {
        _generateTemplateNode(child, containerVar);
      }
    }

    // Handle promise resolution
    _writeLine('${node.expression}.then((${node.thenVariable ?? "value"}) {');
    _indent++;
    _writeLine('while ($containerVar.firstChild != null) {');
    _indent++;
    _writeLine('$containerVar.removeChild($containerVar.firstChild!);');
    _indent--;
    _writeLine('}');

    if (node.then != null) {
      for (final child in node.then!) {
        _generateTemplateNode(child, containerVar);
      }
    }

    _indent--;
    _writeLine('}).catchError((${node.catchVariable ?? "error"}) {');
    _indent++;
    _writeLine('while ($containerVar.firstChild != null) {');
    _indent++;
    _writeLine('$containerVar.removeChild($containerVar.firstChild!);');
    _indent--;
    _writeLine('}');

    if (node.catchBlock != null) {
      for (final child in node.catchBlock!) {
        _generateTemplateNode(child, containerVar);
      }
    }

    _indent--;
    _writeLine('});');
  }

  /// Generate a temporary variable name
  String _tempVar(String prefix) {
    return '_${prefix}_${_tempVarCounter++}';
  }

  /// Capitalize first letter
  String _capitalize(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1);
  }

  /// Escape string for Dart
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
}
