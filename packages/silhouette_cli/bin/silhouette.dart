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
    ..addOption('name', abbr: 'n', help: 'Component class name')
    ..addOption('mode',
        abbr: 'm',
        help: 'Generation mode',
        allowed: ['client', 'static'],
        defaultsTo: 'client');

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
    final mode = results['mode'] as String;

    // Check if input is a directory
    final inputType = await FileSystemEntity.type(inputPath);

    final compiler = Compiler(
      options: CompileOptions(
        debug: debug,
        mode: mode,
      ),
    );

    if (inputType == FileSystemEntityType.directory) {
      // Directory mode
      if (watch) {
        await _watchDirectory(compiler, inputPath, outputPath, debug);
      } else {
        await _compileDirectory(compiler, inputPath, outputPath, debug);
      }
    } else if (inputType == FileSystemEntityType.file) {
      // Single file mode
      if (watch) {
        await _watchAndCompile(
            compiler, inputPath, outputPath, componentName, debug);
      } else {
        await _compileFile(
            compiler, inputPath, outputPath, componentName, debug);
      }
    } else {
      print('Error: Input path not found: $inputPath');
      exit(1);
    }
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  print('Silhouette Compiler - Compile Svelte-like templates to Dart');
  print('');
  print('Usage: silhouette [options] <input-file-or-directory>');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('Examples:');
  print('  # Compile a single file');
  print('  silhouette counter.silhouette');
  print('  silhouette counter.silhouette -o counter.dart');
  print('  ');
  print('  # Compile all .silhouette files in a directory');
  print('  silhouette ./components');
  print('  silhouette ./src/components');
  print('  ');
  print('  # Generate static HTML (server-side rendering)');
  print('  silhouette counter.silhouette --mode static');
  print('  silhouette ./components -m static');
  print('  ');
  print('  # Watch for changes');
  print('  silhouette counter.silhouette --watch');
  print('  silhouette ./components --watch');
}

Future<void> _compileFile(
  Compiler compiler,
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

  // Derive component name from filename if not provided
  final derivedName = componentName ?? _deriveComponentName(inputPath);

  final result = compiler.compile(derivedName, source);

  // Determine output path
  final output =
      outputPath ?? _getDefaultOutputPath(inputPath, compiler.options.mode);

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
  Compiler compiler,
  String inputPath,
  String? outputPath,
  String? componentName,
  bool debug,
) async {
  print('Watching $inputPath for changes...');
  print('Press Ctrl+C to stop\n');

  // Initial compilation
  await _compileFile(compiler, inputPath, outputPath, componentName, debug);

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
      await _compileFile(compiler, inputPath, outputPath, componentName, debug);
    }
  }
}

String _getDefaultOutputPath(String inputPath, String mode) {
  final dir = path.dirname(inputPath);
  final basename = path.basenameWithoutExtension(inputPath);
  final suffix = mode == 'static' ? 'static' : 'client';
  return path.join(dir, '$basename.$suffix.g.dart');
}

String _deriveComponentName(String inputPath) {
  // Get basename without extension (e.g., "my_button" from "my_button.silhouette")
  final basename = path.basenameWithoutExtension(inputPath);

  // Convert from snake_case or kebab-case to PascalCase
  // E.g., "my_button" -> "MyButton", "user-card" -> "UserCard"
  final words = basename.split(RegExp(r'[_-]'));
  final pascalCase = words.map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join();

  return pascalCase;
}

/// Find all .silhouette files in a directory
List<String> _findSilhouetteFiles(String directoryPath) {
  final dir = Directory(directoryPath);
  final files = <String>[];

  if (!dir.existsSync()) {
    return files;
  }

  for (final entity in dir.listSync()) {
    if (entity is File && entity.path.endsWith('.silhouette')) {
      files.add(entity.path);
    }
  }

  // Sort alphabetically for consistent ordering
  files.sort();

  return files;
}

/// Compile all .silhouette files in a directory
Future<void> _compileDirectory(
  Compiler compiler,
  String directoryPath,
  String? outputPath,
  bool debug,
) async {
  final files = _findSilhouetteFiles(directoryPath);

  if (files.isEmpty) {
    print('No .silhouette files found in $directoryPath');
    return;
  }

  print('Found ${files.length} .silhouette file(s) in $directoryPath\n');

  var successCount = 0;
  var errorCount = 0;

  for (final file in files) {
    try {
      await _compileFile(compiler, file, null, null, debug);
      successCount++;
      print('');
    } catch (e) {
      print('✗ Failed to compile $file: $e\n');
      errorCount++;
    }
  }

  print('─' * 50);
  print('Compilation complete:');
  print('  ✓ $successCount succeeded');
  if (errorCount > 0) {
    print('  ✗ $errorCount failed');
  }
}

/// Watch a directory for changes to .silhouette files
Future<void> _watchDirectory(
  Compiler compiler,
  String directoryPath,
  String? outputPath,
  bool debug,
) async {
  print('Watching $directoryPath for changes...');
  print('Press Ctrl+C to stop\n');

  // Initial compilation
  await _compileDirectory(compiler, directoryPath, outputPath, debug);

  // Track last modified times
  final lastModified = <String, DateTime>{};
  final files = _findSilhouetteFiles(directoryPath);

  for (final file in files) {
    final f = File(file);
    if (await f.exists()) {
      lastModified[file] = await f.lastModified();
    }
  }

  while (true) {
    await Future.delayed(Duration(milliseconds: 500));

    // Check for new or modified files
    final currentFiles = _findSilhouetteFiles(directoryPath);

    for (final file in currentFiles) {
      final f = File(file);
      if (!await f.exists()) continue;

      final modified = await f.lastModified();

      if (!lastModified.containsKey(file)) {
        // New file
        print('\nNew file detected: $file');
        try {
          await _compileFile(compiler, file, null, null, debug);
          lastModified[file] = modified;
          print('');
        } catch (e) {
          print('✗ Failed to compile: $e\n');
        }
      } else if (modified.isAfter(lastModified[file]!)) {
        // Modified file
        print('\nFile changed: $file');
        try {
          await _compileFile(compiler, file, null, null, debug);
          lastModified[file] = modified;
          print('');
        } catch (e) {
          print('✗ Failed to compile: $e\n');
        }
      }
    }

    // Remove deleted files from tracking
    lastModified.removeWhere((file, _) => !currentFiles.contains(file));
  }
}
