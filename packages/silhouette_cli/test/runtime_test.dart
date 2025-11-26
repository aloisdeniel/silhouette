/// Tests for the runtime reactivity system
library;

import 'package:test/test.dart';
import 'package:silhouette_cli/src/runtime/runtime.dart';

void main() {
  group('State', () {
    test('should store and retrieve values', () {
      final count = state(0);
      expect(count.value, equals(0));
      
      count.value = 5;
      expect(count.value, equals(5));
    });

    test('should notify subscribers on change', () {
      final count = state(0);
      var effectRuns = 0;
      
      effect(() {
        count.value; // Read to track dependency
        effectRuns++;
      });
      
      expect(effectRuns, equals(1)); // Initial run
      
      count.value = 5;
      expect(effectRuns, equals(2)); // Run after change
    });
  });

  group('Derived', () {
    test('should compute values based on state', () {
      final count = state(5);
      final double = derived(() => count.value * 2);
      
      expect(double.value, equals(10));
      
      count.value = 10;
      expect(double.value, equals(20));
    });

    test('should track dependencies automatically', () {
      final a = state(2);
      final b = state(3);
      final sum = derived(() => a.value + b.value);
      
      expect(sum.value, equals(5));
      
      a.value = 5;
      expect(sum.value, equals(8));
      
      b.value = 10;
      expect(sum.value, equals(15));
    });

    test('should only recompute when dependencies change', () {
      final count = state(0);
      var computeRuns = 0;
      
      final double = derived(() {
        computeRuns++;
        return count.value * 2;
      });
      
      expect(double.value, equals(0));
      expect(computeRuns, equals(1));
      
      // Reading again shouldn't recompute
      expect(double.value, equals(0));
      expect(computeRuns, equals(1));
      
      // Changing state should trigger recompute
      count.value = 5;
      expect(double.value, equals(10));
      expect(computeRuns, equals(2));
    });
  });

  group('Effect', () {
    test('should run immediately and on dependency changes', () {
      final count = state(0);
      var effectValue = 0;
      
      effect(() {
        effectValue = count.value;
      });
      
      expect(effectValue, equals(0));
      
      count.value = 5;
      expect(effectValue, equals(5));
    });

    test('should track multiple dependencies', () {
      final a = state(1);
      final b = state(2);
      var sum = 0;
      
      effect(() {
        sum = a.value + b.value;
      });
      
      expect(sum, equals(3));
      
      a.value = 5;
      expect(sum, equals(7));
      
      b.value = 10;
      expect(sum, equals(15));
    });
  });

  group('Untrack', () {
    test('should not track dependencies', () {
      final count = state(0);
      var effectRuns = 0;
      
      effect(() {
        untrack(() {
          count.value; // This shouldn't be tracked
        });
        effectRuns++;
      });
      
      expect(effectRuns, equals(1));
      
      count.value = 5;
      expect(effectRuns, equals(1)); // Should not run again
    });
  });

  group('Batch', () {
    test('should batch multiple updates', () {
      final a = state(1);
      final b = state(2);
      var effectRuns = 0;
      
      effect(() {
        a.value;
        b.value;
        effectRuns++;
      });
      
      expect(effectRuns, equals(1));
      
      batch(() {
        a.value = 5;
        b.value = 10;
      });
      
      // Should only run once for both changes
      expect(effectRuns, equals(2));
    });
  });
}
