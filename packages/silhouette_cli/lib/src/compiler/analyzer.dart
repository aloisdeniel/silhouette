/// Analyzer for Silhouette components
///
/// Analyzes the AST to detect runes, build scope tree, and track dependencies
library;

import 'ast.dart';

/// Types of runes
enum RuneType {
  state,      // state(initial)
  derived,    // derived(() => expr)
  effect,     // effect(() => { ... })
  props,      // props()
}

/// Binding kinds
enum BindingKind {
  normal,
  state,
  derived,
  prop,
  each,
}

/// A variable binding
class Binding {
  final String name;
  final BindingKind kind;
  final String? initializer;
  final String? type;
  final List<String> references = [];
  final List<String> assignments = [];
  bool reassigned = false;
  bool mutated = false;

  Binding({
    required this.name,
    required this.kind,
    this.initializer,
    this.type,
  });
}

/// A scope
class Scope {
  final Scope? parent;
  final Map<String, Binding> declarations = {};
  final List<Scope> children = [];

  Scope({this.parent});

  /// Add a declaration to this scope
  void declare(String name, Binding binding) {
    declarations[name] = binding;
  }

  /// Lookup a binding in this scope or parent scopes
  Binding? lookup(String name) {
    final binding = declarations[name];
    if (binding != null) return binding;
    return parent?.lookup(name);
  }

  /// Create a child scope
  Scope createChild() {
    final child = Scope(parent: this);
    children.add(child);
    return child;
  }
}

/// Import declaration
class ImportDeclaration {
  final String uri;
  final String? alias;
  final List<String> symbols;

  ImportDeclaration({
    required this.uri,
    this.alias,
    this.symbols = const [],
  });
}

/// Analysis result
class AnalysisResult {
  final Scope rootScope;
  final List<Binding> stateBindings;
  final List<Binding> derivedBindings;
  final List<Binding> propBindings;
  final Set<String> dependencies;
  final List<ImportDeclaration> imports;

  AnalysisResult({
    required this.rootScope,
    required this.stateBindings,
    required this.derivedBindings,
    required this.propBindings,
    required this.dependencies,
    required this.imports,
  });
}

/// Analyzer
class Analyzer {
  final RootNode ast;
  late Scope _currentScope;
  final List<Binding> _stateBindings = [];
  final List<Binding> _derivedBindings = [];
  final List<Binding> _propBindings = [];
  final Set<String> _dependencies = {};
  final List<ImportDeclaration> _imports = [];

  Analyzer(this.ast);

  /// Analyze the AST
  AnalysisResult analyze() {
    _currentScope = Scope();

    // Analyze scripts
    if (ast.moduleScript != null) {
      _analyzeScript(ast.moduleScript!);
    }
    if (ast.script != null) {
      _analyzeScript(ast.script!);
    }

    // Analyze template to find dependencies
    _analyzeFragment(ast.fragment);

    return AnalysisResult(
      rootScope: _currentScope,
      stateBindings: _stateBindings,
      derivedBindings: _derivedBindings,
      propBindings: _propBindings,
      dependencies: _dependencies,
      imports: _imports,
    );
  }

  /// Analyze a script block
  void _analyzeScript(ScriptNode script) {
    // Simple Dart code analysis
    // We look for rune patterns like:
    // var name = state(value);
    // var name = derived(() => expr);
    // effect(() { ... });
    // final (...) = $props();

    // First, check for $props() declarations which can span multiple lines
    _analyzePropsDeclarations(script.content);

    final lines = script.content.split('\n');
    for (final line in lines) {
      _analyzeLine(line.trim());
    }
  }

  /// Analyze $props() declarations from the full script content
  void _analyzePropsDeclarations(String content) {
    // Detect property declarations with $props() destructuring syntax
    // Pattern: final (:Type name = defaultValue, :Type name2, ...) = $props();
    final propsPattern = RegExp(
      r'final\s+\(\s*([^)]+)\s*\)\s*=\s*\$props\s*\(\s*\)\s*;',
      multiLine: true,
      dotAll: true,
    );
    
    final propsMatches = propsPattern.allMatches(content);
    for (final match in propsMatches) {
      final propsContent = match.group(1)!;
      
      // Parse each property from the record destructuring
      // Pattern: :Type name or :Type name = defaultValue
      final propPattern = RegExp(r':([A-Za-z_]\w*(?:<[^>]+>)?)\s+(\w+)(?:\s*=\s*([^,]+))?');
      final propMatches = propPattern.allMatches(propsContent);
      
      for (final propMatch in propMatches) {
        final type = propMatch.group(1)!;
        final name = propMatch.group(2)!;
        var defaultValue = propMatch.group(3)?.trim();
        
        // Clean up default value - remove trailing comma
        if (defaultValue != null && defaultValue.endsWith(',')) {
          defaultValue = defaultValue.substring(0, defaultValue.length - 1).trim();
        }
        
        final binding = Binding(
          name: name,
          kind: BindingKind.prop,
          initializer: defaultValue,
          type: type,
        );
        _propBindings.add(binding);
        _currentScope.declare(name, binding);
      }
    }
  }

  /// Analyze a single line of Dart code
  void _analyzeLine(String line) {
    // Skip comments
    if (line.startsWith('//') || line.isEmpty) return;

    // Detect import statements
    // Pattern: import 'path/to/file.g.dart' as Alias;
    // Or: import 'path/to/file.g.dart';
    final importMatch = RegExp(r'''import\s+['"]([^'"]+)['"]\s*(?:as\s+(\w+))?\s*;''').firstMatch(line);
    if (importMatch != null) {
      final uri = importMatch.group(1)!;
      final alias = importMatch.group(2);
      
      _imports.add(ImportDeclaration(
        uri: uri,
        alias: alias,
      ));
      
      // If there's an alias, add it to scope so we can reference it
      if (alias != null) {
        _currentScope.declare(alias, Binding(
          name: alias,
          kind: BindingKind.normal,
        ));
      }
      
      // Extract component name from path (e.g., 'button.g.dart' -> 'Button')
      final fileName = uri.split('/').last;
      if (fileName.endsWith('.g.dart')) {
        final componentName = _capitalize(fileName.replaceAll('.g.dart', ''));
        _currentScope.declare(componentName, Binding(
          name: componentName,
          kind: BindingKind.normal,
        ));
      }
      return;
    }

    // Note: $props() declarations are now handled in _analyzePropsDeclarations()
    // which processes the full script content to handle multi-line declarations

    // Detect variable declarations with runes (only $state/$derived/$effect)
    // Now requires explicit type: final <Type> name = $state(...)
    final varMatch = RegExp(r'(?:final|late)\s+([A-Za-z_]\w*(?:<[^>]+>)?)\s+(\w+)\s*=\s*(\$\w+)\((.*)\)').firstMatch(line);
    if (varMatch != null) {
      final type = varMatch.group(1)!;
      final name = varMatch.group(2)!;
      final runeName = varMatch.group(3)!;
      final args = varMatch.group(4)!;

      final runeType = _detectRuneType(runeName);
      if (runeType != null) {
        final binding = _createBindingForRune(name, runeType, args, type);
        _currentScope.declare(name, binding);
      } else {
        // Normal variable
        _currentScope.declare(name, Binding(
          name: name,
          kind: BindingKind.normal,
          initializer: args,
          type: type,
        ));
      }
      return;
    }

    // Detect standalone effect calls (only $effect)
    if (line.startsWith(r'$effect(')) {
      // Effects don't create bindings, they just run
      return;
    }

    // Detect assignments
    final assignMatch = RegExp(r'(\w+)\s*=\s*(.*)').firstMatch(line);
    if (assignMatch != null) {
      final name = assignMatch.group(1)!;
      final binding = _currentScope.lookup(name);
      if (binding != null) {
        binding.reassigned = true;
        binding.assignments.add(assignMatch.group(2)!);
      }
    }

    // Track identifier references
    final identifiers = RegExp(r'\b([a-zA-Z_]\w*)\b').allMatches(line);
    for (final match in identifiers) {
      final identifier = match.group(1)!;
      if (!_isKeyword(identifier)) {
        final binding = _currentScope.lookup(identifier);
        if (binding != null) {
          binding.references.add(line);
          _dependencies.add(identifier);
        }
      }
    }
  }

  /// Detect rune type from function name
  RuneType? _detectRuneType(String name) {
    return switch (name) {
      r'$state' => RuneType.state,
      r'$derived' => RuneType.derived,
      r'$effect' => RuneType.effect,
      'props' => RuneType.props,
      _ => null,
    };
  }

  /// Create a binding for a rune
  Binding _createBindingForRune(String name, RuneType rune, String initializer, [String? type]) {
    final binding = switch (rune) {
      RuneType.state => Binding(
          name: name,
          kind: BindingKind.state,
          initializer: initializer,
          type: type,
        ),
      RuneType.derived => Binding(
          name: name,
          kind: BindingKind.derived,
          initializer: initializer,
          type: type,
        ),
      RuneType.props => Binding(
          name: name,
          kind: BindingKind.prop,
          initializer: initializer,
          type: type,
        ),
      RuneType.effect => Binding(
          name: name,
          kind: BindingKind.normal,
          initializer: initializer,
          type: type,
        ),
    };

    switch (rune) {
      case RuneType.state:
        _stateBindings.add(binding);
        break;
      case RuneType.derived:
        _derivedBindings.add(binding);
        break;
      case RuneType.props:
        _propBindings.add(binding);
        break;
      case RuneType.effect:
        break;
    }

    return binding;
  }

  /// Analyze a fragment to find dependencies
  void _analyzeFragment(FragmentNode fragment) {
    for (final node in fragment.nodes) {
      _analyzeTemplateNode(node);
    }
  }

  /// Analyze a template node
  void _analyzeTemplateNode(TemplateNode node) {
    switch (node) {
      case ExpressionTagNode():
        _extractDependencies(node.expression);
      case HtmlTagNode():
        _extractDependencies(node.expression);
      case ElementNode():
        for (final attr in node.attributes) {
          _analyzeAttribute(attr);
        }
        for (final child in node.children) {
          _analyzeTemplateNode(child);
        }
      case IfBlockNode():
        _extractDependencies(node.condition);
        for (final child in node.consequent) {
          _analyzeTemplateNode(child);
        }
        if (node.alternate != null) {
          for (final child in node.alternate!) {
            _analyzeTemplateNode(child);
          }
        }
      case EachBlockNode():
        _extractDependencies(node.expression);
        if (node.keyExpression != null) {
          _extractDependencies(node.keyExpression!);
        }
        // Create child scope for each block
        final previousScope = _currentScope;
        _currentScope = _currentScope.createChild();
        _currentScope.declare(node.itemName, Binding(
          name: node.itemName,
          kind: BindingKind.each,
        ));
        if (node.indexName != null) {
          _currentScope.declare(node.indexName!, Binding(
            name: node.indexName!,
            kind: BindingKind.each,
          ));
        }
        for (final child in node.body) {
          _analyzeTemplateNode(child);
        }
        _currentScope = previousScope;
      case AwaitBlockNode():
        _extractDependencies(node.expression);
        if (node.pending != null) {
          for (final child in node.pending!) {
            _analyzeTemplateNode(child);
          }
        }
        if (node.then != null) {
          for (final child in node.then!) {
            _analyzeTemplateNode(child);
          }
        }
        if (node.catchBlock != null) {
          for (final child in node.catchBlock!) {
            _analyzeTemplateNode(child);
          }
        }
      default:
        break;
    }
  }

  /// Analyze an attribute
  void _analyzeAttribute(AttributeNode attr) {
    switch (attr) {
      case RegularAttribute():
        for (final value in attr.value) {
          if (value is ExpressionAttributeValue) {
            _extractDependencies(value.expression);
          }
        }
      case SpreadAttribute():
        _extractDependencies(attr.expression);
      case EventAttribute():
        if (attr.handler != null) {
          _extractDependencies(attr.handler!);
        }
      case BindDirective():
        _extractDependencies(attr.value);
    }
  }

  /// Extract dependencies from an expression
  void _extractDependencies(String expression) {
    final identifiers = RegExp(r'\b([a-zA-Z_]\w*)\b').allMatches(expression);
    for (final match in identifiers) {
      final identifier = match.group(1)!;
      if (!_isKeyword(identifier)) {
        final binding = _currentScope.lookup(identifier);
        if (binding != null) {
          _dependencies.add(identifier);
        }
      }
    }
  }

  /// Check if a word is a Dart keyword
  bool _isKeyword(String word) {
    const keywords = {
      'var', 'final', 'const', 'if', 'else', 'for', 'while', 'do', 'switch',
      'case', 'default', 'break', 'continue', 'return', 'try', 'catch',
      'finally', 'throw', 'class', 'extends', 'implements', 'with', 'mixin',
      'enum', 'import', 'export', 'library', 'part', 'as', 'show', 'hide',
      'async', 'await', 'yield', 'true', 'false', 'null', 'this', 'super',
      'new', 'void', 'int', 'double', 'String', 'bool', 'num', 'dynamic',
      'Object', 'List', 'Map', 'Set', 'props',
      r'$state', r'$derived', r'$effect',
    };
    return keywords.contains(word);
  }

  /// Capitalize first letter
  String _capitalize(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1);
  }
}
