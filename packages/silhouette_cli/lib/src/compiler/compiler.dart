/// Main compiler class
///
/// Orchestrates parsing, analysis, and code generation
library;

import 'ast.dart';
import 'parser.dart';
import 'analyzer.dart';
import 'generator.dart';

/// Compilation result
class CompileResult {
  final String code;
  final List<String> warnings;
  final RootNode ast;

  CompileResult({
    required this.code,
    required this.warnings,
    required this.ast,
  });
}

/// Compiler options
class CompileOptions {
  /// Generate debug code
  final bool debug;
  
  /// Component name (defaults to 'Component')
  final String? componentName;

  const CompileOptions({
    this.debug = false,
    this.componentName,
  });
}

/// Main compiler
class Compiler {
  final CompileOptions options;

  Compiler({this.options = const CompileOptions()});

  /// Compile a Silhouette component from source
  CompileResult compile(String source) {
    final warnings = <String>[];

    try {
      // Phase 1: Parse
      final parser = Parser(source);
      final ast = parser.parse();

      // Phase 2: Analyze
      final analyzer = Analyzer(ast);
      final analysis = analyzer.analyze();

      // Add warnings for unused variables
      for (final binding in analysis.rootScope.declarations.values) {
        if (binding.references.isEmpty && 
            binding.kind != BindingKind.state &&
            binding.kind != BindingKind.derived) {
          warnings.add('Unused variable: ${binding.name}');
        }
      }

      // Phase 3: Generate
      final generator = CodeGenerator(ast, analysis);
      final code = generator.generate();

      return CompileResult(
        code: code,
        warnings: warnings,
        ast: ast,
      );
    } catch (e) {
      // If compilation fails, return error in code
      return CompileResult(
        code: '// Compilation error: $e',
        warnings: ['Compilation failed: $e'],
        ast: RootNode(
          script: null,
          moduleScript: null,
          style: null,
          fragment: FragmentNode(nodes: [], start: 0, end: 0),
          start: 0,
          end: 0,
        ),
      );
    }
  }

  /// Compile from a file
  Future<CompileResult> compileFile(String path) async {
    throw UnimplementedError('File compilation not yet implemented');
  }
}
