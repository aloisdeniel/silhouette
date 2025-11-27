/// Analyzer for Silhouette components
///
/// Analyzes the AST to detect runes, build scope tree, and track dependencies
library;

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart' as dart_ast;
import 'package:analyzer/dart/ast/visitor.dart';

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
    // Parse imports first (top-level analysis)
    // We use throwIfDiagnostics: false because top-level patterns might cause errors
    // but we still want to get the imports
    final parseResult = parseString(
      content: script.content,
      throwIfDiagnostics: false,
    );
    final unit = parseResult.unit;
    
    // Analyze imports
    final imports = <dart_ast.ImportDirective>[];
    for (final directive in unit.directives) {
      if (directive is dart_ast.ImportDirective) {
        imports.add(directive);
        _analyzeImport(directive);
      }
    }
    
    // Create wrapped content for body analysis
    // We wrap the content in a function to allow top-level patterns
    // and replace imports with whitespace to preserve offsets
    var bodyContent = script.content;
    
    // Replace imports with spaces
    for (final directive in imports.reversed) {
      final length = directive.length;
      bodyContent = bodyContent.replaceRange(
        directive.offset,
        directive.end,
        ' ' * length,
      );
    }
    
    // Wrap in a function
    final wrappedContent = 'void _rune_wrapper() {\n$bodyContent\n}';
    
    // Parse wrapped content
    final wrappedResult = parseString(
      content: wrappedContent,
      throwIfDiagnostics: false,
    );
    
    // Visit the AST
    final visitor = _ScriptVisitor(this);
    wrappedResult.unit.visitChildren(visitor);
  }

  /// Analyze an import directive
  void _analyzeImport(dart_ast.ImportDirective node) {
    final uri = node.uri.stringValue;
    if (uri != null) {
      final alias = node.prefix?.name;
      
      _imports.add(ImportDeclaration(
        uri: uri,
        alias: alias,
      ));
      
      // If there's an alias, add it to scope
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
    }
  }

  /// Analyze $props() declarations using AST
  void _analyzePropsDeclarations(dart_ast.PatternVariableDeclaration node) {
    final pattern = node.pattern;
    final initializer = node.expression;

    if (pattern is! dart_ast.RecordPattern) return;
    if (initializer is! dart_ast.MethodInvocation) return;

    final methodName = initializer.methodName.name;
    if (methodName != r'$props') return;

    // Parse defaults if provided
    final defaults = <String, String>{};
    if (initializer.argumentList.arguments.isNotEmpty) {
      final arg = initializer.argumentList.arguments.first;
      if (arg is dart_ast.RecordLiteral) {
        for (final field in arg.fields) {
          if (field is dart_ast.NamedExpression) {
             // Named field: name: value
             final name = field.name.label.name;
             final value = field.expression.toSource();
             defaults[name] = value;
          }
        }
      }
    }

    // Parse each property from the record destructuring
    for (final field in pattern.fields) {
       final fieldPattern = field.pattern;
       
       String? name;
       String? type;
       
       // Handle (:Type name) or (name)
       if (fieldPattern is dart_ast.DeclaredVariablePattern) {
          name = fieldPattern.name.lexeme;
          type = fieldPattern.type?.toSource();
       } else if (fieldPattern is dart_ast.CastPattern) {
          // (:name as Type) ?? Not typical for $props but possible
          final inner = fieldPattern.pattern;
          if (inner is dart_ast.VariablePattern) {
             name = inner.name.lexeme;
             type = fieldPattern.type.toSource();
          }
       }
       
       if (name != null) {
         final defaultValue = defaults[name];
         
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
    if (expression.trim().isEmpty) return;
    
    // Wrap expression to make it parseable as a statement
    // We use a variable declaration to ensure expressions like "{ a: 1 }" are parsed correctly
    final wrappedContent = 'void _wrapper() { var _ = ($expression); }';
    
    try {
      final result = parseString(
        content: wrappedContent, 
        throwIfDiagnostics: false
      );
      
      final visitor = _IdentifierVisitor(this);
      result.unit.visitChildren(visitor);
    } catch (_) {
      // Ignore parse errors for expressions
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

/// Visitor for analyzing Dart script AST
class _ScriptVisitor extends RecursiveAstVisitor<void> {
  final Analyzer analyzer;

  _ScriptVisitor(this.analyzer);

  @override
  void visitVariableDeclaration(dart_ast.VariableDeclaration node) {
    final name = node.name.lexeme;
    final initializer = node.initializer;
    
    if (initializer != null) {
      // Check if this is a rune call
      if (initializer is dart_ast.MethodInvocation) {
        final methodName = initializer.methodName.name;
        final runeType = _detectRuneType(methodName);
        
        if (runeType != null) {
          // Get the type annotation from the parent VariableDeclarationList
          String? type;
          final parent = node.parent;
          if (parent is dart_ast.VariableDeclarationList && parent.type != null) {
            type = parent.type.toString();
          }
          
          // Get the initializer value
          final args = initializer.argumentList.arguments;
          String? initValue;
          if (args.isNotEmpty) {
            initValue = args.first.toString();
          }
          
          final binding = analyzer._createBindingForRune(
            name,
            runeType,
            initValue ?? '',
            type,
          );
          analyzer._currentScope.declare(name, binding);
          
          // Track identifier references in the initializer
          // Handled by super.visitVariableDeclaration visiting children
          
          super.visitVariableDeclaration(node);
          return;
        }
      }
    }
    
    // Regular variable declaration
    String? type;
    final parent = node.parent;
    if (parent is dart_ast.VariableDeclarationList && parent.type != null) {
      type = parent.type.toString();
    }
    
    analyzer._currentScope.declare(name, Binding(
      name: name,
      kind: BindingKind.normal,
      initializer: initializer?.toString(),
      type: type,
    ));
    
    super.visitVariableDeclaration(node);
  }

  @override
  void visitMethodInvocation(dart_ast.MethodInvocation node) {
    // Handle standalone effect calls (both $effect and _rune_effect)
    // Dependencies are tracked by visiting children
    
    super.visitMethodInvocation(node);
  }

  @override
  void visitAssignmentExpression(dart_ast.AssignmentExpression node) {
    final leftSide = node.leftHandSide;
    if (leftSide is dart_ast.SimpleIdentifier) {
      final name = leftSide.name;
      final binding = analyzer._currentScope.lookup(name);
      if (binding != null) {
        binding.reassigned = true;
        binding.assignments.add(node.rightHandSide.toString());
      }
    }
    
    super.visitAssignmentExpression(node);
  }

  @override
  void visitFunctionDeclaration(dart_ast.FunctionDeclaration node) {
    final name = node.name.lexeme;

    // Ignore internal wrapper
    if (name == '_rune_wrapper') {
      super.visitFunctionDeclaration(node);
      return;
    }

    analyzer._currentScope.declare(name, Binding(
      name: name,
      kind: BindingKind.normal,
    ));
    
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitPatternVariableDeclaration(dart_ast.PatternVariableDeclaration node) {
    // Check for $props()
    final initializer = node.expression;
    if (initializer is dart_ast.MethodInvocation) {
      final methodName = initializer.methodName.name;
      if (methodName == r'$props' || methodName == '_rune_props') {
        analyzer._analyzePropsDeclarations(node);
        // We still want to visit children to track dependencies in default values
        // but we need to avoid processing the pattern as normal variables if it's props
        super.visitPatternVariableDeclaration(node);
        return;
      }
    }

    // Handle normal pattern declarations if needed
    super.visitPatternVariableDeclaration(node);
  }

  @override
  void visitSimpleIdentifier(dart_ast.SimpleIdentifier node) {
    final identifier = node.name;
    if (!analyzer._isKeyword(identifier)) {
      final binding = analyzer._currentScope.lookup(identifier);
      if (binding != null) {
        binding.references.add(node.toString());
        analyzer._dependencies.add(identifier);
      }
    }
    super.visitSimpleIdentifier(node);
  }

  /// Detect rune type from function name
  RuneType? _detectRuneType(String name) {
    return switch (name) {
      r'$state' => RuneType.state,
      r'$derived' => RuneType.derived,
      r'$effect' => RuneType.effect,
      r'$props' => RuneType.props,
      _ => null,
    };
  }
}

/// Visitor for extracting identifier references
class _IdentifierVisitor extends RecursiveAstVisitor<void> {
  final Analyzer analyzer;

  _IdentifierVisitor(this.analyzer);

  @override
  void visitSimpleIdentifier(dart_ast.SimpleIdentifier node) {
    final identifier = node.name;
    if (!analyzer._isKeyword(identifier)) {
      final binding = analyzer._currentScope.lookup(identifier);
      if (binding != null) {
        binding.references.add(node.toString());
        analyzer._dependencies.add(identifier);
      }
    }
    super.visitSimpleIdentifier(node);
  }
}
