# Silhouette CLI

A Svelte-like compiler for Dart that compiles templates into reactive Dart components using runes for state management.

## Features

- **Svelte-like syntax** - Write components with familiar `<script>`, `<template>`, and `<style>` blocks
- **Runes for reactivity** - Use `$state`, `$derived`, and `$effect` runes inspired by Svelte 5
- **Fine-grained reactivity** - Automatic dependency tracking and efficient updates
- **Template syntax** - Support for `{#if}`, `{#each}`, `{#await}`, and more
- **Event handlers** - `on:click`, `on:input`, etc.
- **Two-way binding** - `bind:value` for form inputs
- **Client and static generation** - Generate reactive client code or static HTML
- **Directory compilation** - Compile all `.silhouette` files in a directory
- **Watch mode** - Automatic recompilation on file changes

## Installation

```bash
cd packages/silhouette_cli
dart pub get
```

## Usage

### CLI

Compile a single `.silhouette` file:

```bash
dart run silhouette example/counter.silhouette
```

Compile with custom output and component name:

```bash
dart run silhouette counter.silhouette -o output/counter.dart -n MyCounter
```

Compile all files in a directory:

```bash
dart run silhouette ./components
```

Generate static HTML (server-side rendering):

```bash
dart run silhouette counter.silhouette --mode static
dart run silhouette ./components -m static
```

Watch for changes:

```bash
dart run silhouette counter.silhouette --watch
dart run silhouette ./components --watch
```

Generate debug code:

```bash
dart run silhouette counter.silhouette --debug
```

### Programmatic API

```dart
import 'package:silhouette_cli/silhouette_cli.dart';

void main() {
  final source = '''
<script>
  var count = $state(0);
  void increment() => count++;
</script>

<button on:click={increment}>
  Count: {count}
</button>
''';

  final compiler = Compiler(
    options: CompileOptions(
      debug: false,
      componentName: 'MyComponent',
      mode: 'client', // or 'static'
    ),
  );
  
  final result = compiler.compile(source);
  print(result.code);
  
  // Access warnings and AST
  for (final warning in result.warnings) {
    print('Warning: $warning');
  }
}
```

## Syntax Guide

### Runes

Runes are special functions that provide reactivity:

#### `$state(initialValue)`

Create reactive state:

```dart
var count = $state(0);
var name = $state('Alice');
var items = $state([1, 2, 3]);
```

#### `$derived(computation)`

Create computed/derived values:

```dart
var count = $state(5);
var double = $derived(() => count * 2);
var squared = $derived(() => count * count);
```

#### `$effect(callback)`

Run side effects when dependencies change:

```dart
var count = $state(0);

$effect(() {
  print('Count changed to: $count');
});
```

#### `batch(fn)`

Batch multiple state updates together:

```dart
batch(() {
  count1 = count1 + 1;
  count2 = count2 + 1;
  // Effects run only once after this block
});
```

#### `untrack(fn)`

Read reactive values without creating dependencies:

```dart
var count = $state(0);

$effect(() {
  // This won't create a dependency on count
  var currentCount = untrack(() => count);
  print('Current count (untracked): $currentCount');
});
```

### Template Syntax

#### Expressions

Display reactive values:

```html
<p>Count: {count}</p>
<p>Double: {double}</p>
```

#### If Blocks

Conditional rendering:

```html
{#if count > 10}
  <p>Count is greater than 10</p>
{:else}
  <p>Count is 10 or less</p>
{/if}
```

#### Each Blocks

List rendering:

```html
{#each items as item, index}
  <li>{index}: {item}</li>
{/each}
```

With fallback:

```html
{#each items as item}
  <li>{item}</li>
{:else}
  <p>No items</p>
{/each}
```

#### Await Blocks

Handle async operations:

```html
{#await fetchData()}
  <p>Loading...</p>
{:then data}
  <p>Data: {data}</p>
{:catch error}
  <p>Error: {error}</p>
{/await}
```

#### Event Handlers

Attach event listeners:

```html
<button on:click={handleClick}>Click me</button>
<input on:input={handleInput} />
<form on:submit={handleSubmit}>
```

#### Two-way Binding

Bind input values to state:

```html
<input type="text" bind:value={name} />
```

#### HTML Content

Render raw HTML:

```html
{@html richTextContent}
```

### Component Structure

A complete component example:

```html
<script>
  // State
  var count = $state(0);
  var name = $state('World');
  
  // Derived values
  var greeting = $derived(() => 'Hello, $name!');
  
  // Effects
  $effect(() {
    print('Count is: $count');
  });
  
  // Event handlers
  void increment() {
    count = count + 1;
  }
</script>

<div class="container">
  <h1>{greeting}</h1>
  <p>Count: {count}</p>
  <button on:click={increment}>Increment</button>
  
  <input type="text" bind:value={name} />
  
  {#if count > 5}
    <p>Count is high!</p>
  {/if}
</div>

<style>
  .container {
    padding: 20px;
    max-width: 600px;
    margin: 0 auto;
  }
  
  button {
    padding: 10px 20px;
    cursor: pointer;
  }
</style>
```

## Examples

See the `example/` directory for complete examples:

- `example/counter.silhouette` - Simple counter with state and derived values
- `example/todo_list.silhouette` - Todo list with list rendering and filtering
- `example/dashboard.silhouette` - Dashboard component with complex state
- `example/user_card.silhouette` - User card with props and styling
- `example/button.silhouette` - Reusable button component
- `example/app.silhouette` - Main application component
- `example/example.dart` - Programmatic usage examples

## Architecture

The compiler follows a three-phase architecture inspired by Svelte:

1. **Parse** - Convert source to AST using `Parser`
2. **Analyze** - Detect runes, build scope tree, track dependencies using `Analyzer`
3. **Generate** - Emit Dart code using `ClientCodeGenerator` or `StaticCodeGenerator`

### Runtime

The runtime library (`lib/src/runtime/runtime.dart`) provides:

- `State<T>` - Reactive state container (accessed via `$state()`)
- `Derived<T>` - Computed values with automatic dependency tracking (accessed via `$derived()`)
- `Effect` - Side effect runner (accessed via `$effect()`)
- `batch()` - Efficient update batching
- `untrack()` - Read reactive values without tracking dependencies
- Automatic dependency tracking via effect context
- Fine-grained reactivity with minimal re-renders

### Compiler API

The main `Compiler` class provides:

- `compile(String source)` - Compile source code to Dart
- `CompileResult` - Contains generated code, warnings, and AST
- `CompileOptions` - Configuration for debug mode, component name, and generation mode

## Differences from Svelte

While inspired by Svelte, Silhouette has some differences:

- Uses Dart instead of JavaScript/TypeScript
- File extension is `.silhouette` instead of `.svelte`
- Runes use `$` prefix (`$state`, `$derived`, `$effect`) like Svelte 5
- Compiles to package:web instead of vanilla DOM APIs
- Wasm-compatible through package:web
- Supports both client-side and static HTML generation
- Directory compilation and watch mode built-in
- No component composition yet (single file components only)
- No stores (use state directly)
- No transitions/animations yet
- Simpler scoped CSS (no complex selectors)

## Limitations

Current limitations (contributions welcome!):

- No component imports/composition
- No slots
- No props (coming soon)
- Limited attribute directives
- No transitions/animations
- No server-side rendering
- Basic Dart code parsing (simple patterns only)

## Development

Run the example:

```bash
dart run example/example.dart
```

Compile examples manually:

```bash
# Compile a single example
dart run silhouette example/counter.silhouette

# Compile all examples
dart run silhouette example/

# Watch for changes
dart run silhouette example/ --watch
```

## License

MIT

## Credits

Inspired by [Svelte](https://svelte.dev/) and the amazing work of the Svelte team.
