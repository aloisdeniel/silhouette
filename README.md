# Silhouette

> ⚠️ **WARNING: Prototype / Experimental Project**
>
> This repository is a **vibe-coded prototype** created for experimentation and learning purposes.
> 
> **DO NOT USE IN PRODUCTION.**
>
> This code is not battle-tested, not optimized, and not maintained for production use. It's a playground for exploring ideas around Svelte-like syntax in Dart.

## What is this?

Silhouette is an experimental UI framework for Dart that takes inspiration from Svelte. It provides a compiler that transforms `.silhouette` template files into Dart code with reactive state management.

### Key Features (Experimental)

- 🎨 **Svelte-inspired syntax** - Familiar template syntax with reactive primitives
- 🔄 **Reactive state management** - `$state`, `$derived`, and `$effect` runes
- 🎯 **Component composition** - Build reusable components with props
- 🌐 **Dual output modes**:
  - **Client mode** - Generates interactive DOM-based components (using `package:web`)
  - **Static mode** - Generates server-side rendered HTML strings
- 🚀 **Compile-time optimizations** - Templates compiled to efficient Dart code

### Example

```svelte
<script>
  final (
    :String name,
  ) = $props((
    name: 'World',
  ));
  
  final int count = $state(0);
  final String greeting = $derived(() => 'Hello, $name!');
  
  $effect(() {
    print('Count changed: $count');
  });
  
  void increment() {
    count = count + 1;
  }
</script>

<div>
  <h1>{greeting}</h1>
  <p>Count: {count}</p>
  <button on:click={increment}>Increment</button>
</div>

<style>
  div {
    padding: 20px;
  }
</style>
```

### Project Structure

```
silhouette/
├── packages/
│   └── silhouette_cli/
│       ├── bin/
│       │   └── silhouette.dart          # CLI entry point
│       ├── lib/
│       │   └── src/
│       │       ├── compiler/
│       │       │   ├── parser.dart      # Template parser
│       │       │   ├── analyzer.dart    # AST analyzer
│       │       │   ├── ast.dart         # AST definitions
│       │       │   ├── compiler.dart    # Main compiler
│       │       │   └── generator/
│       │       │       ├── client.dart  # Client-side code generator
│       │       │       └── static.dart  # Static HTML generator
│       │       └── runtime/
│       │           └── runtime.dart     # Runtime reactive primitives
│       ├── example/                     # Example components
│       └── test/                        # Tests
└── README.md
```

### Usage

```bash
# Compile a single component (client mode - default)
dart run silhouette counter.silhouette

# Compile for static/SSR mode
dart run silhouette counter.silhouette --mode static

# Compile all components in a directory
dart run silhouette ./components

# Watch for changes
dart run silhouette ./components --watch

# Help
dart run silhouette --help
```

### Runes (Reactive Primitives)

- **`$state(initialValue)`** - Creates reactive state
- **`$derived(() => expression)`** - Creates computed/derived values
- **`$effect(() => { ... })`** - Runs side effects when dependencies change
- **`$props(defaults)`** - Declares component properties using Dart record destructuring

### Template Syntax

- `{expression}` - Expression interpolation
- `{@html expression}` - Raw HTML output
- `{#if condition}...{:else}...{/if}` - Conditional rendering
- `{#each items as item, index}...{/each}` - List rendering
- `{#await promise}...{:then value}...{:catch error}...{/await}` - Async handling
- `on:event={handler}` - Event binding
- `bind:value={variable}` - Two-way binding

## Again: This is NOT Production-Ready

Things that are missing, broken, or half-baked:

- ❌ No comprehensive test coverage
- ❌ No performance benchmarks
- ❌ Limited error handling
- ❌ Incomplete feature set
- ❌ No versioning or release process
- ❌ No documentation beyond this README
- ❌ Probably has bugs you haven't discovered yet
- ❌ Built through vibes and experimentation, not rigorous engineering

## Why does this exist?

This is a **learning project** to explore:

1. How Svelte's compiler works under the hood
2. How to build a template language compiler in Dart
3. Reactive state management patterns
4. Code generation techniques
5. The feasibility of Svelte-like DX in Dart

## Can I look at the code?

Sure! Feel free to explore, learn, fork, and experiment. Just don't put it in production.

## License

MIT License - See LICENSE file

---

**Remember:** This is a prototype. A proof of concept. An experiment. A vibe. Not a product. 🎨✨
