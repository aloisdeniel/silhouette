/// Example usage of the Silhouette compiler
library;

import 'package:silhouette_cli/silhouette_cli.dart';

void main() {
  // Example 1: Simple counter component
  const counterSource = '''
<script>
  var count = state(0);
  var double = derived(() => count * 2);
  
  void increment() {
    count = count + 1;
  }
</script>

<div>
  <h1>Counter: {count}</h1>
  <p>Double: {double}</p>
  <button on:click={increment}>+</button>
</div>
''';

  print('=== Compiling Counter Component ===\n');
  final compiler = Compiler();
  final result = compiler.compile(counterSource);
  
  print('Generated Code:');
  print(result.code);
  
  if (result.warnings.isNotEmpty) {
    print('\nWarnings:');
    for (final warning in result.warnings) {
      print('  - $warning');
    }
  }
  
  print('\n' + '=' * 50 + '\n');
  
  // Example 2: List rendering
  const listSource = '''
<script>
  var items = state(['Apple', 'Banana', 'Cherry']);
</script>

<ul>
  {#each items as item, index}
    <li>{index + 1}. {item}</li>
  {/each}
</ul>
''';

  print('=== Compiling List Component ===\n');
  final result2 = compiler.compile(listSource);
  print('Generated Code:');
  print(result2.code);
}
