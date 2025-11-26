# Silhouette Compiler Architecture

This document describes the internal architecture of the Silhouette compiler, inspired by [Svelte](https://svelte.dev/).

## Overview

The Silhouette compiler follows a **three-phase architecture**:

1. **Parse** - Convert source text into an Abstract Syntax Tree (AST)
2. **Analyze** - Detect runes, build scope tree, and track dependencies  
3. **Generate** - Transform AST into executable Dart code using dart:html

```
┌─────────────┐     ┌──────────────┐     ┌────────────────┐
│   Source    │────▶│  Parser      │────▶│   AST          │
│  .svelte    │     │              │     │                │
└─────────────┘     └──────────────┘     └────────────────┘
                                                │
                                                ▼
                    ┌──────────────┐     ┌────────────────┐
                    │  Generator   │◀────│   Analyzer     │
                    │              │     │                │
                    └──────────────┘     └────────────────┘
                           │                     │
                           ▼                     ▼
                    ┌──────────────┐     ┌────────────────┐
                    │  Dart Code   │     │ Analysis Result│
                    │              │     │ - Scope tree   │
                    └──────────────┘     │ - Dependencies │
                                         │ - Runes        │
                                         └────────────────┘
```

## Phase 1: Parser

**Location**: `lib/src/compiler/parser.dart`

The parser is a **recursive descent parser** that converts Svelte-like template syntax into an AST.

### Key Components

- **Parser class** - Main parsing logic with position tracking
- **State machine** - Different parsing modes for script, style, and template
- **Error handling** - Reports parsing errors with position information

### Parsing Strategy

The parser uses a single-pass approach:

1. **Top-level blocks** - Parse `<script>`, `<script context="module">`, and `<style>` first
2. **Template fragment** - Parse the remaining content as HTML/template
3. **Recursive descent** - Each node type has its own parsing method

### Template Syntax Handled

- **Text nodes** - Plain text
- **Expression tags** - `{expression}`
- **HTML tags** - `{@html content}`
- **Control flow** - `{#if}`, `{#each}`, `{#await}`
- **Elements** - HTML elements and components
- **Attributes** - Regular, spread, events, and bind directives

### AST Structure

The AST is defined in `lib/src/compiler/ast.dart`:

```dart
RootNode
├── ScriptNode? (instance script)
├── ScriptNode? (module script)
├── StyleNode?
└── FragmentNode
    └── List<TemplateNode>
        ├── TextNode
        ├── ExpressionTagNode
        ├── ElementNode
        │   ├── attributes: List<AttributeNode>
        │   └── children: List<TemplateNode>
        └── BlockNode (IfBlock, EachBlock, AwaitBlock)
```

## Phase 2: Analyzer

**Location**: `lib/src/compiler/analyzer.dart`

The analyzer performs semantic analysis on the AST to understand the component's reactive behavior.

### Key Components

1. **Scope building** - Create a hierarchical scope tree
2. **Rune detection** - Identify `state()`, `derived()`, `effect()`, and `props()` calls
3. **Dependency tracking** - Track which variables are used where
4. **Binding classification** - Categorize variables by kind

### Scope Tree

Each scope tracks:

```dart
class Scope {
  Scope? parent;                           // Parent scope
  Map<String, Binding> declarations;       // Variables declared here
  List<Scope> children;                    // Child scopes
}
```

### Binding Types

Variables are classified as:

- **normal** - Regular Dart variable
- **state** - Reactive state (`state(...)`)
- **derived** - Computed value (`derived(...)`)
- **prop** - Component prop (`props()`)
- **each** - Loop iteration variable

### Rune Detection

The analyzer looks for patterns like:

```dart
var count = state(0);           // State rune
var double = derived(() => ...); // Derived rune
effect(() { ... });             // Effect rune
var props = props();            // Props rune
```

### Dependency Extraction

For each expression in the template, the analyzer:

1. Extracts all identifiers using regex
2. Looks them up in the scope tree
3. Marks them as dependencies
4. Filters out keywords and built-ins

### Analysis Result

```dart
class AnalysisResult {
  Scope rootScope;                  // Top-level scope
  List<Binding> stateBindings;      // All state variables
  List<Binding> derivedBindings;    // All derived values
  List<Binding> propBindings;       // All props
  Set<String> dependencies;         // All template dependencies
}
```

## Phase 3: Generator

**Location**: `lib/src/compiler/generator.dart`

The generator transforms the analyzed AST into executable Dart code using dart:html APIs.

### Code Generation Strategy

The generator produces a Dart class with:

1. **State fields** - `State<T>` instances with getters/setters
2. **Derived fields** - `Derived<T>` instances with getters
3. **Constructor** - Initializes all reactive values
4. **mount() method** - Creates DOM and attaches to target
5. **destroy() method** - Cleans up the component

### Template Compilation

Each template node is compiled to imperative DOM operations:

**Input**:
```html
<p>Count: {count}</p>
```

**Output**:
```dart
final _p_0 = Element.tag("p");
final _text_1 = Text("Count: ");
_p_0.append(_text_1);
final _text_2 = Text("");
_p_0.append(_text_2);
effect(() {
  _text_2.text = "${count}";
});
```

### Reactivity Wrapping

Expressions in the template are wrapped in `effect()` calls:

- **Text interpolation** - `effect(() { text.text = "${expr}"; })`
- **Attributes** - `effect(() { elem.setAttribute("attr", "${expr}"); })`
- **If blocks** - `effect(() { if (condition) { ... } })`
- **Each blocks** - `effect(() { for (var item in items) { ... } })`

### Event Handlers

Event attributes are compiled to listeners:

```html
<button on:click={increment}>
```

```dart
button.onClick.listen((event) {
  increment;
});
```

### Two-way Binding

Bind directives create bidirectional sync:

```html
<input bind:value={name} />
```

```dart
// Update element when state changes
effect(() {
  if (element is InputElement) {
    element.value = name.toString();
  }
});

// Update state when element changes
element.onInput.listen((event) {
  if (element is InputElement) {
    name = element.value;
  }
});
```

## Runtime Library

**Location**: `lib/src/runtime/runtime.dart`

The runtime provides the reactive primitives that the generated code uses.

### Core Primitives

#### State<T>

A reactive value container that notifies subscribers when changed:

```dart
class State<T> {
  T _value;
  Set<Effect> _subscribers;
  
  T get value {
    track();  // Register current effect as subscriber
    return _value;
  }
  
  set value(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      notify();  // Notify all subscribers
    }
  }
}
```

#### Derived<T>

A computed value that re-evaluates when dependencies change:

```dart
class Derived<T> {
  T Function() _compute;
  T? _cachedValue;
  bool _dirty = true;
  Set<Effect> _subscribers;
  
  T get value {
    if (_dirty) {
      _recompute();  // Re-run computation
    }
    track();
    return _cachedValue;
  }
}
```

#### Effect

A side effect that runs when dependencies change:

```dart
class Effect {
  void Function() _fn;
  Set<Reactive> _dependencies;
  
  void _run() {
    // Clear old dependencies
    // Run function while tracking new dependencies
    // Store cleanup if returned
  }
}
```

### Dependency Tracking

The runtime uses a global `_currentEffect` variable:

1. When an effect runs, it sets `_currentEffect = this`
2. When a reactive value is read, it calls `track()`
3. `track()` adds `_currentEffect` to its subscribers
4. When the effect finishes, it restores the previous `_currentEffect`

This creates an automatic dependency graph:

```
State(count)
  ↓ (subscribed by)
Derived(double)
  ↓ (subscribed by)
Effect(update DOM)
```

### Update Scheduling

When a state changes:

1. Mark all subscribing effects as dirty
2. Add them to the effect queue
3. Flush the queue (run all dirty effects)
4. Effects may read other reactive values, creating new subscriptions

### Batching

Multiple state changes can be batched to avoid redundant effect runs:

```dart
batch(() {
  count.value = 5;
  name.value = 'Alice';
});
// Effects only run once, after both changes
```

## Comparison to Svelte

### Similarities

- Three-phase compiler architecture
- Runes for reactivity (Svelte 5)
- Template syntax (if, each, await)
- Fine-grained reactive updates
- Automatic dependency tracking

### Differences

| Aspect | Svelte | Silhouette |
|--------|--------|-----------|
| Language | JavaScript/TypeScript | Dart |
| Output | Vanilla JS + DOM | Dart + dart:html |
| Parsing | Custom parser + Acorn | Custom recursive descent |
| Reactivity | Compiler transforms | Runtime signals |
| Components | Import/export | Single file (for now) |
| SSR | Yes | No (yet) |
| Animations | Yes | No (yet) |

## Performance Considerations

### Compilation

- Single-pass parsing is fast
- Simple regex-based Dart code analysis (not full AST parsing)
- Minimal AST transformations

### Runtime

- **Fine-grained reactivity** - Only update what changed
- **Lazy evaluation** - Derived values only compute when read
- **Batching** - Multiple updates can be batched
- **Efficient cleanup** - Effects properly clean up old subscriptions

### Generated Code

- **Direct DOM manipulation** - No virtual DOM overhead
- **Minimal runtime** - Small runtime library (~300 lines)
- **Effect granularity** - Each dynamic piece gets its own effect

## Future Improvements

### Short-term

1. Better Dart code parsing (use analyzer package)
2. Component composition (imports/exports)
3. Props system
4. Slots for content projection
5. More attribute directives (class:, style:)

### Medium-term

1. Scoped CSS implementation
2. Transitions and animations
3. Server-side rendering
4. Dev mode error messages
5. Source maps

### Long-term

1. TypeScript-like type inference
2. Build tool integration (build_runner)
3. Hot module replacement
4. Performance profiling tools
5. Component library ecosystem

## Development

### Adding a New Template Feature

1. Update `ast.dart` with new AST node type
2. Add parsing logic in `parser.dart`
3. Add analysis logic in `analyzer.dart` if needed
4. Add code generation in `generator.dart`
5. Add tests in `test/`
6. Update documentation

### Adding a New Rune

1. Add enum value to `RuneType` in `analyzer.dart`
2. Update `_detectRuneType()` to recognize it
3. Update `_createBindingForRune()` to handle it
4. Add runtime implementation in `runtime.dart`
5. Update code generator to emit correct runtime calls
6. Add tests and documentation

## Testing

Run the test suite:

```bash
dart test
```

Test the CLI:

```bash
dart run bin/silhouette.dart example/counter.svelte
```

Run the programmatic example:

```bash
dart run example/example.dart
```

## References

- [Svelte Compiler Source](https://github.com/sveltejs/svelte/tree/main/packages/svelte/src/compiler)
- [Svelte Documentation](https://svelte.dev/docs)
- [Svelte 5 Runes RFC](https://github.com/sveltejs/rfcs/blob/master/text/0001-runes.md)
- [Dart HTML Library](https://api.dart.dev/stable/dart-html/dart-html-library.html)
