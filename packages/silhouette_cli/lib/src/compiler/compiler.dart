/// Main compiler class
///
/// Orchestrates parsing, analysis, and code generation
library;

import 'dart:math';

import 'ast.dart';
import 'parser.dart';
import 'analyzer.dart';
import 'generator/client.dart';
import 'generator/static.dart';

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

  /// Generation mode: 'client' or 'static'
  final String mode;

  const CompileOptions({
    this.debug = false,
    this.mode = 'client',
  });
}

/// Main compiler
class Compiler {
  final CompileOptions options;
  final _random = Random();

  Compiler({this.options = const CompileOptions()});

  /// Generate a unique component ID based on name and randomness
  String _generateComponentId(String componentName) {
    final randomPart = _random.nextInt(999999).toString().padLeft(6, '0');
    final namePart =
        componentName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return 'silhouette-$namePart-$randomPart';
  }

  /// Compile a Silhouette component from source
  CompileResult compile(String componentName, String source) {
    final warnings = <String>[];

    final componentId = _generateComponentId(componentName);

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
      final String code;
      if (options.mode == 'static') {
        final generator = StaticCodeGenerator(
          ast,
          analysis,
          componentId,
          componentName: componentName,
        );
        code = generator.generate();
      } else {
        final generator = ClientCodeGenerator(
          ast,
          analysis,
          componentId,
          componentName: componentName,
        );
        code = generator.generate();
      }

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
