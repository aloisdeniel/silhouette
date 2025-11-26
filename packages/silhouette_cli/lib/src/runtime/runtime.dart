/// Runtime library for Silhouette reactivity system
///
/// Provides state management primitives similar to Svelte 5 runes
library;

import 'dart:collection';

/// The current effect being executed (for dependency tracking)
Effect? _currentEffect;

/// Set of all effects that need to run
final _effectQueue = <Effect>{};
bool _isFlushingQueue = false;
bool _isBatching = false;

/// Base class for reactive values
abstract class Reactive<T> {
  T get value;
  
  /// Notify all subscribers that this value has changed
  void notify();
  
  /// Track this reactive value as a dependency
  void track();
}

/// A reactive state value (like Svelte's $state)
class State<T> implements Reactive<T> {
  T _value;
  final Set<Effect> _subscribers = {};

  State(this._value);

  @override
  T get value {
    track();
    return _value;
  }

  set value(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      notify();
    }
  }

  @override
  void track() {
    if (_currentEffect != null) {
      _subscribers.add(_currentEffect!);
      _currentEffect!._dependencies.add(this);
    }
  }

  @override
  void notify() {
    for (final subscriber in _subscribers) {
      subscriber._markDirty();
    }
    if (!_isBatching) {
      _flushQueue();
    }
  }
}

/// A derived/computed value (like Svelte's $derived)
class Derived<T> implements Reactive<T> {
  final T Function() _compute;
  T? _cachedValue;
  bool _dirty = true;
  final Set<Effect> _subscribers = {};
  final Set<Reactive> _dependencies = {};

  Derived(this._compute);

  @override
  T get value {
    if (_dirty) {
      _recompute();
    }
    track();
    return _cachedValue as T;
  }

  void _recompute() {
    // Clear old dependencies
    for (final dep in _dependencies) {
      if (dep is State) {
        dep._subscribers.remove(this as Effect);
      } else if (dep is Derived) {
        dep._subscribers.remove(this as Effect);
      }
    }
    _dependencies.clear();

    // Track new dependencies while computing
    final previousEffect = _currentEffect;
    _currentEffect = _DerivedEffect(this);
    
    try {
      _cachedValue = _compute();
      _dirty = false;
    } finally {
      _currentEffect = previousEffect;
    }
  }

  void _markDirty() {
    if (!_dirty) {
      _dirty = true;
      notify();
    }
  }

  @override
  void track() {
    if (_currentEffect != null) {
      _subscribers.add(_currentEffect!);
      _currentEffect!._dependencies.add(this);
    }
  }

  @override
  void notify() {
    for (final subscriber in _subscribers) {
      subscriber._markDirty();
    }
  }
}

/// Helper class to track derived dependencies
class _DerivedEffect extends Effect {
  final Derived _derived;

  _DerivedEffect(this._derived) : super(() {});

  @override
  void _run() {
    // Derived values don't need to run effects
  }

  @override
  void _markDirty() {
    _derived._markDirty();
  }
}

/// An effect that runs when its dependencies change (like Svelte's $effect)
class Effect {
  final dynamic Function() _fn;
  void Function()? _cleanup;
  final Set<Reactive> _dependencies = {};
  bool _dirty = true;
  bool _queued = false;

  Effect(this._fn);

  /// Run this effect
  void _run() {
    // Run cleanup from previous execution
    _cleanup?.call();
    _cleanup = null;

    // Clear old dependencies
    for (final dep in _dependencies) {
      if (dep is State) {
        dep._subscribers.remove(this);
      } else if (dep is Derived) {
        dep._subscribers.remove(this);
      }
    }
    _dependencies.clear();

    // Track new dependencies while running
    final previousEffect = _currentEffect;
    _currentEffect = this;

    try {
      final result = _fn();
      // If the function returns a cleanup function, store it
      if (result is Function) {
        _cleanup = result as void Function()?;
      }
      _dirty = false;
      _queued = false;
    } finally {
      _currentEffect = previousEffect;
    }
  }

  /// Mark this effect as needing to run
  void _markDirty() {
    if (!_dirty) {
      _dirty = true;
      if (!_queued) {
        _queued = true;
        _effectQueue.add(this);
      }
    }
  }

  /// Destroy this effect and run cleanup
  void destroy() {
    _cleanup?.call();
    _cleanup = null;
    
    // Remove from all dependencies
    for (final dep in _dependencies) {
      if (dep is State) {
        dep._subscribers.remove(this);
      } else if (dep is Derived) {
        dep._subscribers.remove(this);
      }
    }
    _dependencies.clear();
  }
}

/// Run queued effects
void _flushQueue() {
  if (_isFlushingQueue) return;
  
  _isFlushingQueue = true;
  try {
    while (_effectQueue.isNotEmpty) {
      final effects = _effectQueue.toList();
      _effectQueue.clear();
      
      for (final effect in effects) {
        if (effect._dirty) {
          effect._run();
        }
      }
    }
  } finally {
    _isFlushingQueue = false;
  }
}

/// Create a reactive state value
State<T> state<T>(T initialValue) {
  return State<T>(initialValue);
}

/// Create a derived/computed value
Derived<T> derived<T>(T Function() compute) {
  return Derived<T>(compute);
}

/// Create an effect that runs when dependencies change
Effect effect(dynamic Function() fn) {
  final eff = Effect(fn);
  eff._run(); // Run immediately
  return eff;
}

/// Batch multiple state updates together
void batch(void Function() fn) {
  final wasBatching = _isBatching;
  _isBatching = true;
  try {
    fn();
  } finally {
    _isBatching = wasBatching;
    if (!_isBatching) {
      _flushQueue();
    }
  }
}

/// Untrack reactive reads (don't add dependencies)
T untrack<T>(T Function() fn) {
  final previousEffect = _currentEffect;
  _currentEffect = null;
  try {
    return fn();
  } finally {
    _currentEffect = previousEffect;
  }
}
