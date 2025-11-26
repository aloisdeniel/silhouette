#!/usr/bin/env dart

/// Silhouette CLI tool
///
/// Compiles .silhouette files into Dart components
library;

import 'dart:io';
import 'package:args/args.dart';
import 'package:silhouette_cli/silhouette_cli.dart';
import 'package:path/path.dart' as path;

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help',
        abbr: 'h', negatable: false, help: 'Show usage information')
    ..addFlag('debug', abbr: 'd', negatable: false, help: 'Generate debug code')
    ..addFlag('watch',
        abbr: 'w', negatable: false, help: 'Watch for file changes')
    ..addOption('output', abbr: 'o', help: 'Output file or directory')
    ..addOption('name', abbr: 'n', help: 'Component class name');

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      _printUsage(parser);
      return;
    }

    if (results.rest.isEmpty) {
      print('Error: No input file specified\n');
      _printUsage(parser);
      exit(1);
    }

    final inputPath = results.rest[0];
    final outputPath = results['output'] as String?;
    final componentName = results['name'] as String?;
    final debug = results['debug'] as bool;
    final watch = results['watch'] as bool;

    if (watch) {
      await _watchAndCompile(inputPath, outputPath, componentName, debug);
    } else {
      await _compileFile(inputPath, outputPath, componentName, debug);
    }
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  print('Silhouette Compiler - Compile Svelte-like templates to Dart');
  print('');
  print('Usage: silhouette [options] <input-file>');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('Examples:');
  print('  silhouette counter.svelte');
  print('  silhouette counter.svelte -o counter.dart');
  print('  silhouette counter.svelte --watch');
}

Future<void> _compileFile(
  String inputPath,
  String? outputPath,
  String? componentName,
  bool debug,
) async {
  final file = File(inputPath);

  if (!await file.exists()) {
    print('Error: File not found: $inputPath');
    exit(1);
  }

  print('Compiling $inputPath...');

  final source = await file.readAsString();
  final compiler = Compiler(
    options: CompileOptions(
      debug: debug,
      componentName: componentName,
    ),
  );

  final result = compiler.compile(source);

  // Determine output path
  final output = outputPath ?? _getDefaultOutputPath(inputPath);

  // Write output
  final outputFile = File(output);
  await outputFile.writeAsString(result.code);

  print('✓ Compiled to $output');

  // Print warnings
  if (result.warnings.isNotEmpty) {
    print('\nWarnings:');
    for (final warning in result.warnings) {
      print('  ⚠ $warning');
    }
  }
}

Future<void> _watchAndCompile(
  String inputPath,
  String? outputPath,
  String? componentName,
  bool debug,
) async {
  print('Watching $inputPath for changes...');
  print('Press Ctrl+C to stop\n');

  // Initial compilation
  await _compileFile(inputPath, outputPath, componentName, debug);

  // Watch for changes
  final file = File(inputPath);
  DateTime? lastModified = await file.lastModified();

  while (true) {
    await Future.delayed(Duration(milliseconds: 500));

    if (!await file.exists()) continue;

    final modified = await file.lastModified();
    if (modified.isAfter(lastModified!)) {
      lastModified = modified;
      print('\nFile changed, recompiling...');
      await _compileFile(inputPath, outputPath, componentName, debug);
    }
  }
}

String _getDefaultOutputPath(String inputPath) {
  final dir = path.dirname(inputPath);
  final basename = path.basenameWithoutExtension(inputPath);
  return path.join(dir, '$basename.g.dart');
}
